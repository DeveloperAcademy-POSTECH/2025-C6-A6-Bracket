//
//  ExpandableCircle.swift
//  HonestHouse
//
//  Created by Subeen on 11/9/25.
//

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
    
    @State var dragAngle: Double = 0
    
    @Binding var isDragging: Bool
    @Binding var value: Int
    
    let type: WheelSettingType
    let size: CGFloat
    let center: CGPoint
    let isVisible: Bool
    
    private var normalizedValue: Int {
        let range = type.range
        return (value - range.lowerBound) / (range.upperBound - range.lowerBound)
    }
    
    private var startAngle: Angle { .degrees(-60) }
    private var endAngle: Angle { .degrees(60) }
    
    private var currentAngle: Angle {
        if isDragging {
            return .degrees(dragAngle)
        }
        return .degrees(-60 + 120 * Double(normalizedValue))
    }
    
    private var thumbPosition: CGPoint {
        let angle = currentAngle.radians - .pi/2
        let radius = size / 2
        return CGPoint(
            x: radius + radius * Foundation.cos(angle),
            y: radius + radius * Foundation.sin(angle)
        )
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(type.strokeColor, lineWidth: 4)
                .frame(width: size, height: size)
                .position(center)
//                .opacity(isVisible ? 1 : 0)
            
            Circle()
                .fill(Color.g0)
                .frame(width: 12, height: 12)
                .position(thumbPosition)
                .shadow(radius: 5)
            
            Color.clear
                .contentShape(Circle())
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            handleArcDrag(gesture: gesture)
                        }
                        .onEnded { _ in
                            isDragging = false
//                            isAdjusting = false
                        }
                )
        }
    }
    
    private func handleArcDrag(gesture: DragGesture.Value) {
        if !isDragging {
            isDragging = true
//            isAdjusting = true
        }
        
        let center = CGPoint(x: size / 2, y: size / 2)
        let location = gesture.location
        
        // 중심에서 터치 위치까지의 각도 계산
        let deltaX = location.x - center.x
        let deltaY = location.y - center.y
        
        // atan2를 사용해 각도 계산 (라디안)
        var angleInRadians = Foundation.atan2(deltaY, deltaX) + .pi/2
        var angleInDegrees = angleInRadians * 180 / .pi
        
        // -60 ~ 60 범위로 제한 (120도 arc)
        if angleInDegrees < -60 { angleInDegrees = -60 }
        if angleInDegrees > 60 { angleInDegrees = 60 }
        
        dragAngle = angleInDegrees
        
        // 각도를 값으로 변환
        let normalized = (angleInDegrees + 60) / 120
        let range = type.range
        var newValue = range.lowerBound + (range.upperBound - range.lowerBound) * Int(normalized)
        
        // 스텝 적용
//        let step = type.step(for: wheelSize)
//        newValue = round(newValue / step) * step
        
        // 값 업데이트
        value = min(max(newValue, range.lowerBound), range.upperBound)
    }
}
