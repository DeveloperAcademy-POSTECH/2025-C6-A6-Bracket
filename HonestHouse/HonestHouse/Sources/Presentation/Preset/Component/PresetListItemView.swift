//
//  PresetListItemView.swift
//  HonestHouse
//
//  Created by Subeen on 11/6/25.
//

import SwiftUI

struct PresetListItem: View {
    let preset: Preset
    let isSelected: Bool
    let isEditMode: Bool
    let onTap: () -> Void
    let onActionTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Spacer()
                VStack(alignment: .center, spacing: 12) {
                    
                    titleView()
                    iconListView()
                    settingDescriptionView()
                    
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
        }
        .buttonStyle(NoHighlightButtonStyle())
    }
    
    func titleView() -> some View {
        Text(preset.name)
            .font(.num6)
            .foregroundColor(.white)
    }
    
    func iconListView() -> some View {
        HStack(spacing: 4) {
            Circle().frame(width: 32, height: 32)
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

    }
}

#Preview {
    VStack(spacing: 20) {
        PresetListItem(
            preset: .stub1,
            isSelected: false,
            isEditMode: false,
            onTap: {},
            onActionTap: {}
        )
        
        PresetListItem(
            preset: .stub2,
            isSelected: true,
            isEditMode: false,
            onTap: {},
            onActionTap: {}
        )
        
        PresetListItem(
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
