//
//  AlertButtonBuilder.swift
//  HonestHouse
//
//  Created by 이현주 on 11/13/25.
//

import Foundation

@resultBuilder
struct AlertButtonBuilder {
    // 개별 버튼을 배열로 변환
    static func buildExpression(_ button: CustomAlertConfig.AlertButton) -> [CustomAlertConfig.AlertButton] {
        [button]
    }
    
    // 여러 배열을 하나로 결합
    static func buildBlock(_ components: [CustomAlertConfig.AlertButton]...) -> [CustomAlertConfig.AlertButton] {
        let result = components.flatMap { $0 }
        return result.isEmpty ? [CustomAlertConfig.AlertButton(title: "확인", style: .default, action: {})] : result
    }
    
    // Optional 지원
    static func buildOptional(_ component: [CustomAlertConfig.AlertButton]?) -> [CustomAlertConfig.AlertButton] {
        component ?? []
    }
    
    // if-else 지원
    static func buildEither(first component: [CustomAlertConfig.AlertButton]) -> [CustomAlertConfig.AlertButton] {
        component
    }
    
    static func buildEither(second component: [CustomAlertConfig.AlertButton]) -> [CustomAlertConfig.AlertButton] {
        component
    }
    
    // Array 지원
    static func buildArray(_ components: [[CustomAlertConfig.AlertButton]]) -> [CustomAlertConfig.AlertButton] {
        components.flatMap { $0 }
    }
}
