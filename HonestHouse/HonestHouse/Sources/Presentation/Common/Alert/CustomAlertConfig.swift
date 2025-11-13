//
//  CustomAlertConfig.swift
//  HonestHouse
//
//  Created by 이현주 on 11/13/25.
//

import Foundation

struct CustomAlertConfig {
    let title: String
    let message: String
    let buttons: [AlertButton]
    
    struct AlertButton: Identifiable {
        let id = UUID()
        let title: String
        let style: ButtonStyle
        let action: () -> Void
        
        enum ButtonStyle {
            case `default`
            case cancel
        }
        
        static func cancel(_ title: String = "취소", action: @escaping () -> Void = {}) -> Self {
            AlertButton(title: title, style: .cancel, action: action)
        }
        
        static func `default`(_ title: String, action: @escaping () -> Void = {}) -> Self {
            AlertButton(title: title, style: .default, action: action)
        }
    }
}
