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


// TODO: 데이터 옵셔널 케이스 처리해서 하나로 합칠 예정
struct LinearWheelPickerView<SelectionValue>: View where SelectionValue: Hashable & Sendable {

    @Binding var selectedValue: SelectionValue?
    let items: [SelectionValue]
    let config: Config
    
    var body: some View {
        VStack(spacing: 0) {
            LinearWheelPicker(
                items: items,
                selection: $selectedValue,
                config: config
            ) { value in
                
                if let value = value {
                    
                    if let pictureStyle = value as? PictureStyleType {
                        Text("\(pictureStyle.rawValue)")
                        .font(.num4)
                        .foregroundStyle(value == selectedValue ? Color.g12 : Color.g0)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
//                        .frame(height: config.itemSize.height)
                        .background(value == selectedValue ? Color.g0 : Color.g12)
                        .clipShape(RoundedRectangle(cornerRadius: 100))
                        .animation(.easeInOut(duration: 0.2), value: selectedValue)
                        .overlay {
                            RoundedRectangle(cornerRadius: 100)
                                .strokeBorder(Color.g0, lineWidth: 1)
                        }
                        
                    } else {
                        Text("\(value)")
                        .font(.num4)
                        .foregroundStyle(value == selectedValue ? Color.yellow1 : Color.g0)
                        .animation(.easeInOut(duration: 0.2), value: selectedValue)
                        .frame(width: config.itemSize.width,
                               height: config.itemSize.height)
                    }
                    
                        
                }
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

struct NonOptionalLinearWheelPickerView<SelectionValue>: View
where SelectionValue: Hashable & Sendable {
    @Binding var selectedValue: SelectionValue  // Non-Optional
    let items: [SelectionValue]
    let config: Config
    
    var body: some View {
        LinearWheelPickerView(
            selectedValue: Binding(
                get: { self.selectedValue },
                set: { self.selectedValue = $0 ?? self.selectedValue }
            ),
            items: items,
            config: config
        )
    }
}

#Preview("Double") {
    LinearWheelPickerView(selectedValue: .constant("1.0"), items: CameraConstants.apertureValues, config: .init(spacing: 22, itemSize: .init(width: 50, height: 24)))

}


#Preview("Int") {
    LinearWheelPickerView(selectedValue: .constant(1), items: CameraConstants.tintMagentaGreenValues, config: .init(spacing: 22, itemSize: .init(width: 50, height: 24)))
}

#Preview("PictureStyle") {
    LinearWheelPickerView(selectedValue: .constant(PictureStyleType.auto as PictureStyleType?), items: PictureStyleType.allCases, config: .init(spacing: 6, itemSize: .init(width: 100, height: 24)))
}
