//
//  CircularWheelPickerView.swift
//  HonestHouse
//
//  Created by Subeen on 11/10/25.
//

import SwiftUI

// ExpandableWheel + ExpandableButton을 오버레이
struct CircularWheelPickerView: View {
    
    @State var vm: CircularWheelViewModel
    private let coordinateSpaceName = "circleExpandSpace"
    
    @State var index: Int = 0
    
    var body: some View {
        VStack {
            valueView()
            ExpandableButton(viewModel: vm, value: $index, coordinateSpace: coordinateSpaceName)
                .overlay {
                    if vm.isCircleVisible {
                        ExpandableWheel(
                            viewModel: vm,
                            index: $index,
                            type: vm.settingType,
                            isVisible: vm.isCircleVisible
                        )
                    }
                }
                .coordinateSpace(name: coordinateSpaceName)
        }
    }
    
    private func valueView() -> some View {
        Text(vm.settingType.formatValue(index))
            .fontStyle(.num6)
            .foregroundStyle(Color.g0)
    }
    
}

#Preview {
    ZStack {
        Color.g12
        HStack {
            CircularWheelPickerView(vm: .init(settingType: .tintMagentaGreen, isDimmed: .constant(true)))
            Spacer()
            CircularWheelPickerView(vm: .init(settingType: .exposureCompensation, isDimmed: .constant(false)))
            Spacer()
            CircularWheelPickerView(vm: .init(settingType: .colorTemperature, isDimmed: .constant(false)))
        }
    }
    .preferredColorScheme(.dark)
}
