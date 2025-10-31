//
//  NetworkManager.swift
//  CCAPI_test
//
//  Created by Subeen on 10/6/25.
//

import Foundation
import Moya
import Alamofire

/// 네트워크 통신 관리
class NetworkManager {
    
    static let shared = NetworkManager()
    
    private var authManager: DigestAuthManager?
    private var authPlugin: DigestAuthPlugin?
    private var session: Session?
    private let maxAuthRetries = 3
    
    /// Moya Provider
    private var provider: MoyaProvider<MultiTarget>? {
        guard let session = session,
              let authPlugin = authPlugin else {
            return nil
        }
        
        return MoyaProvider<MultiTarget>(
            session: session,
            plugins: [authPlugin]
        )
    }
    
    private init() {}
    
    // MARK: - Initialization
    
    func configure(cameraIP: String,
                   port: Int,
                   username: String = "",
                   password: String = "") {
        
        // SSL 델리게이트 생성
        let sslDelegate = SSLPinningDelegate()
        sslDelegate.addTrustedHost(cameraIP)
        
        // baseURL 생성
        let baseURL = "https://\(cameraIP):\(port)/ccapi"
        
        // DigestAuthManager 생성
        self.authManager = DigestAuthManager(
            baseURL: baseURL,
            username: username,
            password: password,
            sslDelegate: sslDelegate
        )
        
        // DigestAuthPlugin 생성
        if let authManager = authManager {
            self.authPlugin = DigestAuthPlugin(authManager: authManager)
        }
        
        // Alamofire Session 생성
        let serverTrustManager = ServerTrustManager(
            evaluators: [cameraIP: DisabledTrustEvaluator()]
        )
        
        self.session = Session(
            configuration: .default,
            serverTrustManager: serverTrustManager
        )
    }
    
    // MARK: - Public Methods
    
    /// 초기 인증 (401 응답 받아서 nonce 획득)
    func initializeAuthentication() async throws {
        guard let authManager else { throw CCAPIError.notConfigured }
        try await authManager.authenticate()
    }
    
    /// API 요청 (Android WebAPI.executeRequest와 동일한 로직)
    /// Android의 while(!isInterrupted) 루프와 동일하게 401 재시도 처리
    func request<T: TargetType>(_ target: T) async throws -> Response {
        
        guard let provider = provider else {
            throw CCAPIError.notConfigured
        }
        
        var authErrorCount = 0
        
        // Android의 while(true) 루프와 동일
        while true {
            do {
                let response = try await requestOnce(target, provider: provider)
                
                // 401 처리 (Android HttpCommunication.sendRequest와 동일)
                if response.statusCode == 401 {
                    authErrorCount += 1
                    
                    // Android: if(authErrorCount < MAX_AUTH_ERROR) continue;
                    if authErrorCount < maxAuthRetries {
                        print("⚠️ 401 received, retrying... (\(authErrorCount)/\(maxAuthRetries))")
                        // DigestAuthPlugin.process()가 이미 nonce를 갱신했음
                        // Android처럼 바로 continue로 재시도
                        continue
                    } else {
                        print("❌ Max auth retries exceeded")
                        throw CCAPIError.authenticationFailed(401)
                    }
                }
                
                // 401이 아닌 응답은 그대로 반환
                return response
            } catch let error as MoyaError {
                if case .statusCode(let response) = error, response.statusCode == 401 {
                    authErrorCount += 1
                    if authErrorCount < maxAuthRetries {
                        print("⚠️ 401(MoyaError) received, retrying... (\(authErrorCount)/\(maxAuthRetries))")
                        continue
                    } else {
                        print("❌ Max auth retries exceeded")
                        throw CCAPIError.authenticationFailed(401)
                    }
                }
                throw error
            }
        }
    }
    
    /// Authorization 헤더 생성 (외부에서 사용 가능)
    func getAuthorizationHeader(method: String, url: String, body: Data?) -> String? {
        return authManager?.getAuthorizationHeader(
            method: method,
            url: url,
            body: body
        )
    }
    
    /// 인증 리셋
    func resetAuthentication() {
        authManager?.reset()
    }

    /// Digest Auth 헤더 가져오기 (Event Monitoring 등 스트리밍용)
    func getAuthorizationHeader(method: String, url: String, body: Data? = nil) -> String? {
        return authManager?.getAuthorizationHeader(method: method, url: url, body: body)
    }
    
    func getAuthorizationHeader(
        method: String,
        url: String,
        body: Data? = nil
    ) -> String? {
        return authManager?.getAuthorizationHeader(
            method: method,
            url: url,
            body: body
        )
    }
    
    // MARK: - Private Methods
    
    private func requestOnce<T: TargetType>(_ target: T, provider: MoyaProvider<MultiTarget>) async throws -> Response {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(MultiTarget(target)) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}


extension CCAPIError {
    static let notConfigured = CCAPIError.authenticationFailed(-1)
}
