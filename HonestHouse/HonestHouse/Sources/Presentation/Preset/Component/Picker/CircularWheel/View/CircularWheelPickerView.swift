//
//  CircularWheelPickerView.swift
//  HonestHouse
//
//  Created by Subeen on 11/10/25.
//

import SwiftUI

// ExpandableWheel + ExpandableButton을 오버레이
struct CircularWheelPickerView: View {
    
    @Binding var preset: Preset
    @State var vm: CircularWheelViewModel
    @State var index: Int = 0
    private let coordinateSpaceName = "circleExpandSpace"

    
    var body: some View {
        VStack {
            valueView()
            ExpandableButton(viewModel: vm, value: $index, coordinateSpace: coordinateSpaceName)
                .overlay {
                    if vm.isCircleVisible {
                        ExpandableWheel(
                            viewModel: vm,
                            index: $index,
                            preset: $preset,
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
            CircularWheelPickerView(preset: .constant(.stub1), vm: .init(settingType: .tintMagentaGreen, isDimmed: .constant(true)))
            Spacer()
            CircularWheelPickerView(preset: .constant(.stub2), vm: .init(settingType: .exposureCompensation, isDimmed: .constant(false)))
            Spacer()
            CircularWheelPickerView(preset: .constant(.stub3), vm: .init(settingType: .colorTemperature, isDimmed: .constant(false)))
        }
    }
    .preferredColorScheme(.dark)
}
