//
//  DigestAuthPlugin.swift
//  CCAPI_test
//
//  Created by Subeen on 10/7/25.
//

import Foundation
import Moya

/// Moya Plugin으로 Digest 인증 처리
final class DigestAuthPlugin: PluginType {
    private let authManager: DigestAuthManager
    
    init(authManager: DigestAuthManager) {
        self.authManager = authManager
    }
    
    /// 요청 전 Authorization 헤더 추가
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        
        if let url = request.url?.absoluteString,
           let method = request.httpMethod,
           let authHeader = authManager.getAuthorizationHeader(
                method: method,
                url: url,
                body: request.httpBody
           ) {
            request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    /// 401 응답 처리
    func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        guard case .success(let response) = result,
              response.statusCode == 401,
              let request = response.request,
              let url = request.url?.absoluteString,
              let method = request.httpMethod,
              let httpResponse = response.response else {
            return result
        }
        
        // nonce 갱신
        _ = authManager.updateNonce(
            from: httpResponse,
            method: method,
            url: url,
            body: request.httpBody
        )
        
        // nonce 갱신하고, 응답은 그대로 반환 (재시도는 상위에서 처리)
        return result
    }
}
