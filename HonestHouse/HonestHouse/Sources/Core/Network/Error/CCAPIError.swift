//
//  CCAPIError.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

import Foundation

enum CCAPIError: LocalizedError {
    // Network Errors
    case networkError(URLError)
    
    // Authentication Errors
    case invalidURL
    case invalidResponse
    case noWWWAuthenticateHeader
    case authHeaderGenerationFailed
    case authenticationFailed(Int)          // 401
    case notAuthenticated
    case maxRetriesExceeded
    
    // HTTP Client Errors
    case badRequest(String)                 // 400
    case accessForbidden                    // 403
    case urlNotFound                        // 404
    case methodNotAllowed                   // 405
    case conflict(String)                   // 409
    case rangeNotSatisfiable                // 416
    
    // HTTP Server Errors
    case internalError                      // 500
    case serviceUnavailable(String)         // 503 (통합)
    
    // 503의 세부 케이스 (선택적 - 더 구체적인 처리가 필요한 경우)
    case deviceBusy(String)                 // "Device busy"
    case deviceShooting(String)             // "During shooting or recording"
    case modeNotSupported(String)           // "Mode not supported"
    case servicePreparation                 // "Taken in preparation"
    case liveViewNotStarted                 // "Live view not started"
    case alreadyStarted                     // "Already started"
    case outOfFocus                         // "Out of focus"
    case cannotWriteToCard                  // "Can not write to card"
    
    // Other
    case decodingFailed(String)
    case httpError(Int)
    case unexpectedStatusCode(Int)
    case unknown(Error)
    
    // Computed Properties
    /// 카메라 연결이 완전히 끊김
    var isDisconnected: Bool {
        switch self {
        case .networkError(let urlError):
            return [
                .notConnectedToInternet,
                .cannotConnectToHost,
                .networkConnectionLost,
                .timedOut
            ].contains(urlError.code)
        case .authenticationFailed:
            return true
        case .accessForbidden:
            return true
        default:
            return false
        }
    }
    
    /// 카메라가 일시적으로 바쁨
    var isTemporarilyBusy: Bool {
        switch self {
        case .networkError(let urlError):
            return urlError.code == .timedOut
        case .serviceUnavailable, .deviceBusy, .deviceShooting,
             .modeNotSupported, .servicePreparation, .conflict:
            return true
        default:
            return false
        }
    }
    
    /// 클라이언트 요청 오류 (재시도 불필요)
    var isClientError: Bool {
        switch self {
        case .badRequest, .urlNotFound, .methodNotAllowed,
             .rangeNotSatisfiable, .accessForbidden:
            return true
        default:
            return false
        }
    }
    
    // LocalizedError
    var errorDescription: String? {
        switch self {
        // Network Errors
        case .networkError(let urlError):
            switch urlError.code {
            case .notConnectedToInternet:
                return "인터넷 연결이 끊겼습니다"
            case .cannotConnectToHost:
                return "카메라에 연결할 수 없습니다"
            case .networkConnectionLost:
                return "네트워크 연결이 끊겼습니다"
            case .timedOut:
                return "연결 시간이 초과되었습니다"
            default:
                return "네트워크 오류가 발생했습니다: \(urlError.localizedDescription)"
            }
            
        // Authentication
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid HTTP response"
        case .noWWWAuthenticateHeader:
            return "No WWW-Authenticate header found"
        case .authHeaderGenerationFailed:
            return "Failed to generate auth header"
        case .authenticationFailed(let code):
            return "카메라 인증에 실패했습니다 (코드: \(code))"
        case .notAuthenticated:
            return "인증이 필요합니다"
        case .maxRetriesExceeded:
            return "최대 재시도 횟수를 초과했습니다"
            
        // HTTP Client Errors
        case .badRequest(let message):
            return "잘못된 요청입니다: \(message)"
        case .accessForbidden:
            return "카메라 접근이 거부되었습니다"
        case .urlNotFound:
            return "URL을 찾을 수 없습니다"
        case .methodNotAllowed:
            return "허용되지 않은 메서드입니다"
        case .conflict(let message):
            return "리소스 충돌이 발생했습니다: \(message)"
        case .rangeNotSatisfiable:
            return "범위가 유효하지 않습니다"
            
        // HTTP Server Errors
        case .internalError:
            return "카메라 내부 오류가 발생했습니다"
        case .serviceUnavailable(let message):
            return "카메라 서비스를 사용할 수 없습니다: \(message)"
            
        // 503 세부
        case .deviceBusy(let message):
            return "카메라가 사용 중입니다: \(message)"
        case .deviceShooting(let message):
            return "카메라가 촬영/녹화 중입니다: \(message)"
        case .modeNotSupported(let message):
            return "현재 모드에서 지원되지 않습니다: \(message)"
        case .servicePreparation:
            return "서비스 준비 중입니다"
        case .liveViewNotStarted:
            return "라이브뷰가 시작되지 않았습니다"
        case .alreadyStarted:
            return "이미 시작되었습니다"
        case .outOfFocus:
            return "포커스에 실패했습니다"
        case .cannotWriteToCard:
            return "메모리 카드에 기록할 수 없습니다"
            
        // Other
        case .decodingFailed(let message):
            return "데이터 변환 실패: \(message)"
        case .httpError(let code):
            return "HTTP 오류 (코드: \(code))"
        case .unexpectedStatusCode(let code):
            return "예상치 못한 상태 코드: \(code)"
        case .unknown(let error):
            return "알 수 없는 오류: \(error.localizedDescription)"
        }
    }
}
