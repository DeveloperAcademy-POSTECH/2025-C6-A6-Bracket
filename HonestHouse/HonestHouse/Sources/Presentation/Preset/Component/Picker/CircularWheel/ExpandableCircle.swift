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
    let type: WheelSettingType
    let size: CGFloat
    let center: CGPoint
    let isVisible: Bool
    
    var body: some View {
        Circle()
            .stroke(type.strokeColor, lineWidth: 4)
            .frame(width: size, height: size)
            .position(center)
            .opacity(isVisible ? 1 : 0)
    }
}
