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
    private let viewMode: PresetDetailViewMode
    
    init(_ type: PresetDetailSettingButtonType, _ viewMode: PresetDetailViewMode) {
        self.type = type
        self.viewMode = viewMode
    }
    
    func makeBody(configuration: Configuration) -> some View {
        switch type {
        case .activated:
            configuration.label
                .foregroundStyle(Color.g0)
                .clipShape(Circle())
                .fontStyle(.num6)
                .overlay {
                    Circle().strokeBorder(Color.g0, lineWidth: 0.5)
                }
                .buttonStyle(NoHighlightButtonStyle())
            
        case .deactivated:
            configuration.label
                .foregroundStyle(Color.g0)
                .clipShape(Circle())
                .fontStyle(.num6)
                .overlay {
                    Circle().strokeBorder(Color.g7, lineWidth: 0.5)
                }
                .buttonStyle(NoHighlightButtonStyle())
            
        case .selected:
            configuration.label
                .foregroundStyle(Color.g12)
                .background(Color.g0)
                .fontStyle(.num6)
                .clipShape(Circle())
                .overlay {
                    Circle().strokeBorder(Color.g0, lineWidth: 0.5)
                }
                .buttonStyle(NoHighlightButtonStyle())
        }
    }
}
