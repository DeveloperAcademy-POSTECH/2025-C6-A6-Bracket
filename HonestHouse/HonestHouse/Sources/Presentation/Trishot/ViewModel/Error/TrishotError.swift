//
//  TrishotError.swift
//  HonestHouse
//
//  Created by BoMin Lee on 11/4/25.
//

import Foundation

enum TrishotError: LocalizedError, Equatable, AlertPresentable {
    case cameraDisconnected
    case cameraBusy
    case monitoringStartFailed
    case presetApplicationFailed
    case unknown

    var errorDescription: String? {
        alertInfo.title
    }

    var alertInfo: AlertInfo {
        switch self {
        case .cameraDisconnected:
            return AlertInfo(
                title: "카메라 연결이 해제되었습니다.",
                message: "카메라를 다시 연결해주세요."
            )

        case .cameraBusy:
            return AlertInfo(
                title: "카메라가 사용 중입니다.",
                message: "잠시 후 다시 시도해주세요."
            )

        case .monitoringStartFailed:
            return AlertInfo(
                title: "Trishot을 시작할 수 없습니다.",
                message: "카메라 연결을 확인하고 다시 시도해주세요."
            )

        case .presetApplicationFailed:
            return AlertInfo(
                title: "프리셋을 적용하는 과정에서 문제가 발생했습니다.",
                message: "문제가 반복된다면, 앱을 재실행해주세요."
            )

        case .unknown:
            return AlertInfo(
                title: "Tri-shot 실행 중 문제가 발생했습니다.",
                message: "문제가 반복된다면, 앱을 재실행해주세요."
            )
        }
    }
}

extension TrishotError {
    static func fromCCAPI(_ error: CCAPIError) -> TrishotError {
        if error.isDisconnected {
            return .cameraDisconnected
        }

        if error.isTemporarilyBusy {
            return .cameraBusy
        }

        if error.isClientError {
            return .presetApplicationFailed
        }

        switch error {
        case .notAuthenticated, .noWWWAuthenticateHeader,
                .authHeaderGenerationFailed, .maxRetriesExceeded:
            return .cameraDisconnected

        default:
            return .presetApplicationFailed
        }
    }
}
