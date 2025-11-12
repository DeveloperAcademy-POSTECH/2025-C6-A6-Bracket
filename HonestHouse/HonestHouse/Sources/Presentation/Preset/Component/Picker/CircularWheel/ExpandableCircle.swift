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
            return -15
        case .exposureCompensation:
            return -60
        case .colorTemperature:
            return -145
        }
    }
    
    var maxAngle: Double {
        switch self {
        case .tintMagentaGreen:
            return 145
        case .exposureCompensation:
            return 60
        case .colorTemperature:
            return 15
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
    
    // 특정 인덱스의 값 계산
    private func valueForTick(at index: Int) -> Int {
        let range = type.range
        return range.lowerBound + index * type.step
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
            
            
            
//            switch type {
//            case .tintMagentaGreen:
//                tintMagentaGreenTextView()
//            case .exposureCompensation:
//                EmptyView()
//            case .colorTemperature:
//                EmptyView()
//            }
            
//             틱마크와 값 텍스트
            ForEach(0..<tickCount, id: \.self) { index in
                let angle = angleForTick(at: index)
                let tickValue = valueForTick(at: index)
                let formattedValue = type.formatValue(tickValue)
                
                // TODO: 삭제
                // 틱마크 (작은 선)
//                Rectangle()
//                    .fill(Color.white.opacity(0.6))
//                    .frame(width: 1, height: 8)
//                    .offset(y: -viewModel.circleSize / 2 + 4)
//                    .rotationEffect(.degrees(angle + 90))
//                
                // 값 텍스트
                Text(formattedValue)
                    .font(.num6)
                    .foregroundColor(index == index ? Color.g0 : Color.yellow1)
                    .position(labelPosition(for: angle))
                    .rotationEffect(.degrees(angle - 120))
                
            }
            
            // 썸
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
    
    @ViewBuilder
    private func tintMagentaGreenTextView() -> some View {
        ForEach(0..<tickCount, id: \.self) { tickIndex in
            let angle = angleForTick(at: tickIndex)
            let tickValue = valueForTick(at: tickIndex)
            let formattedValue = type.formatValue(tickValue)
            
            switch viewModel.circleSizeType {
            case .small:
                if (Int(formattedValue) ?? 0) % 3 == 0 {
                    Text(formattedValue)
                        .font(.num6)
                        .foregroundStyle(Color.g0)
                        .position(labelPosition(for: angle))
                        .rotationEffect(.degrees(angle - 120))
                }
                
            case .medium:
                if (Int(formattedValue) ?? 0) % 3 == 0 {
                    Text(formattedValue)
                        .font(.num6)
                        .foregroundStyle(Color.g0)
                        .position(labelPosition(for: angle))
                        .rotationEffect(.degrees(angle - 120))
                } else {
                    Text(formattedValue)
                        .font(.num6)
                        .foregroundStyle(Color.g7)
                        .position(labelPosition(for: angle))
                        .rotationEffect(.degrees(angle - 120))
                }
            case .large:
                Text(formattedValue)
                    .font(.num6)
                    .foregroundStyle(Color.g0)
                    .position(labelPosition(for: angle))
                    .rotationEffect(.degrees(angle - 120))
            }
            
            if index == tickIndex {
                Text(formattedValue)
                    .foregroundStyle(Color.yellow1)
                    .font(.num6)
                    .position(labelPosition(for: angle))
                    .rotationEffect(.degrees(angle - 90))
            }
            
//            Text(formattedValue)
//                .font(.num6)
//                .foregroundColor(index == tickIndex ? Color.g0 : Color.yellow1)
                
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
        
        // 각도를 값으로 변환
        let normalized = (angleInDegrees - type.minAngle) / type.angleRange
        let range = type.range
        var newValue = range.lowerBound + Int(normalized * Double(range.upperBound - range.lowerBound))
        
        // 스텝 적용
        let step = type.step
        newValue = Int(round(Double(newValue) / Double(step))) * step
        
        // 값 업데이트
        index = min(max(newValue, range.lowerBound), range.upperBound)
    }
}
