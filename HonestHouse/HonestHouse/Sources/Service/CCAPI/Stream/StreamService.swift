//
//  StreamService.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/30/25.
//

import Foundation

class StreamService: BaseStreamService {

    private var urlSession: URLSession?
    private var streamingTask: URLSessionDataTask?
    private(set) var isStreaming = false

    var endpoint: String {
        fatalError("Subclass must override endpoint")
    }

    var httpMethod: String {
        fatalError("Subclass must override httpMethod")
    }

    @discardableResult
    func startStreaming(
        onDataReceived: @escaping (Data) -> Void,
        onError: @escaping (Error) -> Void
    ) async -> Bool {
        guard !isStreaming else {
            Logger.warning("Already streaming", category: .network)
            return false
        }

        // Phase 1: Authentication
        guard let url = buildURL() else {
            onError(CCAPIError.invalidURL)
            return false
        }

        let request = await createAuthenticatedRequest(
            url: url,
            method: httpMethod
        )
        
        let config = createSessionConfiguration()

        let delegate = StreamDelegate(
            onBinaryDataReceived: onDataReceived,
            onError: onError,
            sslHandler: handleSSLChallenge
        )

        urlSession = URLSession(
            configuration: config,
            delegate: delegate,
            delegateQueue: nil
        )

        // Start streaming
        streamingTask = urlSession?.dataTask(with: request)
        streamingTask?.resume()
        isStreaming = true

        Logger.info("Streaming started: \(endpoint)", category: .network)
        return true
    }

    func stopStreaming() async throws {
        guard isStreaming else {
            Logger.warning("Not streaming", category: .network)
            return
        }

        streamingTask?.cancel()
        streamingTask = nil
        urlSession?.invalidateAndCancel()
        urlSession = nil
        isStreaming = false

        try await sendDeleteRequest()

        Logger.info("Streaming stopped: \(endpoint)", category: .network)
    }

    private func buildURL() -> URL? {
        return URL(string: "\(BaseURLConstants.baseURL)\(endpoint)")
    }

    private func sendDeleteRequest() async throws {
        guard let url = buildURL() else {
            throw CCAPIError.invalidURL
        }

        let request = await createAuthenticatedRequest(url: url, method: "DELETE")

        do {
            let (_, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                Logger.debug("DELETE response: \(httpResponse.statusCode)", category: .network)
            }
        } catch {
            Logger.error("DELETE request error: \(error.localizedDescription)", category: .network)
            throw error
        }
    }
}

private class StreamDelegate: NSObject, URLSessionDataDelegate {
    private var buffer = Data()
    private let onBinaryDataReceived: (Data) -> Void
    private let onError: (Error) -> Void
    private let sslHandler: (URLAuthenticationChallenge, @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> Void

    init(
        onBinaryDataReceived: @escaping (Data) -> Void,
        onError: @escaping (Error) -> Void,
        sslHandler: @escaping (URLAuthenticationChallenge, @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> Void
    ) {
        self.onBinaryDataReceived = onBinaryDataReceived
        self.onError = onError
        self.sslHandler = sslHandler
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        buffer.append(data)

        let dataCopy = Data(buffer)

        onBinaryDataReceived(dataCopy)

        buffer.removeAll()
    }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        if let httpResponse = response as? HTTPURLResponse {
            Logger.debug("Stream response status: \(httpResponse.statusCode)", category: .network)

            if httpResponse.statusCode == 401 {
                Logger.warning("401 received - authentication required", category: .network)
                Logger.warning("This usually means initial authentication didn't get nonce", category: .network)
                Logger.warning("The stream will fail, please check authentication setup", category: .network)
            }

            completionHandler(.allow)
        } else {
            completionHandler(.allow)
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            Logger.error("Stream completed with error: \(error.localizedDescription)", category: .network)
            onError(error)
        } else {
            Logger.info("Stream completed successfully", category: .network)
        }
    }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        sslHandler(challenge, completionHandler)
    }
}
