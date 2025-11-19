//
//  CameraPreset.swift
//  HonestHouse
//
//  Created by Subeen on 11/4/25.
//

import SwiftUI

struct SettingButtonView<SelectionType>: View {
    let type: PresetSettingType
    let state: PresetButtonState  // 변경
    let viewMode: PresetDetailViewMode  // 추가
    let value: SelectionType
    let isSelected: Bool
    let action: () -> Void
    
    private var backgroundColor: Color {
        state.backgroundColor(viewMode: viewMode)
    }
    
    private var foregroundColor: Color {
        state.foregroundColor(viewMode: viewMode)
    }
    
    private var strokeColor: Color {
        state.strokeColor(viewMode: viewMode)
    }
    
    private var isInteractive: Bool {
        state.isInteractive
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // 값 표시
            if type != .cameraMode && type != .pictureStyle {
                Text("\(value)")
                    .fontStyle(.num6)
                    .foregroundColor(Color.g0)
            }
            
            Button {
                if isInteractive {
                    action()
                }
            } label: {
                Circle()
                    .frame(width: buttonWidth(for: type), height: buttonHeight(for: type))
                    .foregroundStyle(backgroundColor)
                    .overlay {
                        Text(type.rawValue)
                            .fontStyle(.num6)
                            .foregroundColor(foregroundColor)
                    }
                    .overlay {
                        Circle()
                            .stroke(strokeColor, lineWidth: 1)
                    }
            }
            .disabled(!isInteractive)
            .animation(.easeInOut(duration: 0.15), value: isSelected)
            .buttonStyle(NoHighlightButtonStyle())
        }
    }
    
    private func buttonWidth(for type: PresetSettingType) -> CGFloat {
        switch type {
        case .cameraMode, .pictureStyle, .tintMagentaGreen, .exposure, .colorTemp:
            return 64
        case .aperture, .shutterSpeed, .iso:
            return 50
        }
    }
    
    private func buttonHeight(for type: PresetSettingType) -> CGFloat {
        switch type {
        case .cameraMode, .pictureStyle, .tintMagentaGreen, .exposure, .colorTemp:
            return 64
        case .aperture, .shutterSpeed, .iso:
            return 50
        }
    }
}
