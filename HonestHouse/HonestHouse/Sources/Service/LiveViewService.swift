//
//  LiveViewService.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/30/25.
//

import Foundation
import UIKit

protocol LiveViewServiceType {
    func startLiveView(
        onFrame: @escaping (ParsedFrame) -> Void,
        onError: @escaping (Error) -> Void,
        size: String,
        display: String
    ) async -> Bool
    
    func stopLiveView() async throws
}

final class LiveViewService: StreamService, LiveViewServiceType {

    private lazy var parser: ChunkedStreamParser = {
        return ChunkedStreamParser(streamType: .scroll)
    }()

    override init() {
        super.init()
    }

    override var endpoint: String {
        return "ver100/shooting/liveview/scroll"
    }

    override var httpMethod: String {
        return "GET"
    }

    func startLiveView(
        onFrame: @escaping (ParsedFrame) -> Void,
        onError: @escaping (Error) -> Void,
        size: String = "medium",
        display: String = "on"
    ) async -> Bool {
        do {
            try await enableLiveView(size: size, display: display)

            try await Task.sleep(nanoseconds: 1_000_000_000)

            await parser.reset()

            return await startStreaming(
                onDataReceived: { [weak self] data in
                    guard let self = self else { return }
                    Task {
                        await self.parser.appendChunk(data)
                        let frames = await self.parser.extractFrames()
                        if !frames.isEmpty {
                            Logger.debug("Parsed \(frames.count) frame(s)", category: .network)
                            await MainActor.run {
                                for frame in frames {
                                    onFrame(frame)
                                }
                            }
                        }
                    }
                },
                onError: onError
            )
        } catch {
            Logger.error("Failed to enable LiveView: \(error)", category: .network)
            onError(error)
            return false
        }
    }

    func stopLiveView() async throws {
        try await stopStreaming()
        await parser.reset()
        try await disableLiveView()
    }

    private func enableLiveView(size: String, display: String) async throws {
        let url = URL(string: "\(BaseURLConstants.baseURL)ver100/shooting/liveview")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "liveviewsize": size,
            "cameradisplay": display
        ]
        let bodyData = try JSONSerialization.data(withJSONObject: body)
        request.httpBody = bodyData

        if let authHeader = NetworkManager.shared.getAuthorizationHeader(
            method: "POST",
            url: url.absoluteString,
            body: bodyData
        ) {
            request.setValue(authHeader, forHTTPHeaderField: "Authorization")
            Logger.debug("Auth header added to enableLiveView", category: .network)
        }

        let session = createSSLTrustingSession()
        let (data, response) = try await session.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            Logger.debug("EnableLiveView response: \(httpResponse.statusCode)", category: .network)

            if httpResponse.statusCode == 200 {
                Logger.info("LiveView enabled successfully", category: .network)
                return
            } else {
                if let responseString = String(data: data, encoding: .utf8) {
                    Logger.error("Error response: \(responseString)", category: .network)
                }
                throw CCAPIError.httpError(httpResponse.statusCode)
            }
        }

        throw CCAPIError.invalidResponse
    }

    private func disableLiveView() async throws {
        let url = URL(string: "\(BaseURLConstants.baseURL)ver100/shooting/liveview")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "liveviewsize": "off",
            "cameradisplay": "on"
        ]
        let bodyData = try JSONSerialization.data(withJSONObject: body)
        request.httpBody = bodyData

        if let authHeader = NetworkManager.shared.getAuthorizationHeader(
            method: "POST",
            url: url.absoluteString,
            body: bodyData
        ) {
            request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        }

        let session = createSSLTrustingSession()
        _ = try? await session.data(for: request)
        Logger.info("LiveView disabled", category: .network)
    }

    private func createSSLTrustingSession() -> URLSession {
        let delegate = SSLTrustDelegate()
        return URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
    }

    private func handleReceivedData(_ data: Data, onFrame: @escaping (ParsedFrame) -> Void) {
        var buffer = data

        Logger.debug("handleReceivedData called with \(data.count) bytes", category: .network)

        var frameCount = 0
        while let frame = parseFrame(&buffer) {
            frameCount += 1
            Logger.debug("Frame #\(frameCount) parsed successfully (type: \(frame.type))", category: .network)
            onFrame(frame)
        }

        if frameCount == 0 {
            Logger.warning("No complete frames found in buffer", category: .network)
            Logger.debug("Buffer size: \(buffer.count) bytes", category: .network)
            if buffer.count > 0 {
                Logger.debug("Buffer content (hex): \(buffer.prefix(50).map { String(format: "%02X", $0) }.joined(separator: " "))", category: .network)
            }
        } else {
            Logger.debug("Parsed \(frameCount) frame(s), \(buffer.count) bytes remaining", category: .network)
        }
    }

    private func parseFrame(_ buffer: inout Data) -> ParsedFrame? {
        Logger.debug("parseFrame: buffer size = \(buffer.count) bytes", category: .network)

        guard buffer.count >= 9 else {
            Logger.debug("Buffer too small (< 9 bytes), waiting for more data", category: .network)
            return nil
        }

        Logger.debug("Checking Start Byte: [0]=0x\(String(format: "%02X", buffer[0])) [1]=0x\(String(format: "%02X", buffer[1]))", category: .network)
        guard buffer[0] == 0xFF && buffer[1] == 0x00 else {
            Logger.warning("Invalid Start Byte", category: .network)
            if let startIndex = buffer.firstIndex(where: { $0 == 0xFF }) {
                Logger.debug("Found 0xFF at index \(startIndex), skipping \(startIndex) bytes", category: .network)
                buffer = buffer.suffix(from: startIndex)
            } else {
                Logger.debug("No 0xFF found, clearing entire buffer", category: .network)
                buffer.removeAll()
            }
            return nil
        }
        Logger.debug("Start Byte OK", category: .network)

        Logger.debug("Checking Data Type: [2]=0x\(String(format: "%02X", buffer[2]))", category: .network)
        guard let dataType = DataType(rawValue: buffer[2]) else {
            Logger.warning("Invalid Data Type (0x\(String(format: "%02X", buffer[2])))", category: .network)
            buffer.removeFirst(3)
            return nil
        }
        Logger.debug("Data Type OK (\(dataType))", category: .network)

        let dataSize = UInt32(buffer[3]) << 24 |
                      UInt32(buffer[4]) << 16 |
                      UInt32(buffer[5]) << 8 |
                      UInt32(buffer[6])

        Logger.debug("Data Size bytes: [3]=0x\(String(format: "%02X", buffer[3])) [4]=0x\(String(format: "%02X", buffer[4])) [5]=0x\(String(format: "%02X", buffer[5])) [6]=0x\(String(format: "%02X", buffer[6]))", category: .network)
        Logger.debug("Data Size = \(dataSize) bytes", category: .network)

        let totalSize = 7 + Int(dataSize) + 2
        Logger.debug("Total frame size = \(totalSize) bytes (header:7 + data:\(dataSize) + end:2)", category: .network)

        guard buffer.count >= totalSize else {
            Logger.debug("Buffer too small (need \(totalSize), have \(buffer.count)), waiting for more data", category: .network)
            return nil
        }

        let endByteIndex = 7 + Int(dataSize)
        Logger.debug("Checking End Byte at index \(endByteIndex): [0x\(String(format: "%02X", buffer[endByteIndex]))] [0x\(String(format: "%02X", buffer[endByteIndex + 1]))]", category: .network)
        
        guard buffer[endByteIndex] == 0xFF && buffer[endByteIndex + 1] == 0xFF else {
            Logger.warning("Invalid End Byte (expected 0xFF 0xFF)", category: .network)
            buffer.removeFirst(7)
            return nil
        }
        Logger.debug("End Byte OK", category: .network)

        let frameData = buffer[7..<(7 + Int(dataSize))]
        Logger.debug("Extracting frame data: \(frameData.count) bytes", category: .network)

        buffer.removeFirst(totalSize)
        Logger.debug("Removed \(totalSize) bytes from buffer, remaining: \(buffer.count) bytes", category: .network)

        let frame = ParsedFrame(
            type: dataType,
            data: Data(frameData),
            timestamp: Date()
        )

        switch dataType {
        case .image:
            if let image = frame.image {
                Logger.debug("JPEG decoded successfully: \(image.size.width)x\(image.size.height)", category: .network)
            } else {
                Logger.warning("JPEG decoding failed", category: .network)
            }
        case .info:
            if let info = frame.info {
                Logger.debug("Info decoded successfully: \(info.afFrame?.count ?? 0) AF frames", category: .network)
            } else {
                Logger.warning("Info decoding failed", category: .network)
            }
        case .event:
            Logger.debug("Event frame received", category: .network)
        }

        return frame
    }
}

private final class SSLTrustDelegate: NSObject, URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

final class StubLiveViewService: LiveViewServiceType {
    func startLiveView(
        onFrame: @escaping (ParsedFrame) -> Void,
        onError: @escaping (any Error) -> Void,
        size: String,
        display: String
    ) async -> Bool {
        return false
    }
    
    func stopLiveView() async throws {
        return
    }
}
