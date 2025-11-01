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
import Foundation

/// Chunked 스트림의 URLSessionDataDelegate
final class StreamDownloadDelegate<T: Decodable>: NSObject, URLSessionDataDelegate {
    
    // MARK: - Properties
    
    private let onProgress: ([T]) -> Void
    private let onComplete: ([T]) -> Void
    private let sslHandler: (URLAuthenticationChallenge, @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> Void
    
    var completion: ((Result<Void, Error>) -> Void)?
    private var hasCompleted = false
    
    // MARK: - Parsing State
    
    private var textBuffer = ""  // 텍스트 버퍼만 유지
    private var parsedObjects: [T] = []
    
    private let decoder = JSONDecoder()
    
    // MARK: - Initialization
    
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
    
    // MARK: - URLSessionDataDelegate
    
    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data
    ) {
        guard let newText = String(data: data, encoding: .utf8) else {
            print("⚠️ Failed to decode chunk as UTF-8")
            return
        }
        
        // 버퍼에 추가
        textBuffer.append(newText)
        
        print("📥 Received \(data.count) bytes, buffer: \(textBuffer.count) chars")
        
        // 완성된 JSON 객체들 파싱
        let newlyParsed = extractAndParseJSONObjects()
        
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
        
        if validateResponseStatus(httpResponse.statusCode) != nil {
            print("⚠️ Invalid status code, cancelling task")
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
            print("⚠️ Already completed, ignoring")
            return
        }
        
        hasCompleted = true
        
        // 남은 버퍼 처리
        if !textBuffer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            print("⚠️ Processing remaining buffer: \(textBuffer.count) chars")
            let remaining = extractAndParseJSONObjects()
            if !remaining.isEmpty {
                parsedObjects.append(contentsOf: remaining)
                print("✅ Parsed \(remaining.count) remaining objects")
            }
        }
        
        if let error = error {
            if (error as NSError).code == NSURLErrorCancelled {
                print("⚠️ Task cancelled")
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
    
    /// 완성된 JSON 객체들을 추출하고 파싱
    private func extractAndParseJSONObjects() -> [T] {
        var parsed: [T] = []
        
        while true {
            // 다음 JSON 객체 찾기
            guard let (jsonString, consumedLength) = extractNextJSONObject() else {
                break
            }
            
            // JSON 파싱
            if let object = decodeJSONObject(from: jsonString) {
                parsed.append(object)
            }
            
            // 파싱된 부분 제거
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
            
            // 문자열 내부 처리
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
            
            // 문자열 밖에서만 중괄호 카운트
            if !inString {
                if char == "{" {
                    if braceCount == 0 {
                        objectStart = index
                    }
                    braceCount += 1
                } else if char == "}" {
                    braceCount -= 1
                    
                    // 완전한 JSON 객체 완성
                    if braceCount == 0, let start = objectStart {
                        objectEnd = textBuffer.index(after: index)
                        
                        let jsonString = String(textBuffer[start..<objectEnd!])
                        let consumedLength = textBuffer.distance(from: textBuffer.startIndex, to: objectEnd!)
                        
                        return (jsonString, consumedLength)
                    }
                }
            }
        }
        
        // 완성된 객체 없음
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
        sslHandler(challenge, completionHandler)
    }
}
