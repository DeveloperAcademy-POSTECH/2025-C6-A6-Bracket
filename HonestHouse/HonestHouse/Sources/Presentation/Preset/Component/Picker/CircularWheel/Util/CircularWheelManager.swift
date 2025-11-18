//
//  CIrcularWheelManager.swift
//  HonestHouse
//
//  Created by Subeen on 11/18/25.
//

import SwiftUI

@Observable
final class WheelStateManager {
    var activeWheelType: WheelSettingType? = nil
    var isDimmed: Bool = false
    
    var isAnyWheelActive: Bool {
        activeWheelType != nil
    }
    
    func activateWheel(_ type: WheelSettingType) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            activeWheelType = type
            isDimmed = true
        }
    }
    
    func deactivateWheel() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            activeWheelType = nil
            isDimmed = false
        }
    }
    
    func isActive(_ type: WheelSettingType) -> Bool {
        activeWheelType == type
    }
    
    func shouldDim(_ type: WheelSettingType) -> Bool {
        activeWheelType != nil && activeWheelType != type
    }
    
    func shouldShowWheel(_ type: WheelSettingType) -> Bool {
        activeWheelType == type
    }
}
