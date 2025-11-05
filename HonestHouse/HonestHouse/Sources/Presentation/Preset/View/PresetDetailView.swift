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
                // Preview Area
                previewView
                    .frame(height: 200)
                
                // Control Panel
                VStack(spacing: 25) {
                    // Camera Mode Section
                    shootingModeView
                    
                    // Primary Settings
                    primarySettingsView
                    
                    if let activePicker = vm.activePicker {
                        pickerView(for: activePicker)
                    }
                    
                    // Secondary Settings
                    secondarySettingsSView
                }
                .padding(.horizontal, 20)
                .padding(.top, 30)
                
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
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
    
    // MARK: - Preview Section
    private var previewView: some View {
        ZStack {
            // Sample Image (구름 사진)
            Image(systemName: "cloud.fill")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
    }
    
    // Camera Mode Section
    private var shootingModeView: some View {
        ShootingModeSelector(
            selectedMode: Binding(
                get: { vm.currentPreset.shootingMode },
                set: { vm.changeCameraMode(to: $0) }
            ),
            isEnabled: vm.viewMode != .view
        )
    }
    
    // Primary Settings Section
    private var primarySettingsView: some View {
        HStack {
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
    
    private func pickerView(for type: SettingType) -> some View {
        Group {
            switch type {
            case .aperture:
                if vm.currentPreset.shootingMode == .av {
                    CustomWheelPickerView(
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
                    CustomWheelPickerView(
                        selectedValue: $vm.currentPreset.shutterSpeed,
                        items: vm.getShutterSpeedValues(),
                        config: .init(
                            spacing: 22,
                            itemSize: .init(width: 50, height: 24)
                        )
                    )
                    
                }
            case .iso:
                CustomWheelPickerView(
                    selectedValue: $vm.currentPreset.iso,
                    items: vm.getISOValues(),
                    config: .init(
                        spacing: 22,
                        itemSize: .init(width: 50, height: 24)
                    )
                )

//            case .pictureStyle:
//                CustomWheelPickerView(
//                    selectedValue: $vm.currentPreset.pictureStyle,
//                    items: vm.getPictureStyleValues(),
//                    config: .init(
//                        spacing: 22,
//                        itemSize: .init(width: 50, height: 24)
//                    )
//                )
                
            case .tintMagentaGreen:
                CustomWheelPickerView(
                    selectedValue: $vm.currentPreset.tintMagentaGreen,
                    items: vm.getTintMagentGreenValues(),
                    config: .init(
                        spacing: 22,
                        itemSize: .init(width: 50, height: 24)
                    )
                )
                
            case .exposure:
                CustomWheelPickerView(
                    selectedValue: $vm.currentPreset.exposureCompensation,
                    items: vm.getExposureCompensationValues(),
                    config: .init(
                        spacing: 22,
                        itemSize: .init(width: 50, height: 24)
                    )
                )
                
//            case .colorTemp:
//                CustomWheelPickerView(
//                    selectedValue: $vm.currentPreset.colorTemperature,
//                    items: vm.getColorTemperatureValues(),
//                    config: .init(
//                        spacing: 22,
//                        itemSize: .init(width: 50, height: 24)
//                    )
//                )
                
            default:
                EmptyView()
            }
        }
        .frame(height: 80)
        .transition(.opacity)
    }
    
    // Secondary Settings Section
    private var secondarySettingsSView: some View {
        HStack(spacing: 30) {
            
            // Tint Magenta Green (마젠타-그린)
            SettingButton(
                type: .tintMagentaGreen,
                state: vm.getButtonState(for: .tintMagentaGreen),
                value: vm.currentPreset.displayTintMagentaGreen,
                isSelected: vm.activePicker == .tintMagentaGreen,
                action: {
                    handleSettingButtonTap(.tintMagentaGreen)
                }
            )
            
            // Exposure Compensation (노출 보정)
            SettingButton(
                type: .exposure,
                state: vm.getButtonState(for: .exposure),
                value: vm.currentPreset.displayExposureCompensation,
                isSelected: vm.activePicker == .exposure,
                action: {
                    handleSettingButtonTap(.exposure)
                }
            )
            
            // Color Temperature (색온도)
            SettingButton(
                type: .colorTemp,
                state: vm.getButtonState(for: .colorTemp),
                value: vm.currentPreset.displayColorTemperature,
                isSelected: vm.activePicker == .colorTemp,
                action: {
                    handleSettingButtonTap(.colorTemp)
                }
            )
        }
    }
    
    private func handleSettingButtonTap(_ type: SettingType) {
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
    private var toolbarContent: some ToolbarContent {
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

// MARK: - Preview
#Preview("View Mode") {
    PresetDetailView(vm: .init(container: .stub, mode: .view, preset: .stub1))
}

#Preview("Edit Mode") {
    PresetDetailView(vm: .init(container: .stub, mode: .edit, preset: .stub2))
}

#Preview("Create Mode") {
    PresetDetailView(vm: .init(container: .stub, mode: .create, preset: .stub3))
}
