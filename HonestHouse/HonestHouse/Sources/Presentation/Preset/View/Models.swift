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

enum ButtonState {
    case active     // 흰색 - 수정 가능
    case disabled   // 검정색 - 비활성화/Auto
    case viewOnly   // 노란색 - 조회 전용
}

enum SettingType: String {
    case cameraMode = "Camera Mode"
    case aperture = "f"
    case shutterSpeed = "s"
    case iso = "ISO"
    case pictureStyle = "Style"
    
    case tintMagentaGreen = "TintMG"
    case exposure = "Exp"
    case colorTemp = "Temp"
}
