//
//  KingfisherSSLDelegate.swift
//  HonestHouse
//
//  Created by 이현주 on 11/10/25.
//

import Foundation
import Kingfisher

import Kingfisher

func setupKingfisher() {
    // AuthenticationChallengeResponsable 구현
    let challengeResponder = SSLBypassChallengeResponder()
    
    // ImageDownloader 설정
    ImageDownloader.default.authenticationChallengeResponder = challengeResponder
    ImageDownloader.default.downloadTimeout = 30.0
}

class SSLBypassChallengeResponder: AuthenticationChallengeResponsible {
    func downloader(
        _ downloader: ImageDownloader,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        print("🔐 Challenge received for: \(challenge.protectionSpace.host)")
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           challenge.protectionSpace.host == BaseURLConstants.cameraIP,
           let serverTrust = challenge.protectionSpace.serverTrust {
            print("✅ Accepting certificate for camera")
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            print("⚠️ Using default handling")
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
    func downloader(
        _ downloader: ImageDownloader,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        print("🔐 Task challenge received for: \(challenge.protectionSpace.host)")
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           challenge.protectionSpace.host == BaseURLConstants.cameraIP,
           let serverTrust = challenge.protectionSpace.serverTrust {
            print("✅ Accepting task certificate for camera")
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

