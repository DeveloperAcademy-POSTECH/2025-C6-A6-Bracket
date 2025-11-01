//
//  LiveViewService.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/30/25.
//

import Foundation
import UIKit

class LiveViewService: StreamService {

    // MARK: - Singleton
    static let shared = LiveViewService()

    // MARK: - Properties

    private lazy var parser: ChunkedStreamParser = {
        return ChunkedStreamParser(streamType: .scroll)
    }()

    private override init() {
        super.init()
    }

    // MARK: - Configuration Override

    override var endpoint: String {
        return "ver100/shooting/liveview/scroll"
    }

    override var httpMethod: String {
        return "GET"
    }

    // MARK: - Public Methods
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
                onData: { [weak self] data in
                    guard let self = self else { return }
                    Task {
                        await self.parser.appendChunk(data)
                        let frames = await self.parser.extractFrames()
                        if !frames.isEmpty {
                            print("✅ Parsed \(frames.count) frame(s)")
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
            print("❌ Failed to enable LiveView: \(error)")
            onError(error)
            return false
        }
    }

    func stopLiveView() async throws {
        try await stopStreaming()
        await parser.reset()
        try await disableLiveView()
    }

    // MARK: - Private Methods - LiveView Control

    private func enableLiveView(size: String, display: String) async throws {
        let url = URL(string: "\(BaseAPI.base.apiDesc)ver100/shooting/liveview")!
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
            print("🔑 Auth header added to enableLiveView")
        }

        let session = createSSLTrustingSession()
        let (data, response) = try await session.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("📡 EnableLiveView response: \(httpResponse.statusCode)")

            if httpResponse.statusCode == 200 {
                print("✅ LiveView enabled successfully")
                return
            } else {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("   Error response: \(responseString)")
                }
                throw CCAPIError.httpError(httpResponse.statusCode)
            }
        }

        throw CCAPIError.invalidResponse
    }

    private func disableLiveView() async throws {
        let url = URL(string: "\(BaseAPI.base.apiDesc)ver100/shooting/liveview")!
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
        print("✅ LiveView disabled")
    }

    private func createSSLTrustingSession() -> URLSession {
        let delegate = SSLTrustDelegate()
        return URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
    }

    // MARK: - Private Methods - Data Processing

    private func handleReceivedData(_ data: Data, onFrame: @escaping (ParsedFrame) -> Void) {
        var buffer = data

        print("🔄 handleReceivedData called with \(data.count) bytes")

        var frameCount = 0
        while let frame = parseFrame(&buffer) {
            frameCount += 1
            print("✅ Frame #\(frameCount) parsed successfully (type: \(frame.type))")
            onFrame(frame)
        }

        if frameCount == 0 {
            print("⚠️ No complete frames found in buffer")
            print("   Buffer size: \(buffer.count) bytes")
            if buffer.count > 0 {
                print("   Buffer content (hex): \(buffer.prefix(50).map { String(format: "%02X", $0) }.joined(separator: " "))")
            }
        } else {
            print("📊 Parsed \(frameCount) frame(s), \(buffer.count) bytes remaining")
        }
    }

    private func parseFrame(_ buffer: inout Data) -> ParsedFrame? {
        print("🔍 parseFrame: buffer size = \(buffer.count) bytes")

        guard buffer.count >= 9 else {
            print("   ⏸️  Buffer too small (< 9 bytes), waiting for more data")
            return nil
        }

        print("   Checking Start Byte: [0]=0x\(String(format: "%02X", buffer[0])) [1]=0x\(String(format: "%02X", buffer[1]))")
        guard buffer[0] == 0xFF && buffer[1] == 0x00 else {
            print("   ❌ Invalid Start Byte!")
            if let startIndex = buffer.firstIndex(where: { $0 == 0xFF }) {
                print("   🔎 Found 0xFF at index \(startIndex), skipping \(startIndex) bytes")
                buffer = buffer.suffix(from: startIndex)
            } else {
                print("   🗑️  No 0xFF found, clearing entire buffer")
                buffer.removeAll()
            }
            return nil
        }
        print("   ✓ Start Byte OK")

        print("   Checking Data Type: [2]=0x\(String(format: "%02X", buffer[2]))")
        guard let dataType = DataType(rawValue: buffer[2]) else {
            print("   ❌ Invalid Data Type! (0x\(String(format: "%02X", buffer[2])))")
            buffer.removeFirst(3)
            return nil
        }
        print("   ✓ Data Type OK (\(dataType))")

        let dataSize = UInt32(buffer[3]) << 24 |
                      UInt32(buffer[4]) << 16 |
                      UInt32(buffer[5]) << 8 |
                      UInt32(buffer[6])

        print("   Data Size bytes: [3]=0x\(String(format: "%02X", buffer[3])) [4]=0x\(String(format: "%02X", buffer[4])) [5]=0x\(String(format: "%02X", buffer[5])) [6]=0x\(String(format: "%02X", buffer[6]))")
        print("   ➡️  Data Size = \(dataSize) bytes")

        let totalSize = 7 + Int(dataSize) + 2
        print("   Total frame size = \(totalSize) bytes (header:7 + data:\(dataSize) + end:2)")

        guard buffer.count >= totalSize else {
            print("   ⏸️  Buffer too small (need \(totalSize), have \(buffer.count)), waiting for more data")
            return nil
        }

        let endByteIndex = 7 + Int(dataSize)
        print("   Checking End Byte at index \(endByteIndex): [0x\(String(format: "%02X", buffer[endByteIndex]))] [0x\(String(format: "%02X", buffer[endByteIndex + 1]))]")
        guard buffer[endByteIndex] == 0xFF && buffer[endByteIndex + 1] == 0xFF else {
            print("   ❌ Invalid End Byte! (expected 0xFF 0xFF)")
            buffer.removeFirst(7)
            return nil
        }
        print("   ✓ End Byte OK")

        let frameData = buffer[7..<(7 + Int(dataSize))]
        print("   📄 Extracting frame data: \(frameData.count) bytes")

        buffer.removeFirst(totalSize)
        print("   🗑️  Removed \(totalSize) bytes from buffer, remaining: \(buffer.count) bytes")

        let frame = ParsedFrame(
            type: dataType,
            data: Data(frameData),
            timestamp: Date()
        )

        switch dataType {
        case .image:
            if let image = frame.image {
                print("   ✅ JPEG decoded successfully: \(image.size.width)x\(image.size.height)")
            } else {
                print("   ⚠️ JPEG decoding failed")
            }
        case .info:
            if let info = frame.info {
                print("   ✅ Info decoded successfully: \(info.afFrame?.count ?? 0) AF frames")
            } else {
                print("   ⚠️ Info decoding failed")
            }
        case .event:
            print("   📢 Event frame received")
        }

        return frame
    }
}

// MARK: - SSL Trust Delegate

private class SSLTrustDelegate: NSObject, URLSessionDelegate {
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
