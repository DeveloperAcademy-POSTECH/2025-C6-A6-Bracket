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
        HStack {
            Spacer()
            VStack(alignment: .center, spacing: 12) {
                nameView()
                iconListView()
                settingDescriptionView()
            if isEditMode && isSelected {
                selectedCapsuleView()
            } else {
                defaultCapsuleView()
            }
            Spacer()
            applyButtonView()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .padding(.trailing, 8)
        .background(Color.g11)
        .clipShape(
            RoundedRectangle(cornerRadius: 100)
        )
        .onTapGesture {
            onTap()
        }
    }
    
    func nameView() -> some View {
        Text(preset.name)
            .font(.num6)
            .foregroundColor(.white)
            .lineLimit(1)
            .padding(.horizontal, 40)
    }
    
    func iconListView() -> some View {
        HStack(spacing: 4) {
            Circle().frame(width: 32, height: 32)
            Circle().frame(width: 32, height: 32)
            Circle().frame(width: 32, height: 32)
            Circle().frame(width: 32, height: 32)
            Circle().frame(width: 32, height: 32)
        }
    }
    
    func settingDescriptionView() -> some View {
        HStack(spacing: 8) {
            if let modeDescription = preset.modeDescription {
                Text(modeDescription)
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
            
            Text(preset.isoDescription)
            
        }
        .font(.num6)
        .foregroundStyle(Color.g0)
    }
    
    func applyButtonView() -> some View {
        Button(action: onActionTap) {
            Image(systemName: "circle")
                .font(.system(size: 24))
                .foregroundColor(.white.opacity(0.7))
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
