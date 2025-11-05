//
//  SSLPinningDelegate.swift
//  CCAPI_test
//
//  Created by Subeen on 10/1/25.
//

import Foundation

/// URLSession의 SSL 인증서 처리를 위한 Delegate
final class SSLPinningDelegate: NSObject, URLSessionDelegate {
    private var allowedHosts = Set<String>()
    
    func addTrustedHost(_ host: String) {
        allowedHosts.insert(host)
    }
    
    func removeTrustedHost(_ host: String) {
        allowedHosts.remove(host)
    }
    
    func urlSession(_ session: URLSession,
                   didReceive challenge: URLAuthenticationChallenge,
                   completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        Logger.debug("Received authentication challenge", category: .network)
        Logger.debug("Protection space: \(challenge.protectionSpace.authenticationMethod)", category: .network)
        Logger.debug("Host: \(challenge.protectionSpace.host)", category: .network)
        
        // 서버 신뢰 인증 (SSL/TLS)
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            // 허용된 호스트인지 확인
            if allowedHosts.contains(challenge.protectionSpace.host),
               let serverTrust = challenge.protectionSpace.serverTrust {
                Logger.info("Accepting self-signed certificate for host: \(challenge.protectionSpace.host)", category: .network)
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
                return
            }
        }
        
        // 그 외의 경우 기본 처리
        completionHandler(.performDefaultHandling, nil)
    }
}
