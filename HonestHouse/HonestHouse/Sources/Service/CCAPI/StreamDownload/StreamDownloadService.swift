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
class StreamDownloadService: BaseStreamService {
    
    static let shared = StreamDownloadService()
    
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
        
        let request = await createAuthenticatedRequest(
            url: url,
            method: "GET",
            headers: headers
        )
        
        let config = createSessionConfiguration()
        
        let delegate = StreamDownloadDelegate(
            decodingType: T.self,
            onProgress: onProgress,
            onComplete: onComplete,
            sslHandler: handleSSLChallenge
        )
        
        let session = URLSession(
            configuration: config,
            delegate: delegate,
            delegateQueue: nil
        )
        
        // Continuation으로 async/await 지원
        try await withCheckedThrowingContinuation { continuation in
            delegate.completion = { result in
                continuation.resume(with: result)
            }
            
            let task = session.dataTask(with: request)
            task.resume()
        }
        
        session.invalidateAndCancel()
    }
}
