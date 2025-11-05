//
//  HTTPDigestAuth.swift
//  CCAPI_test
//
//  Created by Subeen on 10/1/25.
//

import Foundation
import CryptoKit

/// HTTP Digest 인증 헤더를 생성하는 클래스
final class HTTPDigestAuth {
    private let username: String
    private let password: String
    private var wwwAuthHeaderMap: [String: String]?
    private var nonceCount: UInt32 = 0
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    /// Digest 인증 헤더를 생성
    /// - Parameters:
    ///   - method: HTTP 메서드 (GET, POST, PUT 등)
    ///   - url: 요청 URL
    ///   - body: 요청 바디 (optional)
    ///   - wwwAuthHeader: WWW-Authenticate 헤더 (새로운 nonce를 받은 경우에만 전달, 재사용 시 nil)
    /// - Returns: Authorization 헤더 문자열
    func getDigestAuthHeader(method: String, url: String, body: Data?, wwwAuthHeader: String?) -> String? {
        let headerMap: [String: String]
        
        if let wwwAuthHeader = wwwAuthHeader {
            // 첫 번째 인증 또는 새로운 nonce 사용
            headerMap = parseAuthHeader(wwwAuthHeader)
            nonceCount = 1
        } else {
            // 이전 인증 정보 재사용
            guard let savedMap = wwwAuthHeaderMap else { return nil }
            headerMap = savedMap
        }
        
        Logger.debug("NonceCount: \(nonceCount) : \(url)", category: .network)
        
        guard let realm = headerMap["realm"],
              let nonce = headerMap["nonce"] else {
            return nil
        }
        
        let qop = headerMap["qop"]
        let algorithm = headerMap["algorithm"] ?? "MD5"
        let opaque = headerMap["opaque"]
        
        guard let urlComponents = URLComponents(string: url) else {
            return nil
        }
        
        var uri = urlComponents.path.isEmpty ? "/" : urlComponents.path
        
        if let query = urlComponents.query {
            uri += "?\(query)"
        }
        
        let clientNonce = generateClientNonce()
        let nonceCountStr = String(format: "%08x", nonceCount)
        
        // A1 생성: username:realm:password
        var a1 = "\(username):\(realm):\(password)"
        a1 = hashString(a1, algorithm: algorithm)
        
        if algorithm.uppercased().contains("-SESS") {
            a1 = "\(a1):\(nonce):\(clientNonce)"
            a1 = hashString(a1, algorithm: algorithm)
        }
        
        // A2 생성: method:uri
        var a2 = "\(method):\(uri)"
        var selectedQop: String?
        
        if let qop = qop {
            if qop == "auth" {
                selectedQop = qop
            } else if qop == "auth-int", let body = body {
                selectedQop = qop
                let bodyHash = hashData(body, algorithm: algorithm)
                a2 += ":\(bodyHash)"
            } else {
                let qopList = qop.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                if qopList.contains("auth") {
                    selectedQop = "auth"
                } else if qopList.contains("auth-int"), let body = body {
                    selectedQop = "auth-int"
                    let bodyHash = hashData(body, algorithm: algorithm)
                    a2 += ":\(bodyHash)"
                }
            }
        }
        
        a2 = hashString(a2, algorithm: algorithm)
        
        // Response 생성
        var responseStr = "\(a1):\(nonce):"
        
        if let selectedQop = selectedQop {
            responseStr += "\(nonceCountStr):\(clientNonce):\(selectedQop):"
        }
        
        responseStr += a2
        let response = hashString(responseStr, algorithm: algorithm)
        
        // Authorization 헤더 생성
        var header = "Digest "
        header += "username=\"\(username)\", "
        header += "realm=\"\(realm)\", "
        header += "nonce=\"\(nonce)\", "
        header += "uri=\"\(uri)\", "
        
        if !algorithm.isEmpty {
            header += "algorithm=\(algorithm), "
        }
        
        if let opaque = opaque {
            header += "opaque=\"\(opaque)\", "
        }
        
        if let selectedQop = selectedQop {
            header += "nc=\(nonceCountStr), "
            header += "qop=\(selectedQop), "
            header += "cnonce=\"\(clientNonce)\", "
            
            if nonceCount == 0xFFFFFFFF {
                Logger.debug("Next NonceCount: FFFFFFFF -> 00000001", category: .network)
                nonceCount = 1
            } else {
                nonceCount += 1
            }
        }
        
        header += "response=\"\(response)\""
        wwwAuthHeaderMap = headerMap
        
        Logger.debug("Auth Header generated", category: .network)
        return header
    }
    
    /// 서버가 401 에러와 함께 반환한 WWW-Authenticate 헤더 파싱
    private func parseAuthHeader(_ wwwAuthHeader: String) -> [String: String] {
        var headerMap = [String: String]()
        let headerContent = wwwAuthHeader.trimmingCharacters(in: .whitespaces)
        
        guard headerContent.lowercased().hasPrefix("digest ") else {
            return headerMap
        }
        
        let content = String(headerContent.dropFirst(7))
        let components = content.components(separatedBy: ",")
        
        for component in components {
            let parts = component.trimmingCharacters(in: .whitespaces).split(separator: "=", maxSplits: 1)
            if parts.count == 2 {
                let key = String(parts[0]).trimmingCharacters(in: .whitespaces)
                let value = String(parts[1]).trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "\"", with: "")
                headerMap[key] = value
            }
        }
        
        return headerMap
    }
    
    /// 클라이언트 Nonce 생성 (16바이트 랜덤 값)
    private func generateClientNonce() -> String {
        var bytes = [UInt8](repeating: 0, count: 16)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return bytes.map { String(format: "%02x", $0) }.joined()
    }
    
    /// 문자열 해시
    private func hashString(_ string: String, algorithm: String) -> String {
        guard let data = string.data(using: .utf8) else { return "" }
        return hashData(data, algorithm: algorithm)
    }
    
    /// 데이터 해시 (MD5 또는 SHA-256)
    private func hashData(_ data: Data, algorithm: String) -> String {
        let upperAlgorithm = algorithm.uppercased()
        
        if upperAlgorithm.hasPrefix("MD5") {
            return Insecure.MD5.hash(data: data).map { String(format: "%02x", $0) }.joined()
        } else if upperAlgorithm.hasPrefix("SHA-256") {
            return SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
        }
        
        return ""
    }
}
