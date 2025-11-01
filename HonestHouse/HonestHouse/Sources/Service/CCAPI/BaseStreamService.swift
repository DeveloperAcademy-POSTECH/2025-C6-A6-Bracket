//
//  BaseStreamService.swift
//  HonestHouse
//
//  Created by 이현주 on 11/1/25.
//

import Foundation

/// 스트리밍 서비스의 공통 기능을 제공하는 Base 클래스
class BaseStreamService {
    
    // MARK: - Properties
    
    private let networkManager: NetworkManager = NetworkManager.shared
    
    // MARK: - Protected Methods (서브클래스에서 사용)
    
    /// URLSession 설정 생성
    func createSessionConfiguration() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = .infinity
        config.timeoutIntervalForResource = .infinity
        config.waitsForConnectivity = true
        return config
    }
    
    /// 인증 헤더 가져오기
    func getAuthorizationHeader(for url: URL, method: String) async -> String? {
        do {
            try await networkManager.initializeAuthentication()
        } catch {
            print("⚠️ Auth initialization failed: \(error)")
            return nil
        }
        
        return networkManager.getAuthorizationHeader(
            method: method,
            url: url.absoluteString,
            body: nil
        )
    }
    
    /// URLRequest 생성 (인증 포함)
    func createAuthenticatedRequest(
        url: URL,
        method: String,
        headers: [String: String]? = nil
    ) async -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        // 인증 헤더
        if let authHeader = await getAuthorizationHeader(for: url, method: method) {
            request.setValue(authHeader, forHTTPHeaderField: "Authorization")
            print("🔑 Authorization header added")
        } else {
            print("⚠️ No Authorization header")
        }
        
        // 추가 헤더
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
    
    /// SSL Challenge 처리
    func handleSSLChallenge(
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
