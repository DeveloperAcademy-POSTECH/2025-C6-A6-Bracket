//
//  Models.swift
//  HonestHouse
//
//  Created by Subeen on 11/4/25.
//

import Foundation
import SwiftUI

enum PresetDetailViewMode {
    case view
    case edit
    case create
}

enum PresetButtonState {
    case activated      // 편집 가능 기본 상태 (Create/Edit)
    case selected       // 선택됨 (picker 열림 or View 모드 값 설정됨)
    case deactivated    // 편집 불가 (Auto/0)
}

extension PresetButtonState {
    // ViewMode에 따른 배경색
    func backgroundColor(viewMode: PresetDetailViewMode) -> Color {
        if viewMode == .view && self == .selected {
            return .yellow1
        }
        
        switch self {
        case .activated:
            return .g12
        case .selected:
            return .g0
        case .deactivated:
            return .g12
        }
    }
    
    // ViewMode에 따른 전경색
    func foregroundColor(viewMode: PresetDetailViewMode) -> Color {
        if viewMode == .view && self == .selected {
            return .g12
        }
        
        switch self {
        case .activated:
            return .g0
        case .selected:
            return .g12
        case .deactivated:
            return .g7
        }
    }
    
    // ViewMode에 따른 테두리색
    func strokeColor(viewMode: PresetDetailViewMode) -> Color {
        if viewMode == .view && self == .selected {
            return .clear
        }
        
        switch self {
        case .activated:
            return .g0
        case .selected:
            return .g0
        case .deactivated:
            return .g7
        }
    }
    
    // 상호작용 가능 여부
    var isInteractive: Bool {
        switch self {
        case .activated, .selected:
            return true
        case .deactivated:
            return false
        }
    }
}

enum PresetSettingType: String {
    case cameraMode = "Camera Mode"
    case aperture = "f"
    case shutterSpeed = "s"
    case iso = "ISO"
    case pictureStyle = "Style"
    
    case tintMagentaGreen = "TintMG"
    case exposure = "Exp"
    case colorTemp = "Temp"
}
