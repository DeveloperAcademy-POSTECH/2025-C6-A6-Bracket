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
    
    // MARK: - Properties
    
    private let onProgress: ([T]) -> Void
    private let onComplete: ([T]) -> Void
    
    var completion: ((Result<Void, Error>) -> Void)?
    private var hasCompleted = false
    
    // MARK: - Parsing State
    
    private var rawDataBuffer = Data()
    private var jsonTextBuffer = ""
    private var braceDepth = 0
    private var parsedObjects: [T] = []
    
    private let decoder = JSONDecoder()
    
    // MARK: - Initialization
    
    init(
        decodingType: T.Type,  // 파라미터로만 받고 저장 안 함
        onProgress: @escaping ([T]) -> Void,
        onComplete: @escaping ([T]) -> Void
    ) {
        self.onProgress = onProgress
        self.onComplete = onComplete
    }
    
    // MARK: - URLSessionDataDelegate
    
    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data
    ) {
        rawDataBuffer.append(data)
        
        print("📥 Chunk received: \(data.count) bytes (Buffer: \(rawDataBuffer.count) bytes)")
        
        guard let newText = String(data: data, encoding: .utf8) else {
            print("⚠️ Failed to decode chunk as UTF-8")
            return
        }
        
        jsonTextBuffer.append(newText)
        
        let newlyParsed = parseCompletedJSONObjects(from: newText)
        
        if !newlyParsed.isEmpty {
            parsedObjects.append(contentsOf: newlyParsed)
            print("✅ Parsed \(newlyParsed.count) objects (Total: \(parsedObjects.count))")
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
        
        print("📡 Response status: \(httpResponse.statusCode)")
        
        if let error = validateResponseStatus(httpResponse.statusCode) {
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
        // ✅ 이미 완료되었으면 무시
        guard !hasCompleted else {
            print("⚠️ Already completed, ignoring")
            return
        }
        
        hasCompleted = true
        
        if let error = error {
            // Cancellation은 정상적인 종료 (401 등)
            if (error as NSError).code == NSURLErrorCancelled {
                print("⚠️ Task cancelled (likely due to error response)")
                // 상태 코드 에러로 처리
                if let httpResponse = task.response as? HTTPURLResponse,
                   let statusError = validateResponseStatus(httpResponse.statusCode) {
                    completion?(.failure(statusError))
                } else {
                    completion?(.failure(error))
                }
            } else {
                print("❌ Stream error: \(error)")
                completion?(.failure(error))
            }
        } else {
            print("✅ Stream completed: \(parsedObjects.count) objects")
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
    
    // MARK: - Private Methods - Parsing
    
    private func parseCompletedJSONObjects(from newText: String) -> [T] {
        var completed: [T] = []
        var currentObjectBuffer = ""
        
        for char in newText {
            if char == "{" {
                if braceDepth == 0 {
                    currentObjectBuffer = ""
                }
                braceDepth += 1
            }
            
            currentObjectBuffer.append(char)
            
            if char == "}" {
                braceDepth -= 1
                
                if braceDepth == 0 {
                    if let parsed = decodeJSONObject(from: currentObjectBuffer) {
                        completed.append(parsed)
                    }
                    currentObjectBuffer = ""
                }
            }
        }
        
        return completed
    }
    
    private func decodeJSONObject(from jsonString: String) -> T? {
        let trimmed = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty,
              let jsonData = trimmed.data(using: .utf8) else {
            return nil
        }
        
        do {
            return try decoder.decode(T.self, from: jsonData)
        } catch {
            print("⚠️ JSON decode error: \(error)")
            return nil
        }
    }
    
    // MARK: - Private Methods - Validation
    
    private func validateResponseStatus(_ statusCode: Int) -> Error? {
        switch statusCode {
        case 200...299:
            return nil
        case 401:
            print("⚠️ 401 Unauthorized")
            return CCAPIError.authenticationFailed(401)
        default:
            print("⚠️ Unexpected status: \(statusCode)")
            return CCAPIError.unexpectedStatusCode(statusCode)
        }
    }
    
    private func handleSSLChallenge(
        _ challenge: URLAuthenticationChallenge,
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
