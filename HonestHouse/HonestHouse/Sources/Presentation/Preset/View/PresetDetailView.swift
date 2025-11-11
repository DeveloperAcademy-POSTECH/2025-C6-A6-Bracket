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
    @State private var showDeleteAlert = false
    @State private var showUnsavedChangesAlert = false
    @Environment(\.dismiss) private var dismiss // TODO: - vm에서 nvrouter로 관리
    
    var body: some View {
        ZStack {
            Color.g12.ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                previewView()
                settingsView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            toolbarContent()
        }
        .alert("변경사항 저장", isPresented: $showUnsavedChangesAlert) {
            Button("저장하지 않고 나가기", role: .destructive) {
                dismiss()
            }
            Button("계속 편집", role: .cancel) { }
        } message: {
            Text("저장하지 않은 변경사항이 있습니다.")
        }
    }
    
    private func previewView() -> some View {
        LiveStreamView(vm: LiveStreamViewModel(container: vm.container))
            .frame(height: 274)
    }
    
    private func settingsView() -> some View {
        VStack(spacing: 52) {
            shootingModeView()
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
    
    // Camera Mode Section
    private func shootingModeView() -> some View {
        ShootingModeSelector(
            selectedMode: Binding(
                get: { vm.currentPreset.shootingMode },
                set: { vm.changeCameraMode(to: $0) }
            ),
            isEnabled: vm.viewMode != .view
        )
    }
    
    // Primary Settings Section
    private func primarySettingsView() -> some View {
        HStack {
            
//            SettingButton(
//                type: .cameraMode,
//                state: vm.getButtonState(for: .cameraMode),
//                value: vm.currentPreset.shootingMode,
//                isSelected: vm.activePicker == .cameraMode,
//                action: {
//                    handleSettingButtonTap(.cameraMode)
//                }
//            )
            
            // Aperture (조리개)
            SettingButton(
                type: .aperture,
                state: vm.getButtonState(for: .aperture),
                value: vm.currentPreset.displayAperture,
                isSelected: vm.activePicker == .aperture,
                action: {
                    handleSettingButtonTap(.aperture)
                }
            )
            
            // Shutter Speed (셔터 스피드)
            SettingButton(
                type: .shutterSpeed,
                state: vm.getButtonState(for: .shutterSpeed),
                value: vm.currentPreset.displayShutterSpeed,
                isSelected: vm.activePicker == .shutterSpeed,
                action: {
                    handleSettingButtonTap(.shutterSpeed)
                }
            )
            
            // ISO
            SettingButton(
                type: .iso,
                state: vm.getButtonState(for: .iso),
                value: vm.currentPreset.displayISO,
                isSelected: vm.activePicker == .iso,
                action: {
                    handleSettingButtonTap(.iso)
                }
            )
            
            // Picture Style (픽쳐 스타일)
            SettingButton(
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
                    spacing: 22,
                    itemSize: .init(width: 100, height: 24)
                )
            )
            
        default:
            EmptyView().frame(height: 52)
        }
    }
    
    // Secondary Settings Section
    private func secondarySettingsSView() -> some View {
        HStack(alignment: .center, spacing: 54) {
            
            // Tint Magenta Green (마젠타-그린)
            CircularWheelPickerView(vm: .init(settingType: .tintMagentaGreen, isDimmed: $vm.isDimmed))
            
            
            // Exposure Compensation (노출 보정)
            CircularWheelPickerView(vm: .init(settingType: .exposureCompensation, isDimmed: $vm.isDimmed))
            
            // Color Temperature (색온도)
            CircularWheelPickerView(vm: .init(settingType: .colorTemperature, isDimmed: $vm.isDimmed))
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
    
    // Toolbar
    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("취소") {
                if vm.viewMode == .create {
                    showUnsavedChangesAlert = true
                } else if vm.hasUnsavedChanges() {
                    showUnsavedChangesAlert = true
                } else {
                    dismiss()
                }
            }
            .foregroundColor(.white)
        }
        
        ToolbarItem(placement: .principal) {
            Text(vm.currentPreset.name)
                .font(.headline)
                .foregroundColor(.white)
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            switch vm.viewMode {
            case .view:
                Button("편집") {
                    vm.switchToEditMode()
                }
                .foregroundColor(.white)
                
            case .edit, .create:
                Button("저장") {
                    Task {
                        try? await vm.savePreset()
                    }
                }
                .foregroundColor(.white)
            }
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
