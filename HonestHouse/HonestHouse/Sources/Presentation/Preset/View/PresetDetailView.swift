//
//  PresetDetailView.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/27/25.
//

import SwiftUI
import SwiftData

struct PresetDetailView: View {
    @State var vm: PresetDetailViewModel
    @State private var showUnsavedChangesAlert = false
    @FocusState private var isNameFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss // TODO: - vm에서 nvrouter로 관리
    
    var body: some View {
        ZStack {
            Color.g12.ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                nameView()
                previewView()
                settingsView()
            }
        }
        .navigationBarWithBack(title: "", showShadow: false) {
            if vm.viewMode == .create {
                showUnsavedChangesAlert = true
            } else if vm.hasUnsavedChanges() {
                showUnsavedChangesAlert = true
            } else {
                dismiss()
            }
        } rightView: {
            if vm.viewMode == .create {
                saveButtonView()
            }
        }
        // TODO: alert 변경
        .alert("변경사항 저장", isPresented: $showUnsavedChangesAlert) {
            Button("삭제하기", role: .destructive) {
                dismiss()
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
            
            if let activePicker = vm.activePicker {
                pickerView(for: activePicker)
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
                    get: { vm.currentPreset.shootingMode },
                    set: { vm.changeCameraMode(to: $0) }
                ),
                isEnabled: vm.viewMode != .view
            )
            
            // Aperture (조리개)
            SettingButtonView(
                type: .aperture,
                state: vm.getButtonState(for: .aperture),
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
                value: vm.currentPreset.displayISO,
                isSelected: vm.activePicker == .iso,
                action: {
                    handleSettingButtonTap(.iso)
                }
            )
            
            // Picture Style (픽쳐 스타일)
            SettingButtonView(
                type: .pictureStyle,
                state: vm.getButtonState(for: .pictureStyle),
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
    private func pickerView(for type: SettingType) -> some View {
        switch type {
        case .cameraMode:
            NonOptionalLinearWheelPickerView(
                selectedValue: $vm.currentPreset.shootingMode,
                items: vm.getCameraShootingModeValues(),
                config: .init(
                    spacing: 22,
                    itemSize: .init(width: 50, height: 24)
                )
            )
            
        case .aperture:
            if vm.currentPreset.shootingMode == .av {
                LinearWheelPickerView(
                    selectedValue: $vm.currentPreset.aperture,
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
                    selectedValue: $vm.currentPreset.shutterSpeed,
                    items: vm.getShutterSpeedValues(),
                    config: .init(
                        spacing: 22,
                        itemSize: .init(width: 60, height: 24)
                    )
                )
            }
            
        case .iso:
            LinearWheelPickerView(
                selectedValue: $vm.currentPreset.iso,
                items: vm.getISOValues(),
                config: .init(
                    spacing: 22,
                    itemSize: .init(width: 50, height: 24)
                )
            )
            
        case .pictureStyle:
            NonOptionalLinearWheelPickerView(
                selectedValue: $vm.currentPreset.pictureStyle,
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
            CircularWheelPickerView(preset: $vm.currentPreset, vm: .init(settingType: .tintMagentaGreen, isDimmed: $vm.isDimmed))
            
            // Exposure Compensation (노출 보정)
            CircularWheelPickerView(preset: $vm.currentPreset, vm: .init(settingType: .exposureCompensation, isDimmed: $vm.isDimmed))
            
            // Color Temperature (색온도)
            CircularWheelPickerView(preset: $vm.currentPreset, vm: .init(settingType: .colorTemperature, isDimmed: $vm.isDimmed))
        }
        .frame(maxWidth: .infinity)
    }
    
    private func handleSettingButtonTap(_ type: SettingType){
        guard vm.viewMode != .view else {
            vm.switchToEditMode()
            return
        }
        
        // 편집 불가능한 설정은 무시
        guard vm.isSettingEditable(type) else {
            return
        }
        
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


