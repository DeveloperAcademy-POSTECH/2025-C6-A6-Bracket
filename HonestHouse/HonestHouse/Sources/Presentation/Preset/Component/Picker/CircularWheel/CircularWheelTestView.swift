//
//  CircularWheelTestView.swift
//  HonestHouse
//
//  Created by Subeen on 11/11/25.
//

import SwiftUI

struct CircularWheelTestView: View {
    @State private var isDimmed = false
    
    var body: some View {
        VStack {
//            Spacer()
            HStack {
//                ForEach(WheelSettingType.allCases, id: \.self) { item in
                CircularWheelPickerView(preset: .constant(.stub1), vm: .init(settingType: WheelSettingType.tintMagentaGreen, isDimmed: $isDimmed))
                        .frame(maxWidth: .infinity)
                    
//                }
                .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.g12.ignoresSafeArea(.all)
        CircularWheelTestView()
            
    }
}
