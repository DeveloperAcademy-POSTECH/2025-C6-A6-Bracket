//
//  WheelLabelView.swift
//  HonestHouse
//
//  Created by Subeen on 11/13/25.
//

import Foundation
import SwiftUI

// Wheel의 외곽선에 나타나는 라벨
struct WheelLabelView: View {
    let index: Int
    let currentIndex: Int
    let type: WheelSettingType
    let circleSize: CGFloat
    let circleSizeType: CircularWheelSizeType
    
    var body: some View {
        Text(type.formatValue(index))
            .fontStyle(.num6)
            .foregroundColor(labelColor)
            .position(labelPosition)
    }
    
    private var labelPosition: CGPoint {
        let angle = CircularWheelCalculator.indexToAngle(index: index, type: type)
        let angleInRadians = (angle - 90) * .pi / 180
        let radius = circleSize / 2
        let labelDistance = radius + 20
        
        return CGPoint(
            x: radius + labelDistance * Foundation.cos(angleInRadians),
            y: radius + labelDistance * Foundation.sin(angleInRadians)
        )
    }
    
    private var labelColor: Color {
        if index == currentIndex {
            return Color.yellow1
        }
        
        if type == .tintMagentaGreen && circleSizeType == .medium {
            guard index >= 0 && index < CameraConstants.tintMagentaGreenValues.count else {
                return Color.g0
            }
            let value = CameraConstants.tintMagentaGreenValues[index]
            return value % 3 != 0 ? Color.g7 : Color.g0
        }
        
        return Color.g0
    }
}
