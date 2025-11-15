//
//  ShootingModeSettingButtonView.swift
//  HonestHouse
//
//  Created by Subeen on 11/16/25.
//

import SwiftUI

struct ShootingModeSettingButtonView: View {
    @Binding var selectedMode: ShootingModeType
    let isEnabled: Bool
    
    var body: some View {
        Button {
            if isEnabled {
                toggleMode()
            }
        } label: {
            Text(selectedMode.rawValue)
                .font(.num4)
                .foregroundStyle(Color.g0)
                .frame(width: 64, height: 64)
                .background(Color.g12)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .strokeBorder(isEnabled ? Color.g0 : Color.g7, lineWidth: 1)
                }
        }
        .disabled(!isEnabled)
//        .opacity(isEnabled ? 1.0 : 0.5)
        .sensoryFeedback(.selection, trigger: selectedMode)
        .buttonStyle(NoHighlightButtonStyle())
    }
    
    private func toggleMode() {
        let allModes = ShootingModeType.allCases
        if let currentIndex = allModes.firstIndex(of: selectedMode) {
            let nextIndex = (currentIndex + 1) % allModes.count
            selectedMode = allModes[nextIndex]
        }
    }
}
