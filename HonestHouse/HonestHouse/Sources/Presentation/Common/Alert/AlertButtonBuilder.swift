//
//  AlertButtonBuilder.swift
//  HonestHouse
//
//  Created by 이현주 on 11/13/25.
//

import Foundation

@resultBuilder
struct AlertButtonBuilder {
    
    static func buildExpression(_ button: CustomAlertConfig.AlertButton) -> [CustomAlertConfig.AlertButton] {
        [button]
    }
    
    // 버튼 0개 (빈 블록)
    static func buildBlock() -> [CustomAlertConfig.AlertButton] {
        [CustomAlertConfig.AlertButton(title: "확인", style: .default, action: {})]
    }
    
    // 버튼 1개
    static func buildBlock(_ button: CustomAlertConfig.AlertButton) -> [CustomAlertConfig.AlertButton] {
        [button]
    }
    
    // 버튼 2개
    static func buildBlock(
        _ b1: CustomAlertConfig.AlertButton,
        _ b2: CustomAlertConfig.AlertButton
    ) -> [CustomAlertConfig.AlertButton] {
        [b1, b2]
    }
    
    // 버튼 3개
    static func buildBlock(
        _ b1: CustomAlertConfig.AlertButton,
        _ b2: CustomAlertConfig.AlertButton,
        _ b3: CustomAlertConfig.AlertButton
    ) -> [CustomAlertConfig.AlertButton] {
        [b1, b2, b3]
    }
    
    // if 문 지원
    static func buildOptional(_ component: [CustomAlertConfig.AlertButton]?) -> [CustomAlertConfig.AlertButton] {
        component ?? []
    }
    
    // if-else 문 지원
    static func buildEither(first component: [CustomAlertConfig.AlertButton]) -> [CustomAlertConfig.AlertButton] {
        component
    }
    
    static func buildEither(second component: [CustomAlertConfig.AlertButton]) -> [CustomAlertConfig.AlertButton] {
        component
    }
    
    // switch 문 지원
    static func buildArray(_ components: [[CustomAlertConfig.AlertButton]]) -> [CustomAlertConfig.AlertButton] {
        components.flatMap { $0 }
    }
}
