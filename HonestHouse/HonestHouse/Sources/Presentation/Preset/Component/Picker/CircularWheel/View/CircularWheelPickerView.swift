//
//  CircularWheelPickerView.swift
//  HonestHouse
//
//  Created by Subeen on 11/10/25.
//

import SwiftUI

struct CircularWheelPickerView: View {
    @Binding var preset: Preset
    @State var vm: CircularWheelViewModel
    @State var index: Int = 0
    
    // 휠 상태 매니저
    @Environment(WheelStateManager.self) private var wheelManager
    
    private let coordinateSpaceName = "circleExpandSpace"
    
    // 이 휠이 dim 되어야 하는지 확인
    private var shouldBeDimmed: Bool {
        wheelManager.shouldDim(vm.settingType)
    }
    
    // 이 휠이 활성화되어 있는지 확인
    private var isActive: Bool {
        wheelManager.isActive(vm.settingType)
    }
    
    var body: some View {
        VStack {
            valueView()
                .opacity(shouldBeDimmed ? 0.5 : 1)
                .blur(radius: shouldBeDimmed ? 3 : 0)
            
            ExpandableButton(
                viewModel: vm,
                value: $index,
                coordinateSpace: coordinateSpaceName
            )
            .overlay {
                if vm.isCircleVisible && isActive {
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
            .opacity(shouldBeDimmed ? 0.5 : 1)
            .blur(radius: shouldBeDimmed ? 3 : 0)
            .allowsHitTesting(!shouldBeDimmed)
        }
        .onChange(of: vm.isCircleVisible) { _, isVisible in
            if isVisible {
                wheelManager.activateWheel(vm.settingType)
            } else if isActive {
                wheelManager.deactivateWheel()
            }
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
            CircularWheelPickerView(preset: .constant(.stub1), vm: .init(settingType: .tintMagentaGreen))
            Spacer()
            CircularWheelPickerView(preset: .constant(.stub2), vm: .init(settingType: .exposureCompensation))
            Spacer()
            CircularWheelPickerView(preset: .constant(.stub3), vm: .init(settingType: .colorTemperature))
        }
    }
    .preferredColorScheme(.dark)
    .environment(WheelStateManager())
}
