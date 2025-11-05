//
//  PresetDetailView.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/27/25.
//

import SwiftUI
import SwiftData

struct PresetDetailView: View {
    @State private var vm: PresetDetailViewModel
    @State private var showDeleteAlert = false
    @State private var showUnsavedChangesAlert = false
    @Environment(\.dismiss) private var dismiss
    
    init(preset: CameraPreset?, mode: ViewMode = .view) {
        self._vm = State(initialValue: PresetDetailViewModel(preset: preset, mode: mode))
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.g12.ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                // Preview Area
                previewSection
                    .frame(height: UIScreen.main.bounds.height * 0.35)
                
                // Control Panel
                VStack(spacing: 25) {
                    // Camera Mode Section
                    cameraModeSection
                    
                    // Primary Settings
                    primarySettingsSection
                    
                    // Value Slider (if active)
                    if let activeSlider = vm.activeSlider {
                        sliderSection(for: activeSlider)
                    }
                    
                    // Secondary Settings
                    secondarySettingsSection
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
    private var previewSection: some View {
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
            
            // Preset Name & Indicator
            VStack {
                HStack {
                    // Recording indicator
                    HStack(spacing: 5) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 6, height: 6)
                        Circle()
                            .fill(Color.red)
                            .frame(width: 6, height: 6)
                        Circle()
                            .fill(Color.red)
                            .frame(width: 6, height: 6)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(10)
                    
                    Spacer()
                    
                    // Time indicator
                    Text("120장")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                }
                .padding()
                
                Spacer()
            }
        }
    }
    
    // MARK: - Camera Mode Section
    private var cameraModeSection: some View {
        CameraModeSelector(
            selectedMode: Binding(
                get: { vm.currentPreset.cameraMode },
                set: { vm.changeCameraMode(to: $0) }
            ),
            isEnabled: vm.viewMode != .view
        )
    }
    
    // MARK: - Primary Settings Section
    private var primarySettingsSection: some View {
        HStack {
            // Aperture
            SettingButton(
                type: .aperture,
                state: vm.getButtonState(for: .aperture),
                value: vm.formatAperture(vm.currentPreset.aperture),
                isSelected: vm.activeSlider == .aperture,
                action: {
                    handleSettingButtonTap(.aperture)
                }
            )
            
            // Shutter Speed
            SettingButton(
                type: .shutterSpeed,
                state: vm.getButtonState(for: .shutterSpeed),
                value: vm.formatShutterSpeed(vm.currentPreset.shutterSpeed),
                isSelected: vm.activeSlider == .shutterSpeed,
                action: {
                    handleSettingButtonTap(.shutterSpeed)
                }
            )
            
            // ISO
            SettingButton(
                type: .iso,
                state: vm.getButtonState(for: .iso),
                value: vm.formatISO(vm.currentPreset.iso),
                isSelected: vm.activeSlider == .iso,
                action: {
                    handleSettingButtonTap(.iso)
                }
            )
            
            SettingButton(type: .filter, state: vm.getButtonState(for: .filter), value: vm.currentPreset.filter, isSelected: vm.activeSlider == .filter) {
                handleSettingButtonTap(.filter)
            }
            
            
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Slider Section
    private func sliderSection(for type: SettingType) -> some View {
        Group {
            switch type {
            case .aperture:
                if vm.currentPreset.aperture != nil {
                    CustomWheelPickerView(selectedValue: $vm.currentPreset.aperture, items: CameraConstants.apertureValues, config: .init(spacing: 22, itemSize: .init(width: 50, height: 24)))

                }
                
            case .shutterSpeed:
                
                    CustomWheelPickerView(selectedValue: $vm.currentPreset.shutterSpeed, items: CameraConstants.shutterSpeedValues, config: .init(spacing: 22, itemSize: .init(width: 50, height: 24)))
                
                
            case .iso:
//                if vm.currentPreset.iso != 0 {
                    CustomWheelPickerView(selectedValue: $vm.currentPreset.iso, items: CameraConstants.isoValues, config: .init(spacing: 22, itemSize: .init(width: 50, height: 24)))
                    
//                }
            case .filter:
                
                
                    CustomWheelPickerView(selectedValue: $vm.currentPreset.filter, items: CameraConstants.filterValues, config: .init(spacing: 22, itemSize: .init(width: 50, height: 24)))
                
                
            default:
                EmptyView()
            }
        }
        .frame(height: 80)
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.2), value: vm.activeSlider)
    }
    
    // MARK: - Secondary Settings Section
    private var secondarySettingsSection: some View {
        HStack(spacing: 30) {
            // Exposure Compensation
            
            SettingButton(
                type: .tint,
                state: vm.getButtonState(for: .tint),
                value: vm.formatISO(vm.currentPreset.tint),
                isSelected: vm.activeSlider == .tint,
                action: {
                    handleSettingButtonTap(.tint)
                }
            )
            
            SettingButton(  // plusminus.circle
                type: .exposure,
                state: vm.getButtonState(for: .exposure),
                value: vm.formatExposureCompensation(vm.currentPreset.exposureCompensation),
                isSelected: vm.activeSlider == .exposure,
                action: {
                    handleSettingButtonTap(.exposure)
                }
            )
            
            SettingButton(  // thermometer.medium
                type: .colorTemp,
                state: vm.getButtonState(for: .colorTemp),
                value: vm.formatColorTemperature(vm.currentPreset.colorTemperature),
                isSelected: vm.activeSlider == .colorTemp,
                action: {
                    handleSettingButtonTap(.colorTemp)
                }
            )
        }
    }
    
    // MARK: - Helper Methods
//    private func buttonBackgroundColor(for type: SettingType) -> Color {
//        switch vm.getButtonState(for: type) {
//        case .active:
//            return vm.activeSlider == type ? .white : Color.white.opacity(0.2)
//        case .disabled:
//            return Color.black.opacity(0.3)
//        case .viewOnly:
//            return Color.yellow.opacity(0.3)
//        }
//    }
    
//    private func buttonTextColor(for type: SettingType) -> Color {
//        switch vm.getButtonState(for: type) {
//        case .active:
//            return vm.activeSlider == type ? .black : .white
//        case .disabled:
//            return Color.gray.opacity(0.5)
//        case .viewOnly:
//            return .black
//        }
//    }
    
    private func handleSettingButtonTap(_ type: SettingType) {
        guard vm.viewMode != .view else {
            // 조회 모드에서는 편집 모드로 전환
            vm.switchToEditMode()
            return
        }
        
        guard vm.isSettingEditable(type) else { return }
        
        // Toggle slider visibility
        if vm.activeSlider == type {
            vm.activeSlider = nil
        } else {
            vm.activeSlider = type
        }
    }
    
    // MARK: - Toolbar
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
    PresetDetailView(
        preset: CameraPreset(
            name: "푸른_하늘_화사함",
            cameraMode: .P,
            iso: 400
        ),
        mode: .view
    )
}

#Preview("Edit Mode") {
    PresetDetailView(
        preset: CameraPreset(
            name: "푸른_하늘_화사함",
            cameraMode: .Av,
            aperture: 2.8,
            iso: 200
        ),
        mode: .edit
    )
}

#Preview("Create Mode") {
    PresetDetailView(preset: nil, mode: .create)
}
