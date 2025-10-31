//
//  StreamDownloadService.swift
//  HonestHouse
//
//  Created by 이현주 on 10/31/25.
//

import Foundation

/// Chunked Transfer Encoding 응답을 스트리밍으로 처리하는 서비스
/// - 유한한 스트림 (서버가 모든 데이터 전송 후 연결 종료)
/// - JSON 객체들을 실시간으로 파싱
class StreamDownloadService {
    
    static let shared = StreamDownloadService()
    
    // MARK: - Properties
    private let networkManager: NetworkManager
    
    // MARK: - Configuration
    private enum Configuration {
        static let requestTimeout: TimeInterval = 300
        static let resourceTimeout: TimeInterval = 600
    }
    
    // MARK: - Initialization
    private init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    // MARK: - Public Methods
    
    /// Chunked 응답을 스트리밍하며 점진적으로 파싱
    /// - Parameters:
    ///   - url: 요청 URL
    ///   - headers: 추가 헤더
    ///   - type: 디코딩할 타입
    ///   - onProgress: 청크를 받을 때마다 호출 (누적된 전체 데이터)
    ///   - onComplete: 완료 시 호출 (최종 전체 데이터)
    func stream<T: Decodable>(
        from url: URL,
        headers: [String: String]? = nil,
        decoding type: T.Type,
        onProgress: @escaping ([T]) -> Void,
        onComplete: @escaping ([T]) -> Void
    ) async throws {
        
        let request = try await buildRequest(for: url, headers: headers)
        let delegate = createDelegate(
            decodingType: type,
            onProgress: onProgress,
            onComplete: onComplete
        )
        
        try await executeStreamRequest(request: request, delegate: delegate)
    }
    
    // MARK: - Protected Methods (서브클래스에서 오버라이드 가능)
    
    /// 요청 헤더 커스터마이징 (서브클래스에서 오버라이드 가능)
    func customizeRequest(_ request: inout URLRequest) {
        // 기본 구현: 아무것도 하지 않음
        // 서브클래스에서 필요시 오버라이드
    }
    
    // MARK: - Private Methods - Request Building
    
    private func buildRequest(for url: URL, headers: [String: String]?) async throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = Configuration.requestTimeout
        
        // Digest 인증
        if let authHeader = await getAuthorizationHeader(for: url) {
            request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        }
        
        // 추가 헤더
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // 서브클래스 커스터마이징 적용
        customizeRequest(&request)
        
        return request
    }
    
    private func getAuthorizationHeader(for url: URL) async -> String? {
        do {
            try await networkManager.initializeAuthentication()
            return networkManager.getAuthorizationHeader(
                method: "GET",
                url: url.absoluteString,
                body: nil
            )
        } catch {
            print("⚠️ Auth initialization failed: \(error)")
            return nil
        }
    }
    
    // MARK: - Private Methods - Delegate
    
    private func createDelegate<T: Decodable>(
        decodingType: T.Type,
        onProgress: @escaping ([T]) -> Void,
        onComplete: @escaping ([T]) -> Void
    ) -> StreamDownloadDelegate<T> {
        StreamDownloadDelegate(
            decodingType: decodingType,
            onProgress: onProgress,
            onComplete: onComplete
        )
    }
    
    // MARK: - Private Methods - Execution
    
    private func executeStreamRequest<T>(
        request: URLRequest,
        delegate: StreamDownloadDelegate<T>
    ) async throws {
        try await withCheckedThrowingContinuation { continuation in
            delegate.completion = { result in
                continuation.resume(with: result)
            }
            
            // URLSession 생성 (delegate 포함)
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = Configuration.requestTimeout
            configuration.timeoutIntervalForResource = Configuration.resourceTimeout
            
            let session = URLSession(
                configuration: configuration,
                delegate: delegate,
                delegateQueue: nil
            )
            
            let task = session.dataTask(with: request)
            task.resume()
        }
    }
}
