//
//  ExpandableCircle.swift
//  HonestHouse
//
//  Created by Subeen on 11/9/25.
//

import Foundation
import SwiftUI

enum WheelSettingType {
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
}

struct ExpandableCircle: View {
    
    @Bindable var viewModel: CircularWheelViewModel  // ViewModel 추가
    @Binding var value: Int
    
    let type: WheelSettingType
    let size: CGFloat
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
        let angle = currentAngle.radians - .pi/2
        let radius = size / 2
        
        // 로컬 좌표계의 중심 기준으로 계산
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
            
            // 썸 (터치 불가)
            Circle()
                .fill(Color.g0)
                .frame(width: 12, height: 12)
                .position(thumbPosition)
            
            // 제스처 영역 - 원 전체
            Circle()
                .fill(Color.clear)
                .contentShape(Circle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            handleArcDrag(gesture: gesture)
                        }
                        .onEnded { _ in
                            viewModel.isDragging = false
                        }
                )
        }
        .frame(width: size, height: size)
    }
    
    private func handleArcDrag(gesture: DragGesture.Value) {
        // 로컬 좌표계의 중심점 (size의 중심)
        let localCenter = CGPoint(x: size / 2, y: size / 2)
        let location = gesture.location
        
        // 중심에서 터치 위치까지의 상대 위치 계산
        let deltaX = location.x - localCenter.x
        let deltaY = location.y - localCenter.y
        
        // TODO: 나중에 버튼 제외 로직 추가
        // let distanceFromCenter = sqrt(deltaX * deltaX + deltaY * deltaY)
        // if distanceFromCenter < buttonExclusionRadius { return }
        
        // 첫 드래그면 isDragging 활성화
        if !viewModel.isDragging {
            viewModel.isDragging = true
        }
        
        // atan2를 사용해 각도 계산
        // deltaY: 아래쪽 = 양수, 위쪽 = 음수 이므로 -deltaY로 반전
        // deltaX: 오른쪽 = 양수, 왼쪽 = 음수
        let angleInRadians = atan2(deltaX, -deltaY)
        var angleInDegrees = angleInRadians * 180 / .pi
        
        // -60 ~ 60 범위로 제한 (120도 arc)
        angleInDegrees = max(-60, min(60, angleInDegrees))
        
        // ViewModel의 각도 업데이트
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
