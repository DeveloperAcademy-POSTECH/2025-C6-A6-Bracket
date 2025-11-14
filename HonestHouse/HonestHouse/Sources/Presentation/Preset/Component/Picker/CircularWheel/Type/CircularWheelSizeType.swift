//
//  CircularWheelSizeType.swift
//  HonestHouse
//
//  Created by Subeen on 11/13/25.
//

import SwiftUI

// 휠의 사이즈 경계
enum CircularWheelSizeType {
    case small
    case medium
    case large
    
    var size: Double {
        switch self {
        case .small:
            return 120
        case .medium:
            return 260
        case .large:
            return 370
        }
    }
}
