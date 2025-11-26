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
    let baseButtonState: PresetButtonState
    let presetViewModel: PresetDetailViewModel
    
    @Environment(WheelStateManager.self) private var wheelManager
    
    private let coordinateSpaceName = "circleExpandSpace"
    
    private var shouldBeDimmed: Bool {
        wheelManager.shouldDim(vm.settingType)
    }
    
    private var isActive: Bool {
        wheelManager.isActive(vm.settingType)
    }
    
    // 동적으로 계산되는 버튼 상태
    private var currentButtonState: PresetButtonState {
        // View 모드는 기본 상태 유지
        guard vm.viewMode != .view else {
            return baseButtonState
        }
        
        // Dragging 중이거나 Circle이 보이면 selected
        if vm.isActiveState {
            return .selected
        }
        
        return baseButtonState
    }
    
    var body: some View {
        VStack {
            valueView()
                .opacity(shouldBeDimmed ? 0.5 : 1)
                .blur(radius: shouldBeDimmed ? 3 : 0)
            
            ExpandableButton(
                viewModel: vm,
                value: $index,
                coordinateSpace: coordinateSpaceName,
                buttonState: currentButtonState,
                viewMode: vm.viewMode
            )
            .overlay {
                if vm.isCircleVisible && isActive {
                    ExpandableWheel(
                        viewModel: vm,
                        index: $index,
                        preset: $preset,
                        type: vm.settingType,
                        isVisible: vm.isCircleVisible,
                        presetViewModel: presetViewModel
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
        .onChange(of: presetViewModel.isLoading) { _, isLoading in
            // fetchCurrentCameraSettings 완료 후 index 업데이트
            if !isLoading {
                updateIndexFromPreset()
            }
        }
    }
    
    private func updateIndexFromPreset() {
        let newIndex: Int
        switch vm.settingType {
        case .tintMagentaGreen:
            let value = preset.tintMagentaGreen ?? 0
            newIndex = CameraConstants.tintMagentaGreenValues.firstIndex(of: value) ?? 9
            
        case .exposureCompensation:
            let value = preset.exposureCompensation ?? "+0.0"
            newIndex = CameraConstants.exposureCompensationValues.firstIndex(of: value) ?? 9
            
        case .colorTemperature:
            let value = preset.colorTemperature ?? 2500
            newIndex = CameraConstants.colorTemperatureValues.firstIndex(of: value) ?? 0
        }
        
        if index != newIndex {
            index = newIndex
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
            CircularWheelPickerView(
                preset: .constant(.stub1),
                vm: .init(viewMode: .create, settingType: .tintMagentaGreen),
                baseButtonState: .activated,
                presetViewModel: .init(container: .stub, mode: .create, preset: .stub1)
            )
            Spacer()
            CircularWheelPickerView(
                preset: .constant(.stub2),
                vm: .init(viewMode: .create, settingType: .exposureCompensation),
                baseButtonState: .activated,
                presetViewModel: .init(container: .stub, mode: .create, preset: .stub2)
            )
            Spacer()
            CircularWheelPickerView(
                preset: .constant(.stub3),
                vm: .init(viewMode: .create, settingType: .colorTemperature),
                baseButtonState: .activated,
                presetViewModel: .init(container: .stub, mode: .create, preset: .stub3)
            )
        }
    }
    .preferredColorScheme(.dark)
    .environment(WheelStateManager())
}
