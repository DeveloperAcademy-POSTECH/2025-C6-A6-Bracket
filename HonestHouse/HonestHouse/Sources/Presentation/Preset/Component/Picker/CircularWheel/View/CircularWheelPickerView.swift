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
        .onAppear {
            initializeIndex()
        }
        .onChange(of: preset.tintMagentaGreen) {
            if vm.settingType == .tintMagentaGreen {
                initializeIndex()
            }
        }
        .onChange(of: preset.exposureCompensation) {
            if vm.settingType == .exposureCompensation {
                initializeIndex()
            }
        }
        .onChange(of: preset.colorTemperature) {
            if vm.settingType == .colorTemperature {
                initializeIndex()
            }
        }
    }

    private func initializeIndex() {
        switch vm.settingType {
        case .tintMagentaGreen:
            if let value = preset.tintMagentaGreen,
               let idx = CameraConstants.tintMagentaGreenValues.firstIndex(of: value) {
                index = idx
            }

        case .exposureCompensation:
            if let value = preset.exposureCompensation,
               let idx = CameraConstants.exposureCompensationValues.firstIndex(of: value) {
                index = idx
            }

        case .colorTemperature:
            if let value = preset.colorTemperature,
               let idx = CameraConstants.colorTemperatureValues.firstIndex(of: value) {
                index = idx
            }
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
