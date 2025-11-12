//
//  PresetDetailSettingButtonStyle.swift
//  HonestHouse
//
//  Created by Subeen on 11/11/25.
//

import SwiftUI

enum PresetDetailSettingButtonType {
    case activated
    case deactivated
    case selected
}

struct PresetDetailSettingButtonStyle: ButtonStyle {
    private let type: PresetDetailSettingButtonType
    
    init(_ type: PresetDetailSettingButtonType) {
        self.type = type
    }
    
    func makeBody(configuration: Configuration) -> some View {
        switch type {
        case .activated:
            configuration.label
                .foregroundStyle(Color.g0)
                .clipShape(Circle())
                .font(.num6)
                .overlay {
                    Circle().strokeBorder(Color.g0, lineWidth: 0.5)
                }
                .buttonStyle(NoHighlightButtonStyle())
            
        case .deactivated:
            configuration.label
                .foregroundStyle(Color.g0)
                .clipShape(Circle())
                .font(.num6)
                .overlay {
                    Circle().strokeBorder(Color.g7, lineWidth: 0.5)
                }
                .buttonStyle(NoHighlightButtonStyle())
            
        case .selected:
            configuration.label
                .foregroundStyle(Color.g0)
                .background(Color.g11)
                .font(.num6)
                .clipShape(Circle())
                .overlay {
                    Circle().strokeBorder(Color.g0, lineWidth: 0.5)
                }
                .buttonStyle(NoHighlightButtonStyle())
        }
    }
}
