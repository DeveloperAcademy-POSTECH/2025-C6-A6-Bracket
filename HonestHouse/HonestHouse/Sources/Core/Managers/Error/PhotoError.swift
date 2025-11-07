//
//  PhotoError.swift
//  HonestHouse
//
//  Created by Rama on 10/27/25.
//

import Foundation

enum PhotoError: LocalizedError {
    case authorizationDenied
    case authorizationRestricted
    case albumCreationFailed
    case photoSaveFailed(Error)
    case imageURLInvalid
    case imageDataMissing
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return "사진 앱 접근 권한이 거부되었습니다. 설정에서 권한을 허용해주세요."
        case .authorizationRestricted:
            return "사진 앱 접근이 제한되었습니다."
        case .albumCreationFailed:
            return "앨범 생성에 실패했습니다."
        case .photoSaveFailed(let error):
            return "사진 저장에 실패했습니다: \(error.localizedDescription)"
        case .imageURLInvalid:
            return "이미지 URL이 유효하지 않습니다."
        case .imageDataMissing:
            return "이미지 데이터를 가져오는 데 실패했습니다."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}
