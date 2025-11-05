//
//  PresetGridItem.swift
//  HonestHouse
//
//  Created by Subeen on 11/6/25.
//

import SwiftUI

struct PresetGridItem: View {
    let preset: Preset
    let isSelected: Bool
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
            .background(Color.g11)
            .clipShape(RoundedRectangle(cornerRadius: 20))
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
            Image(systemName: "circle")
                .font(.system(size: 24))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

#Preview {
    HStack(spacing: 10) {
        PresetGridItem(
            preset: .stub1,
            isSelected: false,
            isEditMode: false,
            onTap: {},
            onActionTap: {}
        )
        
        PresetGridItem(
            preset: .stub2,
            isSelected: true,
            isEditMode: false,
            onTap: {},
            onActionTap: {}
        )
    }
    .padding()
    .background(Color.gray)
}
