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
            return isSelected ? .white : Color.white.opacity(0.2)
        case .disabled:
            return Color.black.opacity(0.3)
        case .viewOnly:
            return isSelected ? Color.yellow : Color.yellow.opacity(0.3)
        }
    }
    
    private var foregroundColor: Color {
        switch state {
        case .active:
            return isSelected ? .black : .white
        case .disabled:
            return Color.gray.opacity(0.5)
        case .viewOnly:
            return .black
        }
    }
    
    private var isInteractive: Bool {
        state != .disabled
    }
    
    var body: some View {
        Button(action: {
            if isInteractive {
                action()
            }
        }) {
            VStack(spacing: 4) {
                // 타입 레이블 (작은 텍스트)
                if type != .cameraMode {
                    Text(type.rawValue)
                        .font(.caption2)
                        .foregroundColor(foregroundColor.opacity(0.7))
                }
                
                // 값 표시
                Text(value)
                    .font(type == .cameraMode ? .title2 : .system(size: 14, weight: .medium))
                    .foregroundColor(foregroundColor)
                    .fontWeight(type == .cameraMode ? .bold : .medium)
            }
            .frame(width: buttonWidth(for: type), height: buttonHeight(for: type))
            .background(backgroundColor)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(isSelected ? Color.white : Color.clear, lineWidth: 2)
            )
        }
        .disabled(!isInteractive)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
    
    private func buttonWidth(for type: SettingType) -> CGFloat {
        switch type {
        case .cameraMode:
            return 60
        case .filter, .exposure, .colorTemp:
            return 50
        default:
            return 45
        }
    }
    
    private func buttonHeight(for type: SettingType) -> CGFloat {
        switch type {
        case .cameraMode:
            return 60
        case .filter, .exposure, .colorTemp:
            return 50
        default:
            return 45
        }
    }
}

// MARK: - Camera Mode Selector
struct CameraModeSelector: View {
    @Binding var selectedMode: CameraMode
    let isEnabled: Bool
    let onSelect: (CameraMode) -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(CameraMode.allCases, id: \.self) { mode in
                Button(action: {
                    if isEnabled {
                        onSelect(mode)
                    }
                }) {
                    Text(mode.rawValue)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(selectedMode == mode ? .black : .white)
                        .frame(width: 50, height: 50)
                        .background(
                            Circle()
                                .fill(selectedMode == mode ? Color.white : Color.white.opacity(0.2))
                        )
                }
                .disabled(!isEnabled)
            }
        }
    }
}

// MARK: - Value Slider Component
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
