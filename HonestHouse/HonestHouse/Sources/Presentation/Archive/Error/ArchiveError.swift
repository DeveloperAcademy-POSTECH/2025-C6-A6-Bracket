//
//  ArchiveError.swift
//  HonestHouse
//
//  Created by Claude on 11/6/25.
//

import Foundation

/// Archive 기능에서 발생하는 모든 에러 (Selection, Grouping, Saving)
enum ArchiveError: Error, AlertPresentable, Equatable {
    // Selection Errors
    case cameraBusy
    case cameraDisconnected
    case photoLoadFailed

    // Grouping Errors
    case imageLoadingFailed
    case visionAnalysisFailed
    case partialAnalysisFailed(failedCount: Int)

    // Saving Errors
    case photoPermissionDenied
    case photoPermissionRestricted
    case albumCreationFailed
    case photoSaveFailed(failedCount: Int)
    case imageDataInvalid

    // General
    case unknown

    var alertInfo: AlertInfo {
        switch self {
        // MARK: Selection
        case .cameraBusy:
            return AlertInfo(
                title: "카메라 사용 중",
                message: "카메라가 사용 중입니다. 잠시 후 다시 시도해주세요."
            )

        case .cameraDisconnected:
            return AlertInfo(
                title: "카메라 연결 끊김",
                message: "카메라 연결이 불안정합니다. 다시 연결해주세요."
            )

        case .photoLoadFailed:
            return AlertInfo(
                title: "사진 불러오기 실패",
                message: "사진을 불러오는 중 오류가 발생했습니다. 네트워크 연결을 확인해주세요."
            )

        // MARK: Grouping
        case .imageLoadingFailed:
            return AlertInfo(
                title: "이미지 로딩 실패",
                message: "이미지를 불러오는 데 실패했습니다. 네트워크 연결을 확인해주세요."
            )

        case .visionAnalysisFailed:
            return AlertInfo(
                title: "분석 실패",
                message: "이미지 분석 중 오류가 발생했습니다. 다시 시도해주세요."
            )

        case .partialAnalysisFailed(let failedCount):
            return AlertInfo(
                title: "일부 분석 실패",
                message: "일부 이미지(\(failedCount)개) 분석에 실패했습니다.\n나머지 이미지는 정상적으로 처리되었습니다."
            )

        // MARK: Saving
        case .photoPermissionDenied:
            return AlertInfo(
                title: "권한 필요",
                message: "사진 앱 접근 권한이 거부되었습니다.\n설정에서 권한을 허용해주세요."
            )

        case .photoPermissionRestricted:
            return AlertInfo(
                title: "권한 제한됨",
                message: "사진 앱 접근이 제한되었습니다.\n기기 설정을 확인해주세요."
            )

        case .albumCreationFailed:
            return AlertInfo(
                title: "앨범 생성 실패",
                message: "앨범 생성에 실패했습니다. 다시 시도해주세요."
            )

        case .photoSaveFailed(let failedCount):
            return AlertInfo(
                title: "저장 실패",
                message: "\(failedCount)개의 사진을 저장하는 데 실패했습니다.\n다시 시도해주세요."
            )

        case .imageDataInvalid:
            return AlertInfo(
                title: "이미지 데이터 오류",
                message: "이미지 데이터를 가져오는 데 실패했습니다."
            )

        // MARK: General
        case .unknown:
            return AlertInfo(
                title: "오류 발생",
                message: "알 수 없는 오류가 발생했습니다. 다시 시도해주세요."
            )
        }
    }
}

// MARK: - Conversion from Foundation/Domain Errors

extension ArchiveError {
    /// CCAPIError → ArchiveError (Selection 단계)
    static func fromCCAPI(_ error: CCAPIError) -> ArchiveError {
        switch error {
        case .deviceUnavailable:
            return .cameraBusy
        case .invalidResponse, .unexpectedStatusCode, .urlNotFound, .badRequest:
            return .photoLoadFailed
        default:
            return .cameraDisconnected
        }
    }

    /// VisionError → ArchiveError (Grouping 단계)
    static func fromVision(_ error: VisionError) -> ArchiveError {
        switch error {
        case .imageFetching:
            return .imageLoadingFailed
        case .cgImageConversion, .observation:
            return .visionAnalysisFailed
        case .partialAnalysis(let failedPhotos, _):
            return .partialAnalysisFailed(failedCount: failedPhotos.count)
        case .unknown:
            return .unknown
        }
    }

    /// PhotoError → ArchiveError (Saving 단계)
    static func fromPhoto(_ error: PhotoError) -> ArchiveError {
        switch error {
        case .authorizationDenied:
            return .photoPermissionDenied
        case .authorizationRestricted:
            return .photoPermissionRestricted
        case .albumCreationFailed:
            return .albumCreationFailed
        case .photoSaveFailed:
            return .photoSaveFailed(failedCount: 1)
        case .imageURLInvalid, .imageDataMissing:
            return .imageDataInvalid
        case .unknown:
            return .unknown
        }
    }
}
