//
//  OptionsMenuView.swift
//  HonestHouse
//
//  Created by Subeen on 11/19/25.
//

import SwiftUI

struct MenuItem {
    let icon: ImageResource
    let label: String
    let action: () -> Void
}

struct OptionsMenuView: View {
    let items: [MenuItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(items.indices, id: \.self) { index in
                Button {
                    items[index].action()
                } label: {
                    HStack(spacing: 10) {
                        Image(items[index].icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        Text(items[index].label)
                            .fontStyle(.num3)
                            .foregroundStyle(Color.g0)
                    }
                }
                
                if index < items.count - 1 {
                    Divider()
                        .foregroundStyle(Color.g7)
                        .frame(height: 0.5)
                }
            }
        }
        .frame(width: 250)
        .padding(.vertical, 24)
        .padding(.horizontal, 21)
        .background {
            VisualEffectBlurView()
                .blur(radius: 6, opaque: true)
                .overlay {
                    (Color.g10.opacity(0.8))
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(radius: 20, x: 0, y: 4)
    }
}

#Preview {
    OptionsMenuView(items: [
        .init(icon: .addressIcon, label: "bb", action: { }),
        .init(icon: .addressIcon, label: "bb", action: { })
    ])
}
