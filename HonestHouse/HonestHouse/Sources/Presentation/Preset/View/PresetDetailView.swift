//
//  PresetDetailView.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/27/25.
//

import SwiftUI
import SwiftData

struct PresetDetailView: View {
    @State private var wheelManager = WheelStateManager()
    @State var vm: PresetDetailViewModel
    @State private var showDeleteAlert = false
    @State private var showUnsavedChangesAlert = false
    @FocusState private var isNameFieldFocused: Bool
    
    var body: some View {
        ZStack {
            Color.g12.ignoresSafeArea(.all)
        
            VStack(spacing: 0) {
                nameView()
                previewView()
                
                ZStack {
                    if wheelManager.isAnyWheelActive {
                        Color.black
                            .opacity(0.8)
                            .onTapGesture {
                                wheelManager.deactivateWheel()
                            }
                        .ignoresSafeArea()
                    }
                    
                    settingsView()
                }
            }
        }
        .environment(wheelManager)
        .navigationBarWithBack(title: "", showShadow: false) {
            if vm.viewMode == .create {
                showUnsavedChangesAlert = true
            } else if vm.hasUnsavedChanges() {
                showUnsavedChangesAlert = true
            } else {
                vm.send(.popToPresetView)
            }
        } rightView: {
            if vm.viewMode == .create {
                saveButtonView()
            }
        }
        .alert("변경사항 저장", isPresented: $showUnsavedChangesAlert) {
            Button("삭제하기", role: .destructive) {
                vm.send(.popToPresetView)
            }
            Button("취소", role: .cancel) { }
        } message: {
            Text("이 프리셋이 저장되지 않았습니다.\n정말 나가시겠습니까?")
        }
        .customAlert(
            title: "정말 삭제하시겠습니까?",
            isPresented: $vm.showDeleteAlert
        ) {
            AlertButton.cancel("취소")
            AlertButton.delete("삭제하기") {
                // TODO: 삭제 기능 구현 후 vm.deletePreset() 호출
                // vm.deletePreset()
            }
        }
        .customErrorAlert(error: $vm.currentError) { error in
            switch error {
            case .cameraDisconnected:
                AlertButton.cancel("확인") {
                    vm.useDefaultPreset()
                }
                AlertButton.default("재시도") {
                    vm.retryFetchCameraSettings()
                }
            case .cameraBusy:
                AlertButton.default("재시도") {
                    vm.retryFetchCameraSettings()
                }
            case .cameraSettingsFetchFailed:
                AlertButton.cancel("확인") {
                    vm.useDefaultPreset()
                }
                AlertButton.default("재시도") {
                    vm.retryFetchCameraSettings()
                }
            case .settingApplicationFailed:
                AlertButton.cancel("확인")
            default:
                AlertButton.cancel("확인") {
                    vm.useDefaultPreset()
                }
                AlertButton.default("재시도") {
                    vm.retryFetchCameraSettings()
                }
            }
        }
        .overlay {
            if vm.isLoading {
                ProgressWithTextView(text: "카메라 설정값 가져오는 중")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.8))
            }
        }
        .task {
            if vm.viewMode == .create {
                await vm.fetchCurrentCameraSettings()
            }
        }
    }
    
    private func saveButtonView() -> some View {
        Button {
            Task {
                try await vm.savePreset()
            }
            vm.send(.popToPresetView)
        } label: {
            Text("저장")
                .foregroundStyle(Color.g0)
        }
    }

    // TODO: 임의로 구현해둔 deleteButton이므로 추후 수정 필요
    private func deleteButtonView() -> some View {
        Button {
            vm.showDeleteAlert = true
        } label: {
            Image(systemName: "trash")
                .foregroundStyle(Color.red1)
        }
    }
    
    private func nameView() -> some View {
        HStack() {
            if vm.viewMode == .view {
                Text(vm.currentPreset.name)
                    .fontStyle(.num2)
                    .foregroundStyle(Color.g0)
                    .lineLimit(1)
                    .truncationMode(.tail)
            } else {
                PresetNameTextFieldView(placeholder: "프리셋 이름", text: $vm.currentPreset.name)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .onTapGesture {
            if vm.viewMode != .view {
                isNameFieldFocused = true
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func previewView() -> some View {
        LiveStreamView(vm: LiveStreamViewModel(container: vm.container))
            .frame(height: 274)
    }
    
    private func settingsView() -> some View {
        VStack(spacing: 52) {
            primarySettingsView()
                .blur(radius: wheelManager.isAnyWheelActive ? 3 : 0)
                .opacity(wheelManager.isAnyWheelActive ? 0.5 : 1)
                .allowsHitTesting(!wheelManager.isAnyWheelActive)
            
            if let activePicker = vm.activePicker {
                pickerView(for: activePicker)
                    .blur(radius: wheelManager.isAnyWheelActive ? 3 : 0)
                    .opacity(wheelManager.isAnyWheelActive ? 0.5 : 1)
                    .allowsHitTesting(!wheelManager.isAnyWheelActive)
            }
            
            secondarySettingsSView()
        }
        .frame(maxHeight: .infinity)
        .padding(.horizontal, 20)
        .padding(.top, 30)
    }
    
    // Primary Settings Section
    private func primarySettingsView() -> some View {
        HStack(alignment: .bottom, spacing: 20) {
            
            // 촬영 모드
            ShootingModeSettingButtonView(
                selectedMode: Binding(
                    get: {
                        return vm.currentPreset.shootingMode
                    },
                    set: { newValue in
                        vm.changeCameraMode(to: newValue)
                    }
                ),
                isEnabled: vm.viewMode != .view
            )
            
            // Aperture (조리개)
            SettingButtonView(
                type: .aperture,
                state: vm.getButtonState(for: .aperture),
                viewMode: vm.viewMode,
                value: vm.currentPreset.displayAperture,
                isSelected: vm.activePicker == .aperture,
                action: {
                    handleSettingButtonTap(.aperture)
                }
            )
            
            // Shutter Speed (셔터 스피드)
            SettingButtonView(
                type: .shutterSpeed,
                state: vm.getButtonState(for: .shutterSpeed),
                viewMode: vm.viewMode,
                value: vm.currentPreset.displayShutterSpeed,
                isSelected: vm.activePicker == .shutterSpeed,
                action: {
                    handleSettingButtonTap(.shutterSpeed)
                }
            )
            
            // ISO
            SettingButtonView(
                type: .iso,
                state: vm.getButtonState(for: .iso),
                viewMode: vm.viewMode,
                value: vm.currentPreset.displayISO,
                isSelected: vm.activePicker == .iso,
                action: {
                    handleSettingButtonTap(.iso)
                }
            )
            
            // Picture Style (픽처 스타일)
            SettingButtonView(
                type: .pictureStyle,
                state: vm.getButtonState(for: .pictureStyle),
                viewMode: vm.viewMode,
                value: vm.currentPreset.pictureStyle.rawValue,
                isSelected: vm.activePicker == .pictureStyle,
                action: {
                    handleSettingButtonTap(.pictureStyle)
                }
            )
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private func pickerView(for type: PresetSettingType) -> some View {
        switch type {
        case .cameraMode:
            NonOptionalLinearWheelPickerView(
                selectedValue: Binding(
                    get: { vm.currentPreset.shootingMode },
                    set: { newValue in
                        vm.changeCameraMode(to: newValue)
                    }
                ),
                items: vm.getCameraShootingModeValues(),
                config: .init(
                    spacing: 22,
                    itemSize: .init(width: 50, height: 24)
                )
            )

        case .aperture:
            if vm.currentPreset.shootingMode == .av {
                LinearWheelPickerView(
                    selectedValue: Binding(
                        get: { vm.currentPreset.aperture },
                        set: { newValue in
                            Logger.info("Aperture binding set called: \(newValue ?? "nil")", category: .preset)
                            vm.currentPreset.aperture = newValue
                            guard vm.viewMode != .view, let newValue = newValue else {
                                Logger.warning("View mode is .view or newValue is nil, skipping camera setting application", category: .preset)
                                return
                            }
                            Task {
                                await vm.applyCameraSettings(for: .aperture, value: newValue)
                            }
                        }
                    ),
                    items: vm.getApertureValues(),
                    config: .init(
                        spacing: 22,
                        itemSize: .init(width: 50, height: 24)
                    )
                )
            }
            
        case .shutterSpeed:
            if vm.currentPreset.shootingMode == .tv {
                LinearWheelPickerView(
                    selectedValue: Binding(
                        get: { vm.currentPreset.shutterSpeed },
                        set: { newValue in
                            Logger.info("Shutter speed binding set called: \(newValue ?? "nil")", category: .preset)
                            vm.currentPreset.shutterSpeed = newValue
                            guard vm.viewMode != .view, let newValue = newValue else {
                                Logger.warning("View mode is .view or newValue is nil, skipping camera setting application", category: .preset)
                                return
                            }
                            Task {
                                await vm.applyCameraSettings(for: .shutterSpeed, value: newValue)
                            }
                        }
                    ),
                    items: vm.getShutterSpeedValues(),
                    config: .init(
                        spacing: 22,
                        itemSize: .init(width: 60, height: 24)
                    )
                )
            }
            
        case .iso:
            LinearWheelPickerView(
                selectedValue: Binding(
                    get: { vm.currentPreset.iso },
                    set: { newValue in
                        Logger.info("ISO binding set called: \(newValue ?? "nil")", category: .preset)
                        vm.currentPreset.iso = newValue
                        guard vm.viewMode != .view, let newValue = newValue else {
                            Logger.warning("View mode is .view or newValue is nil, skipping camera setting application", category: .preset)
                            return
                        }
                        Task {
                            await vm.applyCameraSettings(for: .iso, value: newValue)
                        }
                    }
                ),
                items: vm.getISOValues(),
                config: .init(
                    spacing: 22,
                    itemSize: .init(width: 50, height: 24)
                )
            )
            
        case .pictureStyle:
            NonOptionalLinearWheelPickerView(
                selectedValue: Binding(
                    get: { vm.currentPreset.pictureStyle },
                    set: { newValue in
                        Logger.info("Picture style binding set called: \(newValue)", category: .preset)
                        vm.currentPreset.pictureStyle = newValue
                        guard vm.viewMode != .view else {
                            Logger.warning("View mode is .view, skipping camera setting application", category: .preset)
                            return
                        }
                        Task {
                            await vm.applyCameraSettings(for: .pictureStyle, value: newValue)
                        }
                    }
                ),
                items: vm.getPictureStyleValues(),
                config: .init(
                    spacing: 6,
                    itemSize: .init(width: 90, height: 24)
                )
            )
            
        default:
            Spacer()
                .frame(height: 52)
        }
    }
    
    // Secondary Settings Section
    private func secondarySettingsSView() -> some View {
        HStack(alignment: .center, spacing: 54) {
            // Tint Magenta Green (마젠타-그린)
            CircularWheelPickerView(
                preset: $vm.currentPreset,
                vm: .init(viewMode: vm.viewMode, settingType: .tintMagentaGreen),
                buttonState: vm.getButtonState(for: .tintMagentaGreen)
            )
            
            // Exposure Compensation (노출 보정)
            CircularWheelPickerView(
                preset: $vm.currentPreset,
                vm: .init(viewMode: vm.viewMode, settingType: .exposureCompensation),
                buttonState: vm.getButtonState(for: .exposure)
            )
            
            // Color Temperature (색온도)
            CircularWheelPickerView(
                preset: $vm.currentPreset,
                vm: .init(viewMode: vm.viewMode, settingType: .colorTemperature),
                buttonState: vm.getButtonState(for: .colorTemp)
            )
        }
        .frame(maxWidth: .infinity)
    }
    
    private func handleSettingButtonTap(_ type: PresetSettingType) {
        // View 모드는 일단 무시 (나중에 Edit 전환 구현 예정)
        guard vm.viewMode != .view else {
            return
        }

        // 편집 불가능한 설정은 무시
        guard vm.isSettingEditable(type) else {
            return
        }
        
        // Picker 토글
        if vm.activePicker == type {
            vm.activePicker = nil
        } else {
            vm.activePicker = type
        }
    }
}

#Preview("View Mode") {
    PresetDetailView(vm: .init(container: .stub, mode: .view, preset: .stub1))
}

#Preview("Edit Mode") {
    PresetDetailView(vm: .init(container: .stub, mode: .edit, preset: .stub2))
}

#Preview("Create Mode") {
    PresetDetailView(vm: .init(container: .stub, mode: .create, preset: .stub3))
}
