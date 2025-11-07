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
final class NetworkManager {
    static let shared = NetworkManager()
    
    private var authManager: DigestAuthManager?
    private var authPlugin: DigestAuthPlugin?
    private var session: Session?
    private let maxAuthRetries = 3
    
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
    
    func configure(cameraIP: String,
                   username: String = "",
                   password: String = "") {
        
        // SSL 델리게이트 생성
        let sslDelegate = SSLPinningDelegate()
        sslDelegate.addTrustedHost(cameraIP)
        
        let baseURL = BaseURLConstants.baseURL
        
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
                        Logger.warning("401 received, retrying... (\(authErrorCount)/\(maxAuthRetries))", category: .network)
                        // DigestAuthPlugin.process()가 이미 nonce를 갱신했음
                        // Android처럼 바로 continue로 재시도
                        continue
                    } else {
                        Logger.error("Max auth retries exceeded", category: .network)
                        throw CCAPIError.authenticationFailed(401)
                    }
                }
                
                // 다른 http 에러 검증
                try validateResponse(response)
                
                return response
                
            } catch let error as CCAPIError {
                throw error
            } catch let error as MoyaError {
                if case .statusCode(let response) = error, response.statusCode == 401 {
                    authErrorCount += 1
                    if authErrorCount < maxAuthRetries {
                        Logger.warning("401(MoyaError) received, retrying... (\(authErrorCount)/\(maxAuthRetries))", category: .network)
                        continue
                    } else {
                        Logger.error("Max auth retries exceeded", category: .network)
                        throw CCAPIError.authenticationFailed(401)
                    }
                }
                
                // 다른 MoyaError 변환
                throw handleMoyaError(error)
            } catch let urlError as URLError {
                // URLError 변환
                Logger.error("URLError: \(urlError.localizedDescription)", category: .network)
                throw CCAPIError.networkError(urlError)
            } catch {
                // 예상 못한 에러
                Logger.error("Unexpected error: \(error)", category: .network)
                throw CCAPIError.unknown(error)
            }
        }
    }
    
    /// Response를 CCAPIError로 변환
    private func convertToCCAPIError(_ response: Response) -> CCAPIError {
        let errorMessage = try? response.map(CCAPIErrorResponse.self).message
        
        switch response.statusCode {
        case 400: return .badRequest(errorMessage ?? "Bad Request")
        case 401: return .authenticationFailed(401)
        case 403: return .accessForbidden
        case 404: return .urlNotFound
        case 405: return .methodNotAllowed
        case 409: return .conflict(errorMessage ?? "Conflict")
        case 416: return .rangeNotSatisfiable
        case 500: return .internalError
        case 503: return parse503Error(message: errorMessage)
        default: return .httpError(response.statusCode)
        }
    }

    /// HTTP 응답 검증
    private func validateResponse(_ response: Response) throws {
        guard !(200...299).contains(response.statusCode) else {
            return  // 성공
        }
        throw convertToCCAPIError(response)  // 실패
    }

    /// Response를 CCAPIError로 변환 (throws 버전)
    private func validateResponseError(_ response: Response) throws -> CCAPIError {
        return convertToCCAPIError(response)
    }
    
    /// 503 Service Unavailable 메시지 파싱
    private func parse503Error(message: String?) -> CCAPIError {
        guard let message = message else {
            return .serviceUnavailable("Service Unavailable")
        }
        
        // CCAPI 공식 문서의 503 메시지들
        switch message {
        case "Device busy":
            return .deviceBusy(message)
        case "During shooting or recording":
            return .deviceShooting(message)
        case "Mode not supported":
            return .modeNotSupported(message)
        case "Taken in preparation":
            return .servicePreparation
        case "Live view not started":
            return .liveViewNotStarted
        case "Already started":
            return .alreadyStarted
        case "Out of focus":
            return .outOfFocus
        case "Can not write to card":
            return .cannotWriteToCard
        default:
            return .serviceUnavailable(message)
        }
    }
    
    /// MoyaError를 CCAPIError로 변환
    private func handleMoyaError(_ error: MoyaError) -> CCAPIError {
        switch error {
        case .underlying(let nsError as URLError, _):
            // URLError 추출
            Logger.error("Network error: \(nsError.localizedDescription)", category: .network)
            return .networkError(nsError)
            
        case .statusCode(let response):
            // HTTP 에러 응답 (validateResponse에서 이미 처리되었을 것)
            if let validatedError = try? validateResponseError(response) {
                return validatedError
            }
            return .httpError(response.statusCode)
            
        case .objectMapping(let error, _):
            return .decodingFailed(error.localizedDescription)
            
        case .encodableMapping(let error):
            return .decodingFailed(error.localizedDescription)
            
        default:
            Logger.error("Moya error: \(error)", category: .network)
            return .unknown(error)
        }
    }
    
    /// 인증 리셋
    func resetAuthentication() {
        authManager?.reset()
    }
    
    /// Digest Auth 헤더 가져오기 (Event Monitoring 등 스트리밍용)
    func getAuthorizationHeader(method: String, url: String, body: Data? = nil) -> String? {
        return authManager?.getAuthorizationHeader(method: method, url: url, body: body)
    }
    
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

struct CCAPIErrorResponse: Decodable {
    let message: String
}
