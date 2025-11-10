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
        HStack {
            ForEach(WheelSettingType.allCases, id: \.self) { item in
                ExpandableCircleView(vm: .init(settingType: item, isDimmed: $isDimmed))
            }
        }
    }
}

#Preview {
    ZStack {
        Color.g12
        CircularWheelTestView()
    }
}
