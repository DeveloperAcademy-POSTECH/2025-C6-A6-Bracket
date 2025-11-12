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
    
    // 최소값 텍스트
    var minValueText: String {
        switch self {
        case .tintMagentaGreen:
            return CameraConstants.tintMagentaGreenValues.first?.description ?? "0"
        case .exposureCompensation:
            return CameraConstants.exposureCompensationValues.first?.description ?? "-3.0"
        case .colorTemperature:
            return CameraConstants.colorTemperatureValues.first?.description ?? "2500K"
        }
    }
    
    // 최대값 텍스트
    var maxValueText: String {
        switch self {
        case .tintMagentaGreen:
            return CameraConstants.tintMagentaGreenValues.last?.description ?? "0"
        case .exposureCompensation:
            return CameraConstants.exposureCompensationValues.last?.description ?? "+3.0"
        case .colorTemperature:
            return CameraConstants.colorTemperatureValues.last?.description ?? "10000K"
        }
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
    
    @Bindable var viewModel: CircularWheelViewModel  // ViewModel 추가
    @Binding var index: Int
    
    let type: WheelSettingType
    let isVisible: Bool
//    var circleSize: CircleSize
    
    // 버튼 영역 크기 (제스처에서 제외할 중심 영역) - 나중에 사용
    private let buttonExclusionRadius: CGFloat = 30
    
    private var normalizedValue: Double {
        let range = type.range
        return Double(index - range.lowerBound) / Double(range.upperBound - range.lowerBound)
    }
    
    private var currentAngle: Angle {
        // ViewModel의 각도가 설정되어 있으면 항상 사용 (드래그 중이든 아니든)
        if viewModel.currentAngle != 0.0 {
            return .degrees(viewModel.currentAngle)
        }
        // 각도가 설정되지 않았으면 value 기반으로 계산
        return .degrees(type.minAngle + type.angleRange * normalizedValue)
    }
    
    private var thumbPosition: CGPoint {
        // currentAngle: 0도 = 12시 방향(위), 양수 = 시계방향
        // cos/sin: 0도 = 3시 방향(오른쪽), 양수 = 반시계방향
        // 12시를 0도로 맞추려면 -90도 필요
        let angle = (currentAngle.degrees - 90) * .pi / 180
        let radius = viewModel.circleSize / 2
        
        // ZStack의 중심은 (circleSize/2, circleSize/2)
        // 원의 호선 위 좌표 = 중심 + (radius * cos, radius * sin)
        return CGPoint(
            x: radius + radius * cos(angle),
            y: radius + radius * sin(angle)
        )
    }
    
    // 양끝값 라벨 위치 계산 (원 바깥쪽 30pt)
    private func labelPosition(for angle: Double) -> CGPoint {
        let angleInRadians = (angle - 90) * .pi / 180
        let radius = viewModel.circleSize / 2
        let labelDistance = radius + 30  // 원 바깥쪽 30pt
        
        return CGPoint(
            x: radius + labelDistance * cos(angleInRadians),
            y: radius + labelDistance * sin(angleInRadians)
        )
    }
    
    // 틱마크 개수 계산
    private var tickCount: Int {
        let range = type.range
        let step = type.step
        return (range.upperBound - range.lowerBound) / step + 1
    }
    
    // 특정 인덱스의 각도 계산
    private func angleForTick(at index: Int) -> Double {
        let normalized = Double(index) / Double(max(tickCount - 1, 1))
        return type.minAngle + type.angleRange * normalized
    }
    
    // 특정 인덱스의 값 계산 (배열 인덱스 그대로 반환)
    private func valueForTick(at index: Int) -> Int {
        return index
    }
    
//    mutating private func getCircleSize() {
//        circleSize = viewModel.checkCircleSize()
//    }
    
    var body: some View {
        ZStack {
            // 원 그리기
            Circle()
                .stroke(type.strokeColor, lineWidth: 4)
                .frame(width: viewModel.circleSize, height: viewModel.circleSize)
            
            // 라벨 표시
            ForEach(0..<tickCount, id: \.self) { tickIndex in
                let angle = angleForTick(at: tickIndex)
                let tickValue = valueForTick(at: tickIndex)
                
                // 라벨 표시 여부 판단
                if shouldShowLabel(for: tickIndex, value: tickValue) {
                    let formattedValue = type.formatValue(tickValue)
                    let labelColor = getLabelColor(for: tickIndex, value: tickValue)
                    
                    Text(formattedValue)
                        .font(.num6)
                        .foregroundColor(labelColor)
                        .position(labelPosition(for: angle))
                        .rotationEffect(.degrees(angle - 90))
                }
            }
            
            // Thumb
            Circle()
                .fill(Color.g0)
                .frame(width: 12, height: 12)
                .position(thumbPosition)
            
            // 제스처 영역 - 원 전체
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
                        }
                )
        }
        .frame(width: viewModel.circleSize, height: viewModel.circleSize)
    }
    
    // 라벨 표시 여부 판단
    private func shouldShowLabel(for tickIndex: Int, value: Int) -> Bool {
        switch type {
        case .tintMagentaGreen:
            guard tickIndex >= 0 && tickIndex < CameraConstants.tintMagentaGreenValues.count else {
                return false
            }
            let actualValue = CameraConstants.tintMagentaGreenValues[tickIndex]
            
            // Small: 3의 배수 값만
            if viewModel.circleSizeType == .small {
                return actualValue % 3 == 0
            }
            // Medium/Large: 모두 표시
            return true
            
        case .exposureCompensation:
            // 정수값만 표시 (인덱스 3의 배수)
            return tickIndex % 3 == 0
            
        case .colorTemperature:
            // 양끝값 + 현재 선택된 값만 표시
            let maxIndex = type.range.upperBound
            return tickIndex == 0 || tickIndex == maxIndex || tickIndex == index
        }
    }
    
    // 라벨 색상 결정
    private func getLabelColor(for tickIndex: Int, value: Int) -> Color {
        // 현재 선택된 값이면 강조 색상
        if tickIndex == index {
            return Color.yellow1
        }
        
        switch type {
        case .tintMagentaGreen:
            guard tickIndex >= 0 && tickIndex < CameraConstants.tintMagentaGreenValues.count else {
                return Color.g0
            }
            let actualValue = CameraConstants.tintMagentaGreenValues[tickIndex]
            
            // Medium일 때 3의 배수 아니면 어두운 색
            if viewModel.circleSizeType == .medium && actualValue % 3 != 0 {
                return Color.g7
            }
            return Color.g0
            
        case .exposureCompensation:
            return Color.g0
            
        case .colorTemperature:
            return Color.g0
        }
    }
    
    
    private func handleArcDrag(gesture: DragGesture.Value) {
        let center = viewModel.circleSize / 2
        let location = gesture.location
        
        // 중심에서 터치 위치까지의 벡터
        let deltaX = location.x - center
        let deltaY = location.y - center
        
        // 중심에서의 거리 계산
        let distanceFromCenter = sqrt(deltaX * deltaX + deltaY * deltaY)
        
        // 첫 드래그면 isDragging 활성화
        if !viewModel.isDragging {
            viewModel.isDragging = true
        }
        
        // 거리가 너무 작으면 각도 계산 불안정하므로 최소 거리 적용
        guard distanceFromCenter > 5 else { return }
        
        // atan2를 사용해 각도 계산
        let angleInRadians = atan2(deltaX, -deltaY)
        var angleInDegrees = angleInRadians * 180 / .pi
        
        // 타입별 각도 범위로 제한
        angleInDegrees = max(type.minAngle, min(type.maxAngle, angleInDegrees))
        
        // 애니메이션 없이 즉시 업데이트
        viewModel.currentAngle = angleInDegrees
        
        // 각도를 인덱스로 변환
        let normalized = (angleInDegrees - type.minAngle) / type.angleRange
        let maxIndex = type.range.upperBound
        let rawIndex = normalized * Double(maxIndex)
        
        // 유효한 인덱스로 스냅
        index = snapToValidIndex(rawIndex)
    }
    
    // 설정 가능한 가장 가까운 인덱스로 스냅
    private func snapToValidIndex(_ rawIndex: Double) -> Int {
        let maxIndex = type.range.upperBound
        let rounded = Int(round(rawIndex))
        let clamped = min(max(rounded, 0), maxIndex)
        
        switch type {
        case .tintMagentaGreen:
            if viewModel.circleSizeType == .small {
                // 3의 배수 값을 가진 인덱스만 허용
                let validIndices = (0...maxIndex).filter { index in
                    guard index < CameraConstants.tintMagentaGreenValues.count else { return false }
                    return CameraConstants.tintMagentaGreenValues[index] % 3 == 0
                }
                
                // 가장 가까운 유효한 인덱스 찾기
                return validIndices.min(by: {
                    abs($0 - clamped) < abs($1 - clamped)
                }) ?? clamped
            }
            return clamped
            
        case .exposureCompensation:
            // 정수 인덱스만 (0, 3, 6, 9, ...)
            return (clamped / 3) * 3
            
        case .colorTemperature:
            return clamped
        }
    }
}
