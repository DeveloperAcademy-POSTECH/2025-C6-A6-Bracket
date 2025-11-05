//
//  CustomWheelPickerView.swift
//  HonestHouse
//
//  Created by Subeen on 11/4/25.
//

import SwiftUI

@available(iOS 18.0, *)
struct CustomWheelPickerView: View {
    @State private var selectedAperture: String = ApertureData.defaultAperture
    
    private let apertureData = ApertureData()
    
    var body: some View {
        VStack(spacing: 0) {
            CustomWheelPicker(
                items: ApertureData.standardApertures,
                selection: $selectedAperture,
                config: .init(
                    spacing: apertureData.spacing,
                    itemSize: apertureData.itemSize
                )
            ) { aperture in
                Text(aperture)
                    .font(.num4)
                    .foregroundStyle(aperture == selectedAperture ? Color.yellow1 : Color.g0)
                    .animation(.easeInOut(duration: 0.2), value: selectedAperture)
                    .frame(width: apertureData.itemSize.width,
                           height: apertureData.itemSize.height)
            }
            .frame(height: 52)
            .overlay {
                VStack {
                    Rectangle()
                        .frame(width: 1, height: 8)
                        .foregroundStyle(Color.g0)
                    
                    Spacer()
                    
                    Rectangle()
                        .frame(width: 1, height: 8)
                        .foregroundStyle(Color.g0)
                }
                .allowsHitTesting(false)
            }
            .overlay(
                LinearGradient(
                    colors: [
                        Color.g12,
                        .clear,
                        .clear,
                        Color.g12
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .allowsHitTesting(false)
            )
            .clipShape(RoundedRectangle(cornerRadius: 100))
            .overlay {
                RoundedRectangle(cornerRadius: 100)
                    .strokeBorder(Color.g0, lineWidth: 1)
                    .allowsHitTesting(false)
            }
        }
    }
}

#Preview {
    if #available(iOS 18.0, *) {
        CustomWheelPickerView()
    } else { }
}
