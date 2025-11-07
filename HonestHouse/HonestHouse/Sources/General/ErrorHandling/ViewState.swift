//
//  ViewState.swift
//  HonestHouse
//
//  Created by Claude on 11/6/25.
//

import Foundation

/// 뷰의 상태를 나타내는 제네릭 enum
enum ViewState<Success: Equatable, Failure: Error & Equatable>: Equatable {
    case idle                                    // 초기 상태
    case loading(progress: Double? = nil)        // 로딩 중 (선택적 progress)
    case success(Success)                        // 성공
    case failure(Failure)                        // 실패

    /// 현재 로딩 중인지 여부
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    /// 성공 데이터 가져오기
    var successValue: Success? {
        if case .success(let value) = self { return value }
        return nil
    }

    /// 실패 에러 가져오기
    var failureError: Failure? {
        if case .failure(let error) = self { return error }
        return nil
    }
}
