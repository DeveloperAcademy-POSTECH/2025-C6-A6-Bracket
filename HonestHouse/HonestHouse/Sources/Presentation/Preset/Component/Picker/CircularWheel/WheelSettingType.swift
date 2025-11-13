//
//  WheelSettingType.swift
//  HonestHouse
//
//  Created by Subeen on 11/13/25.
//


//
//  ExpandableCircle.swift
//  HonestHouse
//
//  Created by Subeen on 11/9/25.
//

import Foundation
import SwiftUI

enum WheelSettingType: CaseIterable {
    case tintMagentaGreen
    case exposureCompensation
    case colorTemperature
    
    var icon: Image {
        switch self {
        case .tintMagentaGreen:
            return Image(.colortemperatureIcon) // TODO: - tint 로 변경
        case .exposureCompensation:
            return Image(.exposureIcon)
        case .colorTemperature:
            return Image(.colortemperatureIcon)
        }
    }
    
    var range: ClosedRange<Int> {
        switch self {
        case .tintMagentaGreen:
            return 0...CameraConstants.tintMagentaGreenValues.count - 1
        case .exposureCompensation:
            return 0...CameraConstants.exposureCompensationValues.count - 1
        case .colorTemperature:
            return 0...CameraConstants.colorTemperatureValues.count - 1
        }
    }
    
    var strokeColor: LinearGradient {
        switch self {
        case .tintMagentaGreen:
            return LinearGradient.magentaGreenGradient
        case .exposureCompensation:
            return LinearGradient.exposureGradient
        case .colorTemperature:
            return LinearGradient.colorTemperatureGradient
        }
    }
    
    // 드래그 가능한 각도 범위
    var minAngle: Double {
        switch self {
        case .tintMagentaGreen:
            return -20
        case .exposureCompensation:
            return -65
        case .colorTemperature:
            return -160
        }
    }
    
    var maxAngle: Double {
        switch self {
        case .tintMagentaGreen:
            return 140
        case .exposureCompensation:
            return 65
        case .colorTemperature:
            return 0
        }
    }
    
    var angleRange: Double {
        return maxAngle - minAngle
    }
    
    // 현재 값 포맷
    func formatValue(_ index: Int) -> String {
        switch self {
        case .tintMagentaGreen:
            guard index >= 0 && index < CameraConstants.tintMagentaGreenValues.count else { return "0" }
            return "\(CameraConstants.tintMagentaGreenValues[index])"
            
        case .exposureCompensation:
            guard index >= 0 && index < CameraConstants.exposureCompensationValues.count else { return "0" }
            return CameraConstants.exposureCompensationValues[index]
            
        case .colorTemperature:
            guard index >= 0 && index < CameraConstants.colorTemperatureValues.count else { return "0" }
            return "\(CameraConstants.colorTemperatureValues[index])K"
        }
    }
}

struct ExpandableCircle: View {
    
    @Bindable var viewModel: CircularWheelViewModel
    @Binding var index: Int
    
    @State private var previousIndex: Int = 0
    
    let type: WheelSettingType
    let isVisible: Bool
    
    // MARK: - Computed Properties
    
    private var currentAngle: Double {
        WheelCalculator.indexToAngle(index: index, type: type)
    }
    
    private var thumbPosition: CGPoint {
        let angle = (currentAngle - 90) * .pi / 180
        let radius = viewModel.circleSize / 2
        
        return CGPoint(
            x: radius + radius * cos(angle),
            y: radius + radius * sin(angle)
        )
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // 원
            Circle()
                .stroke(type.strokeColor, lineWidth: 4)
                .frame(width: viewModel.circleSize, height: viewModel.circleSize)
            
            // 라벨
            ForEach(0..<type.range.upperBound + 1, id: \.self) { idx in
                if shouldShowLabel(at: idx) {
                    LabelView(
                        index: idx,
                        currentIndex: index,
                        type: type,
                        circleSize: viewModel.circleSize,
                        circleSizeType: viewModel.circleSizeType
                    )
                }
            }
            
            // 썸
            Circle()
                .fill(Color.g0)
                .frame(width: 12, height: 12)
                .position(thumbPosition)
            
            // 제스처 영역
            Circle()
                .fill(Color.clear)
                .contentShape(Circle())
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            handleDrag(at: gesture.location)
                        }
                        .onEnded { _ in
                            viewModel.isDragging = false
                        }
                )
        }
        .frame(width: viewModel.circleSize, height: viewModel.circleSize)
        .sensoryFeedback(.selection, trigger: index)  // ✨ 값 변경시 진동
        .onChange(of: index) { _, newValue in
            previousIndex = newValue
        }
    }
    
    // MARK: - Gesture Handling
    
    private func handleDrag(at location: CGPoint) {
        let center = viewModel.circleSize / 2
        let deltaX = location.x - center
        let deltaY = location.y - center
        
        guard sqrt(deltaX * deltaX + deltaY * deltaY) > 5 else { return }
        
        if !viewModel.isDragging {
            viewModel.isDragging = true
        }
        
        let angleInRadians = atan2(deltaX, -deltaY)
        let angleInDegrees = angleInRadians * 180 / .pi
        let clampedAngle = max(type.minAngle, min(type.maxAngle, angleInDegrees))
        
        index = WheelCalculator.angleToIndex(
            angle: clampedAngle,
            type: type,
            circleSize: viewModel.circleSizeType
        )
    }
    
    private func shouldShowLabel(at idx: Int) -> Bool {
        switch type {
        case .tintMagentaGreen:
            guard idx < CameraConstants.tintMagentaGreenValues.count else { return false }
            let value = CameraConstants.tintMagentaGreenValues[idx]
            return viewModel.circleSizeType == .small ? value % 3 == 0 : true
            
        case .exposureCompensation:
            return idx % 3 == 0
            
        case .colorTemperature:
            return idx == 0 || idx == type.range.upperBound || idx == index
        }
    }
}

// MARK: - Label View Component

private struct LabelView: View {
    let index: Int
    let currentIndex: Int
    let type: WheelSettingType
    let circleSize: CGFloat
    let circleSizeType: CircleSizeType
    
    var body: some View {
        Text(type.formatValue(index))
            .font(.num6)
            .foregroundColor(labelColor)
            .position(labelPosition)
    }
    
    private var labelPosition: CGPoint {
        let angle = WheelCalculator.indexToAngle(index: index, type: type)
        let angleInRadians = (angle - 90) * .pi / 180
        let radius = circleSize / 2
        let labelDistance = radius + 20
        
        return CGPoint(
            x: radius + labelDistance * cos(angleInRadians),
            y: radius + labelDistance * sin(angleInRadians)
        )
    }
    
    private var labelColor: Color {
        if index == currentIndex {
            return Color.yellow1
        }
        
        if type == .tintMagentaGreen && circleSizeType == .medium {
            let value = CameraConstants.tintMagentaGreenValues[index]
            return value % 3 != 0 ? Color.g7 : Color.g0
        }
        
        return Color.g0
    }
}
