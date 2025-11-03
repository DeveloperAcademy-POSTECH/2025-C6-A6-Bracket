//
//  GroupingError.swift
//  HonestHouse
//
//  Created by Rama on 10/26/25.
//

import Foundation

enum GroupingError: Error, LocalizedError {
     case imageLoadingFailed
     case imageAnalysisFailed
     case partialAnalysis(failedCount: Int) /// 일부 이미지 실패 시
     case unknown

     var errorDescription: String? {
         switch self {
         case .imageLoadingFailed: return "이미지를 불러오는 데 실패했습니다. 네트워크 연결을 확인해주세요."
         case .imageAnalysisFailed: return "이미지 분석 중 오류가 발생했습니다. 다시 시도해주세요."
         case .partialAnalysis(let count): return "일부 이미지(\(count)개) 분석에 실패했습니다. 나머지 이미지는 정상적으로 처리되었습니다."
         case .unknown: return "알 수 없는 오류가 발생했습니다. 다시 시도해주세요."
         }
     }
 }

extension GroupingError: Equatable {
    static func from(visionError: VisionError) -> GroupingError {
        switch visionError {
        case .imageFetching(url: _, underlyingError: _):
            return .imageLoadingFailed
        case .cgImageConversion(url: _), .observation(url: _):
            return .imageAnalysisFailed
        case .partialAnalysis(failedPhotos: let failedPhotos, errors: _):
            return .partialAnalysis(failedCount: failedPhotos.count)
        case .unknown:
            return .unknown
        }
    }
}
