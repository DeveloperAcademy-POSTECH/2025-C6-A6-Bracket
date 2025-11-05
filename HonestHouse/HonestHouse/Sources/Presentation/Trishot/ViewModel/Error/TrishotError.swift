//
//  TrishotError.swift
//  HonestHouse
//
//  Created by BoMin Lee on 11/4/25.
//

import Foundation

enum TrishotError: Error, LocalizedError {
    // MARK: - Preset Loading Errors
    case noPresetsSelected
    case insufficientPresets
    case presetLoadFailed
    case presetToggleFailed
    case noDeactivatedPresetAvailable

    // MARK: - Monitoring Errors
    case monitoringStartFailed
    case monitoringStopFailed
    case monitoringAlreadyActive

    // MARK: - Preset Application Errors
    case presetApplicationFailed(presetName: String)
    case invalidPresetIndex
    case shootingModeIgnoreFailed
    case shootingModeSetFailed
    case pictureStyleSetFailed
    case apertureSetFailed
    case shutterSpeedSetFailed
    case isoSetFailed
    case exposureCompensationSetFailed
    case colorTemperatureSetFailed
    case wbShiftSetFailed

    // MARK: - Camera Errors
    case cameraNotConnected
    case cameraBusy

    // MARK: - General
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        // Preset Loading Errors
        case .noPresetsSelected:
            return "선택된 프리셋이 없습니다. 프리셋을 선택해주세요."
        case .insufficientPresets:
            return "최소 2개의 프리셋이 필요합니다."
        case .presetLoadFailed:
            return "프리셋을 불러오는 데 실패했습니다."
        case .presetToggleFailed:
            return "프리셋 활성화 상태를 변경하는 데 실패했습니다."
        case .noDeactivatedPresetAvailable:
            return "활성화할 수 있는 프리셋이 없습니다."

        // Monitoring Errors
        case .monitoringStartFailed:
            return "이벤트 모니터링을 시작할 수 없습니다."
        case .monitoringStopFailed:
            return "이벤트 모니터링을 중지하는 데 실패했습니다."
        case .monitoringAlreadyActive:
            return "이미 모니터링이 실행 중입니다."

        // Preset Application Errors
        case .presetApplicationFailed(let presetName):
            return "'\(presetName)' 프리셋 적용에 실패했습니다."
        case .invalidPresetIndex:
            return "잘못된 프리셋 인덱스입니다."
        case .shootingModeIgnoreFailed:
            return "촬영 모드 무시 설정에 실패했습니다."
        case .shootingModeSetFailed:
            return "촬영 모드 설정에 실패했습니다."
        case .pictureStyleSetFailed:
            return "픽쳐 스타일 설정에 실패했습니다."
        case .apertureSetFailed:
            return "조리개 값 설정에 실패했습니다."
        case .shutterSpeedSetFailed:
            return "셔터 스피드 설정에 실패했습니다."
        case .isoSetFailed:
            return "ISO 설정에 실패했습니다."
        case .exposureCompensationSetFailed:
            return "노출 보정 설정에 실패했습니다."
        case .colorTemperatureSetFailed:
            return "색온도 설정에 실패했습니다."
        case .wbShiftSetFailed:
            return "화이트 밸런스 틴트 설정에 실패했습니다."

        // Camera Errors
        case .cameraNotConnected:
            return "카메라가 연결되어 있지 않습니다."
        case .cameraBusy:
            return "카메라가 사용 중입니다. 잠시 후 다시 시도해주세요."

        // General
        case .unknown(let error):
            return "알 수 없는 오류가 발생했습니다: \(error.localizedDescription)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .noPresetsSelected, .insufficientPresets:
            return "프리셋 선택 화면에서 최소 2개의 프리셋을 선택해주세요."
        case .monitoringStartFailed, .monitoringStopFailed:
            return "카메라 연결을 확인하고 다시 시도해주세요."
        case .cameraNotConnected:
            return "카메라를 연결한 후 다시 시도해주세요."
        case .cameraBusy:
            return "잠시 후 다시 시도해주세요."
        default:
            return "문제가 지속되면 카메라를 재시작하고 다시 연결해주세요."
        }
    }
}

extension TrishotError: Equatable {
    static func == (lhs: TrishotError, rhs: TrishotError) -> Bool {
        switch (lhs, rhs) {
        case (.noPresetsSelected, .noPresetsSelected),
             (.insufficientPresets, .insufficientPresets),
             (.presetLoadFailed, .presetLoadFailed),
             (.presetToggleFailed, .presetToggleFailed),
             (.noDeactivatedPresetAvailable, .noDeactivatedPresetAvailable),
             (.monitoringStartFailed, .monitoringStartFailed),
             (.monitoringStopFailed, .monitoringStopFailed),
             (.monitoringAlreadyActive, .monitoringAlreadyActive),
             (.invalidPresetIndex, .invalidPresetIndex),
             (.shootingModeIgnoreFailed, .shootingModeIgnoreFailed),
             (.shootingModeSetFailed, .shootingModeSetFailed),
             (.pictureStyleSetFailed, .pictureStyleSetFailed),
             (.apertureSetFailed, .apertureSetFailed),
             (.shutterSpeedSetFailed, .shutterSpeedSetFailed),
             (.isoSetFailed, .isoSetFailed),
             (.exposureCompensationSetFailed, .exposureCompensationSetFailed),
             (.colorTemperatureSetFailed, .colorTemperatureSetFailed),
             (.wbShiftSetFailed, .wbShiftSetFailed),
             (.cameraNotConnected, .cameraNotConnected),
             (.cameraBusy, .cameraBusy):
            return true
        case (.presetApplicationFailed(let lhsName), .presetApplicationFailed(let rhsName)):
            return lhsName == rhsName
        default:
            return false
        }
    }

    static func from(ccapiError: CCAPIError) -> TrishotError {
        switch ccapiError {
        case .deviceUnavailable:
            return .cameraBusy
        case .invalidURL, .notAuthenticated, .authenticationFailed, .maxRetriesExceeded, .noWWWAuthenticateHeader, .authHeaderGenerationFailed:
            return .cameraNotConnected
        case .invalidResponse, .unexpectedStatusCode, .badRequest, .urlNotFound, .httpError:
            return .cameraBusy
        case .decodingFailed:
            return .unknown(ccapiError)
        }
    }
}
