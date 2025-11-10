//
//  ExpandableCircle.swift
//  HonestHouse
//
//  Created by Subeen on 11/9/25.
//

import Foundation
import SwiftUI

enum WheelSettingType: CaseIterable {
    case mg
    case exposure
    case temperature
    
    var range: ClosedRange<Int> {
        switch self {
        case .mg:
            return 0...CameraConstants.tintMagentaGreenValues.count
        case .exposure:
            return 0...CameraConstants.exposureCompensationValues.count
        case .temperature:
            return CameraConstants.colorTemperatureRange
        }
    }
    
    var step: Int {
        switch self {
        case .mg:
            return 1
        case .exposure:
            return CameraConstants.exposureCompensationStep
        case .temperature:
            return CameraConstants.colorTemperatureStep
        }
    }
    
    var strokeColor: LinearGradient {
        switch self {
        case .mg:
            return LinearGradient.magentaGreenGradient
        case .exposure:
            return LinearGradient.exposureGradient
        case .temperature:
            return LinearGradient.colorTemperatureGradient
        }
    }
    
    var rotationAngle: Double {
        switch self {
        case .mg:
            45
        case .exposure:
            0.0
        case .temperature:
            -45
        }
    }
}

struct ExpandableCircle: View {
    
    @Bindable var viewModel: CircularWheelViewModel  // ViewModel 추가
    @Binding var value: Int
    
    let type: WheelSettingType
    let isVisible: Bool
    
    // 버튼 영역 크기 (제스처에서 제외할 중심 영역) - 나중에 사용
    private let buttonExclusionRadius: CGFloat = 30
    
    private var normalizedValue: Double {
        let range = type.range
        return Double(value - range.lowerBound) / Double(range.upperBound - range.lowerBound)
    }
    
    private var startAngle: Angle { .degrees(-60) }
    private var endAngle: Angle { .degrees(60) }
    
    private var currentAngle: Angle {
        // ViewModel의 각도가 설정되어 있으면 항상 사용 (드래그 중이든 아니든)
        if viewModel.currentAngle != 0.0 {
            return .degrees(viewModel.currentAngle)
        }
        // 각도가 설정되지 않았으면 value 기반으로 계산
        return .degrees(-60 + 120 * normalizedValue)
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
    
    var body: some View {
        ZStack {
            // 원 그리기 (터치 불가)
            Circle()
                .stroke(type.strokeColor, lineWidth: 4)
                .frame(width: viewModel.circleSize, height: viewModel.circleSize)
            
            // 썸 (터치 불가)
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
                        }
                        .onEnded { _ in
                            viewModel.isDragging = false
                        }
                )
        }
        .rotationEffect(.degrees(type.rotationAngle))
        .frame(width: viewModel.circleSize, height: viewModel.circleSize)
    }
    
    private func handleArcDrag(gesture: DragGesture.Value) {
        // 원 크기가 변하는 중에도 정확한 각도 계산을 위해
        // 현재 프레임의 중심을 기준으로 계산
        let center = viewModel.circleSize / 2
        let location = gesture.location
        
        // 중심에서 터치 위치까지의 벡터
        let deltaX = location.x - center
        let deltaY = location.y - center
        
        // 중심에서의 거리 계산
        let distanceFromCenter = sqrt(deltaX * deltaX + deltaY * deltaY)
        
        // TODO: 나중에 버튼 제외 로직
        // if distanceFromCenter < buttonExclusionRadius { return }
        
        // 첫 드래그면 isDragging 활성화
        if !viewModel.isDragging {
            viewModel.isDragging = true
        }
        
        // 거리가 너무 작으면 각도 계산 불안정하므로 최소 거리 적용
        guard distanceFromCenter > 5 else { return }
        
        // atan2를 사용해 각도 계산
        // -deltaY: 위쪽을 0도로 만들기 위해 Y축 반전
        let angleInRadians = atan2(deltaX, -deltaY)
        var angleInDegrees = angleInRadians * 180 / .pi
        
        // 회전 보정: 원이 회전한 만큼 역회전 적용
        // 예: mg가 45도 회전되어 있으면, 드래그 각도에서 45도를 빼서 실제 thumb 각도 계산
        angleInDegrees = angleInDegrees - type.rotationAngle
        
        // -60 ~ 60 범위로 제한 (120도 arc)
        angleInDegrees = max(-60, min(60, angleInDegrees))
        
        // 애니메이션 없이 즉시 업데이트 (빠른 드래그 대응)
        viewModel.currentAngle = angleInDegrees
        
        // 각도를 값으로 변환
        let normalized = (angleInDegrees + 60) / 120
        let range = type.range
        var newValue = range.lowerBound + Int(normalized * Double(range.upperBound - range.lowerBound))
        
        // 스텝 적용
        let step = type.step
        newValue = Int(round(Double(newValue) / Double(step))) * step
        
        // 값 업데이트
        value = min(max(newValue, range.lowerBound), range.upperBound)
    }
}
