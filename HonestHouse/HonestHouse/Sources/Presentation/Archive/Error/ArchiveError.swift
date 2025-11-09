//
//  ArchiveError.swift
//  HonestHouse
//
//  Created by 이현주 on 11/6/25.
//

import Foundation

/// Archive 기능에서 발생하는 모든 에러 (Selection, Grouping, Saving)
enum ArchiveError: LocalizedError, Equatable, AlertPresentable {
    case cameraBusy
    case cameraDisconnected
    
    case photoLoadingFailed
    case visionAnalysisFailed
    
    case photoPermissionDenied
    case photoProcessingError // 사진 저장 실패 관련으로 바꾸기
    
    // LocalizedError
    var errorDescription: String? {
        alertInfo.title
    }
    
    // AlertPresentable
    var alertInfo: AlertInfo {
        switch self {
        case .cameraBusy:
            return AlertInfo(
                title: "카메라가 이미 사용 중입니다.\n잠시 후에 다시 시도해주세요.",
                message: "카메라가 촬영 중일 때는 아카이빙 기능을 이용할 수 없습니다."
            )
            
        case .cameraDisconnected:
            return AlertInfo(
                title: "카메라와의 연결이 불안정합니다.",
                message: "카메라를 다시 연결해주세요."
            )
            
        case .photoLoadingFailed:
            return AlertInfo(
                title: "이미지를 불러오는데 문제가 발생하였습니다."
            )
            
        case .visionAnalysisFailed:
            return AlertInfo(
                title: "이미지를 분류하는데 오류가 발생하였습니다."
            )
            
        case .photoPermissionDenied:
            return AlertInfo(
                title: "사진 앱 접근 권한을 확인해주세요.",
                message: "설정 → 앱 → Bracket → 사진 → '전체 접근'으로 설정해주세요."
            )
            
        case .photoProcessingError:
            return AlertInfo(
                title: "이미지를 처리하는 과정에서 문제가 발생하였습니다."
            )
        }
    }
}

extension ArchiveError {
    /// CCAPIError → ArchiveError
    static func fromCCAPI(_ error: CCAPIError) -> ArchiveError {
        // 1. 연결 끊김 (최우선)
        if error.isDisconnected {
            return .cameraDisconnected
        }
        
        // 2. 일시적으로 바쁨
        if error.isTemporarilyBusy {
            return .cameraBusy
        }
        
        // 3. 클라이언트 오류 (요청 오류)
        if error.isClientError {
            return .photoLoadingFailed
        }
        
        // 4. 개별 에러 처리
        switch error {
            // 인증 관련
        case .notAuthenticated, .noWWWAuthenticateHeader,
                .authHeaderGenerationFailed, .maxRetriesExceeded:
            return .cameraDisconnected
            
        default:
            return .photoLoadingFailed
        }
    }
    
    
    /// VisionError → ArchiveError
    static func fromVision(_ error: VisionError) -> ArchiveError {
        switch error {
        case .imageFetching, .unknown:
            return .photoLoadingFailed
        case .cgImageConversion, .observation:
            return .visionAnalysisFailed
        }
    }
    
    /// PhotoError → ArchiveError
    static func fromPhoto(_ error: PhotoError) -> ArchiveError {
        switch error {
        case .authorizationDenied, .authorizationRestricted:
            return .photoPermissionDenied
        case .albumCreationFailed, .photoSaveFailed, .imageURLInvalid, .imageDataMissing, .unknown:
            return .photoProcessingError
        }
    }
}

