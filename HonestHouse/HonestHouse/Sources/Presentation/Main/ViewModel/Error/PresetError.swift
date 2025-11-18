//
//  PresetError.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/28/25.
//

import Foundation

enum PresetError: LocalizedError, Equatable, AlertPresentable {
    case fetchFailed
    case createFailed
    case updateFailed
    case deleteFailed
    case presetNotFound

    case cameraBusy
    case cameraDisconnected
    case cameraSettingsFetchFailed
    case settingApplicationFailed

    case unknown

    var errorDescription: String? {
        alertInfo.title
    }

    var alertInfo: AlertInfo {
        switch self {
        case .fetchFailed:
            return AlertInfo(
                title: "프리셋을 불러오는데\n문제가 발생했습니다."
            )

        case .createFailed:
            return AlertInfo(
                title: "프리셋을 생성하는데\n문제가 발생했습니다."
            )

        case .updateFailed:
            return AlertInfo(
                title: "프리셋을 업데이트하는데\n문제가 발생했습니다."
            )

        case .deleteFailed:
            return AlertInfo(
                title: "프리셋을 삭제하는데\n문제가 발생했습니다."
            )

        case .presetNotFound:
            return AlertInfo(
                title: "프리셋을 찾을 수 없습니다."
            )

        case .cameraBusy:
            return AlertInfo(
                title: "카메라가 사용 중입니다.",
                message: "잠시 후 다시 시도해주세요."
            )

        case .cameraDisconnected:
            return AlertInfo(
                title: "카메라 연결이 해제되었습니다.",
                message: "카메라를 다시 연결해주세요."
            )

        case .cameraSettingsFetchFailed:
            return AlertInfo(
                title: "현재 카메라 값을 불러오는데\n문제가 발생했습니다."
            )

        case .settingApplicationFailed:
            return AlertInfo(
                title: "프리셋 적용 중\n문제가 발생했습니다.",
                message: "문제가 반복된다면, 앱을 재실행해주세요."
            )

        case .unknown:
            return AlertInfo(
                title: "알 수 없는 문제가 발생했습니다.",
                message: "문제가 반복된다면, 앱을 재실행해주세요."
            )
        }
    }
}

extension PresetError {
    static func fromPresetManager(_ error: PresetManagerError) -> PresetError {
        switch error {
        case .presetNotFound, .selectedPresetNotFound:
            return .presetNotFound
        case .invalidOrder:
            return .unknown
        case .saveFailed:
            return .createFailed
        }
    }

    static func fromCCAPI(_ error: CCAPIError) -> PresetError {
        if error.isDisconnected {
            return .cameraDisconnected
        }

        if error.isTemporarilyBusy {
            return .cameraBusy
        }

        if error.isClientError {
            return .settingApplicationFailed
        }

        switch error {
        case .notAuthenticated, .noWWWAuthenticateHeader,
                .authHeaderGenerationFailed, .maxRetriesExceeded:
            return .cameraDisconnected

        default:
            return .settingApplicationFailed
        }
    }
}
