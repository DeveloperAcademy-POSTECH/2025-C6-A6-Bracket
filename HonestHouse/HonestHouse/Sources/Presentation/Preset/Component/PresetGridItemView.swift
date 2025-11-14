//
//  PresetGridItem.swift
//  HonestHouse
//
//  Created by Subeen on 11/6/25.
//

import SwiftUI

struct PresetGridItemView: View {
    let preset: Preset
    let displayType: PresetCapsuleDisplayType
    let isEditMode: Bool
    let onTap: () -> Void
    let onActionTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                nameView()
                Spacer()
                applyButtonView()
            }
            .padding(.vertical, 20)
            .frame(maxHeight: 122)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.g11)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(displayType != .default ? Color.yellow1 : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(NoHighlightButtonStyle())
    }
    
    func nameView() -> some View {
        Text("\(preset.name)")
            .font(.num6)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .foregroundStyle(Color.g0)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
    }
    
    func applyButtonView() -> some View {
        Button(action: onActionTap) {
            if isEditMode {
                Image(displayType == .selected ? .checkSelectBtnS : .checkUnselectBtnS)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            } else {
                Image(.cameraSend)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(displayType == .currentlyApplied ? Color.yellow1 : Color.g0)
            }
        }
    }
}

#Preview {
    HStack(spacing: 10) {
        PresetGridItemView(
            preset: .stub1,
            displayType: .default,
            isEditMode: false,
            onTap: {},
            onActionTap: {}
        )
        
        PresetGridItemView(
            preset: .stub2,
            displayType: .selected,
            isEditMode: true,
            onTap: {},
            onActionTap: {}
        )
    }
    .padding()
    .background(Color.gray)
}
