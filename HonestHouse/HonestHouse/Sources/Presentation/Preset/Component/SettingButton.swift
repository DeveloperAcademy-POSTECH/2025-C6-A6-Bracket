//
//  CameraPreset.swift
//  HonestHouse
//
//  Created by Subeen on 11/4/25.
//

import SwiftUI

struct SettingButton<SelectionType>: View {
    let type: SettingType
    let state: ButtonState
    let value: SelectionType
    let isSelected: Bool
    let action: () -> Void
    
    private var backgroundColor: Color {
        switch state {
        case .active:
            return isSelected ? Color.g0 : Color.g11
        case .disabled:
            return Color.g11
        case .viewOnly:
            return Color.yellow1
        }
    }
    
    private var foregroundColor: Color {
        switch state {
        case .active:
            return isSelected ? Color.g12 : Color.g0
        case .disabled:
            return Color.g7
        case .viewOnly:
            return Color.g12
        }
    }
    
    private var strokeColor: Color {
        switch state {
        case .active:
            return Color.g0
        case .disabled:
            return Color.g7
        case .viewOnly:
            return Color.clear
        }
    }
    
    
    private var isInteractive: Bool {
        state == .active
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // 값 표시
            if type != .cameraMode {
                Text("\(value)")
                    .font(.num6)
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
                            .font(.num6)
                            .foregroundColor(foregroundColor)
                    }
                    .overlay {
                        Circle()
                            .stroke(strokeColor)
                    }
            }
            
            .disabled(!isInteractive)
            .animation(.easeInOut(duration: 0.15), value: isSelected)
            .buttonStyle(NoHighlightButtonStyle())
        }
    }
    
    private func buttonWidth(for type: SettingType) -> CGFloat {
        switch type {
        case .cameraMode, .pictureStyle, .tintMagentaGreen, .exposure, .colorTemp:
            return 64
        case .aperture, .shutterSpeed, .iso:
            return 50
        }
    }
    
    private func buttonHeight(for type: SettingType) -> CGFloat {
        switch type {
        case .cameraMode, .pictureStyle, .tintMagentaGreen, .exposure, .colorTemp:
            return 64
        case .aperture, .shutterSpeed, .iso:
            return 50
        }
    }
}

struct ShootingModeSelector: View {
    @Binding var selectedMode: ShootingModeType
    let isEnabled: Bool
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(ShootingModeType.allCases, id: \.self) { mode in
                Button {
                    if isEnabled {
                        selectedMode = mode  // 직접 Binding 업데이트
                    }
                } label: {
                    Text(mode.rawValue)
                        .font(.num6)
                        .foregroundStyle(Color.g0)
                        .padding(15)
                        .clipShape(Circle())
                        .overlay {
                            Circle().strokeBorder(Color.g0, lineWidth: 1)
                        }
                }
            }
        }
    }
}
