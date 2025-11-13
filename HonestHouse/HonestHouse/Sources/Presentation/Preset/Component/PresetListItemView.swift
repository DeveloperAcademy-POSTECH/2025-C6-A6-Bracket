//
//  PresetListItemView.swift
//  HonestHouse
//
//  Created by Subeen on 11/6/25.
//

import SwiftUI

struct PresetListItemView: View {
    let preset: Preset
    let displayType: PresetCapsuleDisplayType
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
            capsuleView()
        }
    }
    
    func titleView() -> some View {
        Text(preset.name)
            .fontStyle(.num4)
            .foregroundStyle(Color.g0)
            .lineLimit(1)
    }
    
    func applyButtonView() -> some View {
        Button {
            onActionTap()
        } label: {
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
    
    func capsuleView() -> some View {
        PresetCapsuleView(preset: preset, displayType: displayType)
            .onTapGesture {
                onTap()
            }
    }
}

#Preview {
    VStack(spacing: 20) {
        PresetListItemView(
            preset: .stub1,
            displayType: .default,
            isEditMode: false,
            onTap: {},
            onActionTap: {}
        )
        
        PresetListItemView(
            preset: .stub2,
            displayType: .selected,
            isEditMode: true,
            onTap: {},
            onActionTap: {}
        )
        
        PresetListItemView(
            preset: .stub3,
            displayType: .currentlyApplied,
            isEditMode: false,
            onTap: {},
            onActionTap: {}
        )
    }
    .padding()
    .background(Color.gray)
}
