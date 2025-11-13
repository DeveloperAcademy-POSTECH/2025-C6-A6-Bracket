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
    
    var step: Int {
        switch self {
        case .tintMagentaGreen:
            return 1
        case .exposureCompensation:
            return CameraConstants.exposureCompensationStep
        case .colorTemperature:
            return CameraConstants.colorTemperatureStep
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
    
    var rotationAngle: Double {
        switch self {
        case .tintMagentaGreen:
            45
        case .exposureCompensation:
            0.0
        case .colorTemperature:
            -45
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
    
    // 각도 범위의 크기
    var angleRange: Double {
        return maxAngle - minAngle
    }
    
    // 현재 값 포맷
    func formatValue(_ value: Int) -> String {
        switch self {
        case .tintMagentaGreen:
            guard value >= 0 && value < CameraConstants.tintMagentaGreenValues.count else { return "0" }
            return "\(CameraConstants.tintMagentaGreenValues[value])"
            
        case .exposureCompensation:
            guard value >= 0 && value < CameraConstants.exposureCompensationValues.count else { return "0" }
            return CameraConstants.exposureCompensationValues[value]
            
        case .colorTemperature:
            guard value >= 0 && value < CameraConstants.colorTemperatureValues.count else { return "0" }
            return "\(CameraConstants.colorTemperatureValues[value])K"
        }
    }
}

struct ExpandableCircle: View {
    
    @Bindable var viewModel: CircularWheelViewModel
    @Binding var index: Int
    
    let type: WheelSettingType
    let isVisible: Bool
    
    private let buttonExclusionRadius: CGFloat = 30
    
    private func angleForIndex(_ idx: Int) -> Double {
        switch type {
        case .tintMagentaGreen:
            // 17개 값을 160도 범위에 균등 분포
            // 인덱스 0(-8) → -20°
            // 인덱스 16(+8) → 140°
            let totalValues = 17  // 0~16 인덱스
            let normalized = Double(idx) / Double(totalValues - 1)  // 0/(17-1) ~ 16/(17-1) = 0~1
            return type.minAngle + type.angleRange * normalized  // -20 + 160 * (0~1)
            
        case .exposureCompensation:
            let totalValues = 19
            let normalized = Double(idx) / Double(totalValues - 1)
            return type.minAngle + type.angleRange * normalized
            
        case .colorTemperature:
            let totalValues = CameraConstants.colorTemperatureValues.count
            let normalized = Double(idx) / Double(totalValues - 1)
            return type.minAngle + type.angleRange * normalized
        }
    }
    
    // 현재 선택된 인덱스의 각도
    private var currentAngle: Angle {
        if viewModel.currentAngle != 0.0 && viewModel.isDragging {
            return .degrees(viewModel.currentAngle)
        }
        return .degrees(angleForIndex(index))
    }
    
    // 썸 위치 계산
    private var thumbPosition: CGPoint {
        let angle = (currentAngle.degrees - 90) * .pi / 180
        let radius = viewModel.circleSize / 2
        
        return CGPoint(
            x: radius + radius * cos(angle),
            y: radius + radius * sin(angle)
        )
    }
    
    // 라벨 위치 계산
    private func labelPosition(for angle: Double) -> CGPoint {
        let angleInRadians = (angle - 90) * .pi / 180
        let radius = viewModel.circleSize / 2
        let labelDistance = radius + 20
        
        return CGPoint(
            x: radius + labelDistance * cos(angleInRadians),
            y: radius + labelDistance * sin(angleInRadians)
        )
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(type.strokeColor, lineWidth: 4)
                .frame(width: viewModel.circleSize, height: viewModel.circleSize)
            
            // 라벨 표시
            ForEach(0..<type.range.upperBound + 1, id: \.self) { idx in
                if shouldShowLabel(at: idx) {
                    let angle = angleForIndex(idx)
                    let formattedValue = type.formatValue(idx)
                    let labelColor = getLabelColor(at: idx)
                    
                    Text(formattedValue)
                        .font(.num6)
                        .foregroundColor(labelColor)
                        .position(labelPosition(for: angle))
//                        .rotationEffect(.degrees(angle - 90))
                }
            }
            
            // Thumb
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
                            handleArcDrag(gesture: gesture)
                            viewModel.checkCircleSize()
                        }
                        .onEnded { _ in
                            viewModel.isDragging = false
                            viewModel.currentAngle = 0.0  // 리셋
                        }
                )
        }
        .frame(width: viewModel.circleSize, height: viewModel.circleSize)
    }
    
    // 라벨 표시 여부 판단 - 간단하게
    private func shouldShowLabel(at idx: Int) -> Bool {
        switch type {
        case .tintMagentaGreen:
            guard idx < CameraConstants.tintMagentaGreenValues.count else { return false }
            let value = CameraConstants.tintMagentaGreenValues[idx]
            
            if viewModel.circleSizeType == .small {
                return value % 3 == 0
            }
            return true
            
        case .exposureCompensation:
            return idx % 3 == 0
            
        case .colorTemperature:
            let maxIndex = type.range.upperBound
            return idx == 0 || idx == maxIndex || idx == index
        }
    }
    
    // 라벨 색상 결정 - 간단하게
    private func getLabelColor(at idx: Int) -> Color {
        if idx == index {
            return Color.yellow1
        }
        
        switch type {
        case .tintMagentaGreen:
            guard idx < CameraConstants.tintMagentaGreenValues.count else { return Color.g0 }
            let value = CameraConstants.tintMagentaGreenValues[idx]
            
            if viewModel.circleSizeType == .medium && value % 3 != 0 {
                return Color.g7
            }
            return Color.g0
            
        default:
            return Color.g0
        }
    }
    
    private func handleArcDrag(gesture: DragGesture.Value) {
        let center = viewModel.circleSize / 2
        let location = gesture.location
        
        let deltaX = location.x - center
        let deltaY = location.y - center
        
        let distanceFromCenter = sqrt(deltaX * deltaX + deltaY * deltaY)
        
        if !viewModel.isDragging {
            viewModel.isDragging = true
        }
        
        guard distanceFromCenter > 5 else { return }
        
        // 각도 계산
        let angleInRadians = atan2(deltaX, -deltaY)
        var angleInDegrees = angleInRadians * 180 / .pi
        
        // 범위 제한
        angleInDegrees = max(type.minAngle, min(type.maxAngle, angleInDegrees))
        viewModel.currentAngle = angleInDegrees
        
        // 각도를 인덱스로 변환 - 수정된 부분!
        let normalized = (angleInDegrees - type.minAngle) / type.angleRange
        
        switch type {
        case .tintMagentaGreen:
            // 17개 값 (인덱스 0~16)
            let totalCount = CameraConstants.tintMagentaGreenValues.count
            let rawIndex = normalized * Double(totalCount)  // ✅ 16을 곱함 (0~16 범위)
            let closestIndex = Int(round(rawIndex))
            
            if viewModel.circleSizeType == .small {
                // Small: 3의 배수 값만
                let validIndices = (0..<totalCount).filter { idx in
                    return CameraConstants.tintMagentaGreenValues[idx] % 3 == 0
                }
                
                index = validIndices.min(by: {
                    abs(Double($0) - rawIndex) < abs(Double($1) - rawIndex)
                }) ?? closestIndex
            } else {
                index = min(max(closestIndex, 0), totalCount)
            }
            
        case .exposureCompensation:
            let totalCount = CameraConstants.exposureCompensationValues.count
            let rawIndex = normalized * Double(totalCount - 1)
            let rounded = Int(round(rawIndex))
            
            // 3의 배수 인덱스만
            index = (rounded / 3) * 3
            index = min(max(index, 0), totalCount - 1)
            
        case .colorTemperature:
            let totalCount = CameraConstants.colorTemperatureValues.count
            let rawIndex = normalized * Double(totalCount - 1)
            index = min(max(Int(round(rawIndex)), 0), totalCount - 1)
        }
    }
}
