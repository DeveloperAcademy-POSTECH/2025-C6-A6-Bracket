//
//  StreamDownloadDelegate.swift
//  HonestHouse
//
//  Created by 이현주 on 10/31/25.
//

import Foundation

/// 점진적 다운로드의 JSON 파싱 델리게이트
/// - URLSessionDataDelegate 구현
/// - 실시간으로 완성된 JSON 객체를 파싱하여 콜백
final class StreamDownloadDelegate<T: Decodable>: NSObject, URLSessionDataDelegate {
    
    private let onProgress: ([T]) -> Void
    private let onComplete: ([T]) -> Void
    private let sslHandler: (URLAuthenticationChallenge, @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> Void
    
    var completion: ((Result<Void, Error>) -> Void)?
    
    private var hasCompleted = false
    private var textBuffer = ""
    private var parsedObjects: [T] = []
    private let decoder = JSONDecoder()
    
    init(
        decodingType: T.Type,
        onProgress: @escaping ([T]) -> Void,
        onComplete: @escaping ([T]) -> Void,
        sslHandler: @escaping (URLAuthenticationChallenge, @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> Void
    ) {
        self.onProgress = onProgress
        self.onComplete = onComplete
        self.sslHandler = sslHandler
    }
    
    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data
    ) {
        guard let newText = String(data: data, encoding: .utf8) else {
            Logger.warning("Failed to decode chunk as UTF-8", category: .network)
            return
        }
        
        textBuffer.append(newText)
        
        Logger.debug("Received \(data.count) bytes, buffer: \(textBuffer.count) chars", category: .network)
        
        let newlyParsed = extractAndParseJSONObjects()
        
        if !newlyParsed.isEmpty {
            parsedObjects.append(contentsOf: newlyParsed)
            Logger.debug("Parsed \(newlyParsed.count) objects (Total: \(parsedObjects.count))", category: .network)
            onProgress(parsedObjects)
        }
    }
    
    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        guard let httpResponse = response as? HTTPURLResponse else {
            completionHandler(.allow)
            return
        }
        
        Logger.debug("Response status: \(httpResponse.statusCode)", category: .network)
        
        if validateResponseStatus(httpResponse.statusCode) != nil {
            Logger.warning("Invalid status code, cancelling task", category: .network)
            completionHandler(.cancel)
            return
        }
        
        completionHandler(.allow)
    }
    
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        guard !hasCompleted else {
            Logger.warning("Already completed, ignoring", category: .network)
            return
        }
        
        hasCompleted = true
        
        if !textBuffer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            Logger.warning("Processing remaining buffer: \(textBuffer.count) chars", category: .network)
            let remaining = extractAndParseJSONObjects()
            if !remaining.isEmpty {
                parsedObjects.append(contentsOf: remaining)
                Logger.debug("Parsed \(remaining.count) remaining objects", category: .network)
            }
        }
        
        if let error = error {
            if (error as NSError).code == NSURLErrorCancelled {
                Logger.warning("Task cancelled", category: .network)
                if let httpResponse = task.response as? HTTPURLResponse,
                   let statusError = validateResponseStatus(httpResponse.statusCode) {
                    completion?(.failure(statusError))
                } else {
                    completion?(.failure(error))
                }
            } else {
                Logger.error("Stream error: \(error)", category: .network)
                completion?(.failure(error))
            }
        } else {
            Logger.info("Stream completed: \(parsedObjects.count) objects", category: .network)
            onComplete(parsedObjects)
            completion?(.success(()))
        }
    }
    
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        handleSSLChallenge(challenge, completionHandler: completionHandler)
    }
    
    /// 완성된 JSON 객체들을 추출하고 파싱
    private func extractAndParseJSONObjects() -> [T] {
        var parsed: [T] = []
        
        while true {
            guard let (jsonString, consumedLength) = extractNextJSONObject() else {
                break
            }
            
            if let object = decodeJSONObject(from: jsonString) {
                parsed.append(object)
            }
            
            textBuffer.removeFirst(consumedLength)
        }
        
        return parsed
    }
    
    /// 버퍼에서 다음 완성된 JSON 객체 추출
    /// - Returns: (JSON 문자열, 소비된 길이) 또는 nil
    private func extractNextJSONObject() -> (String, Int)? {
        var braceCount = 0
        var inString = false
        var escapeNext = false
        var objectStart: String.Index?
        var objectEnd: String.Index?
        
        for index in textBuffer.indices {
            let char = textBuffer[index]
            
            if escapeNext {
                escapeNext = false
                continue
            }
            
            if char == "\\" {
                escapeNext = true
                continue
            }
            
            if char == "\"" {
                inString.toggle()
                continue
            }
            
            if !inString {
                if char == "{" {
                    if braceCount == 0 {
                        objectStart = index
                    }
                    braceCount += 1
                } else if char == "}" {
                    braceCount -= 1
                    
                    if braceCount == 0, let start = objectStart {
                        objectEnd = textBuffer.index(after: index)
                        
                        let jsonString = String(textBuffer[start..<objectEnd!])
                        let consumedLength = textBuffer.distance(from: textBuffer.startIndex, to: objectEnd!)
                        
                        return (jsonString, consumedLength)
                    }
                }
            }
        }
        
        return nil
    }
    
    /// JSON 문자열을 객체로 디코딩
    private func decodeJSONObject(from jsonString: String) -> T? {
        let trimmed = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty,
              let jsonData = trimmed.data(using: .utf8) else {
            return nil
        }
        
        do {
            return try decoder.decode(T.self, from: jsonData)
        } catch {
            Logger.warning("JSON decode error: \(error)", category: .network)
            return nil
        }
    }
    
    private func validateResponseStatus(_ statusCode: Int) -> Error? {
        switch statusCode {
        case 200...299:
            return nil
        case 401:
            Logger.warning("401 Unauthorized", category: .network)
            return CCAPIError.authenticationFailed(401)
        default:
            Logger.warning("Unexpected status: \(statusCode)", category: .network)
            return CCAPIError.unexpectedStatusCode(statusCode)
        }
    }
    
    private func handleSSLChallenge(
        _ challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        sslHandler(challenge, completionHandler)
    }
}
