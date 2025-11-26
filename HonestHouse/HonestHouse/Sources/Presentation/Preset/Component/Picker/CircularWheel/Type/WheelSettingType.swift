//
//  WheelSettingType.swift
//  HonestHouse
//
//  Created by Subeen on 11/13/25.
//

import Foundation
import SwiftUI

// Circular Wheel Picker로 값을 정하는 틴트, 노출, 색온도 타입
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
            return -30
        case .exposureCompensation:
            return -65
        case .colorTemperature:
            return -130
        }
    }
    
    var maxAngle: Double {
        switch self {
        case .tintMagentaGreen:
            return 130
        case .exposureCompensation:
            return 65
        case .colorTemperature:
            return 30
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
            return CameraConstants.tintMagentaGreenValues[index].withSign
            
        case .exposureCompensation:
            guard index >= 0 && index < CameraConstants.exposureCompensationValues.count else { return "0" }
            return CameraConstants.exposureCompensationValues[index]
            
        case .colorTemperature:
            guard index >= 0 && index < CameraConstants.colorTemperatureValues.count else { return "0" }
            return "\(CameraConstants.colorTemperatureValues[index])K"
        }
    }
}
