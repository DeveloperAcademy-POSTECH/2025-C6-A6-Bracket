//
//  AlertInfo.swift
//  HonestHouse
//
//  Created by 이현주 on 11/6/25.
//

import Foundation

/// Alert에 표시될 정보를 담는 구조체
struct AlertInfo {
    let title: String
    let message: String

    init(title: String, message: String) {
        self.title = title
        self.message = message
    }
}
