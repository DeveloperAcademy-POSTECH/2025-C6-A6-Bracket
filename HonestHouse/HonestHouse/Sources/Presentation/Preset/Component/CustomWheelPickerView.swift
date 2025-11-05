//
//  CustomWheelPickerView.swift
//  HonestHouse
//
//  Created by Subeen on 11/4/25.
//

import SwiftUI

struct Config {
    var spacing: CGFloat
    var itemSize: CGSize
}

struct CustomWheelPickerView<SelectionValue>: View where SelectionValue: Hashable & Sendable {

    @Binding var selectedValue: SelectionValue
    let items: [SelectionValue]
    let config: Config
    
    var body: some View {
        VStack(spacing: 0) {
            CustomWheelPicker(
                items: items,
                selection: $selectedValue,
                config: config
            ) { value in
                Text("\(value)")
                    .font(.num4)
                    .foregroundStyle(value == selectedValue ? Color.yellow1 : Color.g0)
                    .animation(.easeInOut(duration: 0.2), value: selectedValue)
                    .frame(width: config.itemSize.width,
                           height: config.itemSize.height)
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

#Preview("Double") {
    CustomWheelPickerView(selectedValue: .constant("1.0"), items: CameraConstants.apertureValues, config: .init(spacing: 22, itemSize: .init(width: 50, height: 24)))

}


#Preview("Int") {
    CustomWheelPickerView(selectedValue: .constant(1), items: CameraConstants.tintMagentaGreenValues    , config: .init(spacing: 22, itemSize: .init(width: 50, height: 24)))
}
