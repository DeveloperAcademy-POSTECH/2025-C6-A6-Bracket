//
//  AlertPresentable.swift
//  HonestHouse
//
//  Created by Claude on 11/6/25.
//

import Foundation

/// 사용자에게 Alert으로 표시될 수 있는 에러
protocol AlertPresentable: Error {
    /// Alert에 표시될 정보 (title, message, actions)
    var alertInfo: AlertInfo { get }
}
