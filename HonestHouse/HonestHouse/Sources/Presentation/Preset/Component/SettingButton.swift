//
//  CameraPreset.swift
//  HonestHouse
//
//  Created by Subeen on 11/4/25.
//

import SwiftUI

struct SettingButton: View {
    let type: SettingType
    let state: ButtonState
    let value: String
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
                Text(value)
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
        }
    }
    
    private func buttonWidth(for type: SettingType) -> CGFloat {
        switch type {
        case .cameraMode, .filter, .tint, .exposure, .colorTemp:
            return 64
        case .aperture, .shutterSpeed, .iso:
            return 50
        }
    }
    
    private func buttonHeight(for type: SettingType) -> CGFloat {
        switch type {
        case .cameraMode, .filter, .tint, .exposure, .colorTemp:
            return 64
        case .aperture, .shutterSpeed, .iso:
            return 50
        }
    }
}

struct CameraModeSelector: View {
    @Binding var selectedMode: CameraMode
    let isEnabled: Bool
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(CameraMode.allCases, id: \.self) { mode in
                Button {
                    if isEnabled {
                        selectedMode = mode  // 직접 Binding 업데이트
                    }
                } label: {
                    Text(mode.rawValue)
                }
            }
        }
    }
}

// TODO : 삭제 예정
struct ValueSlider: View {
    let title: String
    @Binding var selectedIndex: Int
    let values: [String]
    let isEnabled: Bool
    let onValueChange: (Int) -> Void
    
    @State private var dragOffset: CGFloat = 0
    @GestureState private var isDragging: Bool = false
    
    private let itemWidth: CGFloat = 70
    private let itemSpacing: CGFloat = 5
    
    var body: some View {
        VStack(spacing: 0) {
            // Slider Track
            GeometryReader { geometry in
                let totalWidth = CGFloat(values.count - 1) * (itemWidth + itemSpacing)
                let centerX = geometry.size.width / 2
                
                HStack(spacing: itemSpacing) {
                    ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                        Text(value)
                            .font(.system(size: index == selectedIndex ? 16 : 12))
                            .fontWeight(index == selectedIndex ? .bold : .regular)
                            .foregroundColor(
                                index == selectedIndex ? .white :
                                isEnabled ? Color.white.opacity(0.5) : Color.gray.opacity(0.3)
                            )
                            .frame(width: itemWidth, height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(index == selectedIndex ? Color.yellow : Color.clear)
                            )
                            .scaleEffect(index == selectedIndex ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.15), value: selectedIndex)
                    }
                }
                .offset(x: calculateOffset(geometry: geometry))
                .gesture(
                    isEnabled ? DragGesture()
                        .updating($isDragging) { _, state, _ in
                            state = true
                        }
                        .onChanged { value in
                            dragOffset = value.translation.width
                        }
                        .onEnded { value in
                            let totalOffset = value.translation.width
                            let itemTotalWidth = itemWidth + itemSpacing
                            let steps = Int(round(-totalOffset / itemTotalWidth))
                            
                            let newIndex = max(0, min(values.count - 1, selectedIndex + steps))
                            if newIndex != selectedIndex {
                                onValueChange(newIndex)
                            }
                            
                            dragOffset = 0
                        }
                    : nil
                )
            }
            .frame(height: 60)
            
            // Center Indicator
            Rectangle()
                .fill(Color.yellow)
                .frame(width: 2, height: 20)
                .offset(y: -10)
        }
        .opacity(isEnabled ? 1.0 : 0.5)
    }
    
    private func calculateOffset(geometry: GeometryProxy) -> CGFloat {
        let itemTotalWidth = itemWidth + itemSpacing
        let centerX = geometry.size.width / 2
        let selectedOffset = -CGFloat(selectedIndex) * itemTotalWidth
        let centering = centerX - (itemWidth / 2)
        
        return centering + selectedOffset + (isDragging ? dragOffset : 0)
    }
}
