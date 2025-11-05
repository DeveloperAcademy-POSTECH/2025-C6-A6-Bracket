//
//  SelectionError.swift
//  HonestHouse
//
//  Created by 이현주 on 10/27/25.
//

import Foundation

enum SelectionError: Error, LocalizedError {
    case cameraBusy          // 카메라 사용 중, 일시적 기능 사용 불가
    case cameraShooting      // 촬영/녹화 진행 중
    case cameraUnavailable   // 카메라 연결 문제
    case generic             // 기타 오류
    
    var errorDescription: String? {
        switch self {
        case .cameraBusy:
            return "카메라가 사용 중입니다. 잠시 후 다시 시도해주세요."
        case .cameraShooting:
            return "카메라가 촬영 중입니다. 촬영이 완료될 때까지 기다려주세요."
        case .cameraUnavailable:
            return "카메라 연결이 불안정합니다. 다시 연결해주세요."
        case .generic:
            return "사진을 불러오는 중 오류가 발생했습니다."
        }
    }
}

extension SelectionError: Equatable {
    static func from(_ error: Error) -> SelectionError {
        if let ccapiError = error as? CCAPIError {
            switch ccapiError {
            case .deviceBusy:
                return .cameraBusy
            case .deviceShooting:
                return .cameraShooting
            case .invalidResponse, .unexpectedStatusCode, .urlNotFound, .badRequest:
                return .generic
            default:
                return .cameraUnavailable
            }
        }
        return .cameraUnavailable
    }
}
