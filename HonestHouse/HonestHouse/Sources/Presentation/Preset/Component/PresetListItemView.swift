//
//  PresetListItemView.swift
//  HonestHouse
//
//  Created by Subeen on 11/6/25.
//

import SwiftUI

struct PresetListItemView: View {
    let preset: Preset
    let isSelected: Bool
    let isEditMode: Bool
    let onTap: () -> Void
    let onActionTap: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            HStack {
                titleView()
                Spacer()
                applyButtonView()
            }
            if isEditMode && isSelected {
                selectedCapsuleView()
            } else {
                defaultCapsuleView()
            }
        }
    }
    
    func titleView() -> some View {
        Text(preset.name)
            .font(.num4)
            .foregroundStyle(Color.g0)
    }
    
    func applyButtonView() -> some View {
        Button {
            onActionTap()
        } label: {
            if isEditMode {
                Image(isSelected ? .checkSelectBtnS : .checkUnselectBtnS)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            } else {
                Image(.cameraSend)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
        }
    }
    
    func defaultCapsuleView() -> some View {
        PresetCapsuleView(preset: preset)
            .background(
                Capsule()
                    .fill(Color.g11)
            )
            .contentShape(Capsule())
            .onTapGesture {
                onTap()
            }
    }
    
    func selectedCapsuleView() -> some View {
        PresetCapsuleView(preset: preset)
            .background(
                Capsule()
                    .fill(Color.g11)
            )
            .overlay(
                Capsule()
                    .strokeBorder(Color.yellow1, lineWidth: 1)
            )
            .contentShape(Capsule())
            .onTapGesture {
                onTap()
            }
    }
}

#Preview {
    VStack(spacing: 20) {
        PresetListItemView(
            preset: .stub1,
            isSelected: false,
            isEditMode: false,
            onTap: {},
            onActionTap: {}
        )
        
        PresetListItemView(
            preset: .stub2,
            isSelected: true,
            isEditMode: false,
            onTap: {},
            onActionTap: {}
        )
        
        PresetListItemView(
            preset: .stub3,
            isSelected: false,
            isEditMode: true,
            onTap: {},
            onActionTap: {}
        )
    }
    .padding()
    .background(Color.gray)
}
