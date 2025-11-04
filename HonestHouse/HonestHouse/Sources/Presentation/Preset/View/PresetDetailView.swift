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
    
    init(preset: CameraPreset? = nil, mode: ViewMode = .view) {
        self._vm = State(initialValue: PresetDetailViewModel(preset: preset, mode: mode))
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
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
        HStack(spacing: 12) {
            Text("촬영 모드")
                .font(.caption)
                .foregroundColor(.gray)
            
            CameraModeSelector(
                selectedMode: .init(
                    get: { vm.currentPreset.cameraMode },
                    set: { vm.changeCameraMode(to: $0) }
                ),
                isEnabled: vm.viewMode != .view,
                onSelect: { mode in
                    vm.changeCameraMode(to: mode)
                }
            )
            
            Spacer()
        }
    }
    
    // MARK: - Primary Settings Section
    private var primarySettingsSection: some View {
        HStack(spacing: 25) {
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
            
            Spacer()
            
            // Filter toggle
            Button(action: {
                if vm.viewMode != .view {
                    vm.toggleFilter()
                }
            }) {
                Image(systemName: vm.currentPreset.filterEnabled ? "square.grid.3x3.fill" : "square.grid.3x3")
                    .font(.system(size: 20))
                    .foregroundColor(
                        vm.viewMode == .view ?
                        (vm.currentPreset.filterEnabled ? .yellow : .gray) :
                        (vm.currentPreset.filterEnabled ? .white : .gray)
                    )
                    .frame(width: 45, height: 45)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.1))
                    )
            }
            .disabled(vm.viewMode == .view)
        }
    }
    
    // MARK: - Slider Section
    private func sliderSection(for type: SettingType) -> some View {
        Group {
            switch type {
            case .aperture:
                if vm.currentPreset.aperture != nil {
                    ValueSlider(
                        title: "조리개",
                        selectedIndex: .init(
                            get: {
                                vm.getClosestIndex(
                                    for: vm.currentPreset.aperture ?? 2.8,
                                    in: CameraConstants.apertureValues
                                )
                            },
                            set: { _ in }
                        ),
                        values: CameraConstants.apertureValues.map { vm.formatAperture($0) },
                        isEnabled: vm.isSettingEditable(.aperture),
                        onValueChange: { index in
                            vm.updateAperture(CameraConstants.apertureValues[index])
                        }
                    )
                }
                
            case .shutterSpeed:
                if vm.currentPreset.shutterSpeed != nil {
                    ValueSlider(
                        title: "셔터 스피드",
                        selectedIndex: .init(
                            get: {
                                vm.getClosestIndex(
                                    for: vm.currentPreset.shutterSpeed ?? 1/125,
                                    in: CameraConstants.shutterSpeedValues
                                )
                            },
                            set: { _ in }
                        ),
                        values: CameraConstants.shutterSpeedValues.map { vm.formatShutterSpeed($0) },
                        isEnabled: vm.isSettingEditable(.shutterSpeed),
                        onValueChange: { index in
                            vm.updateShutterSpeed(CameraConstants.shutterSpeedValues[index])
                        }
                    )
                }
                
            case .iso:
                ValueSlider(
                    title: "ISO",
                    selectedIndex: .init(
                        get: {
                            vm.getClosestIndex(
                                for: vm.currentPreset.iso,
                                in: CameraConstants.isoValues
                            )
                        },
                        set: { _ in }
                    ),
                    values: CameraConstants.isoValues.map { vm.formatISO($0) },
                    isEnabled: vm.isSettingEditable(.iso),
                    onValueChange: { index in
                        vm.updateISO(CameraConstants.isoValues[index])
                    }
                )
                
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
            VStack(spacing: 4) {
                Text(vm.formatExposureCompensation(vm.currentPreset.exposureCompensation))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(buttonTextColor(for: .exposure))
                
                Image(systemName: "plusminus.circle")
                    .font(.system(size: 24))
                    .foregroundColor(buttonTextColor(for: .exposure))
            }
            .frame(width: 60, height: 60)
            .background(buttonBackgroundColor(for: .exposure))
            .clipShape(Circle())
            .onTapGesture {
                handleSettingButtonTap(.exposure)
            }
            
            // Color Temperature
            VStack(spacing: 4) {
                Text(vm.formatColorTemperature(vm.currentPreset.colorTemperature))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(buttonTextColor(for: .colorTemp))
                
                Image(systemName: "thermometer.medium")
                    .font(.system(size: 24))
                    .foregroundColor(buttonTextColor(for: .colorTemp))
            }
            .frame(width: 60, height: 60)
            .background(buttonBackgroundColor(for: .colorTemp))
            .clipShape(Circle())
            .onTapGesture {
                handleSettingButtonTap(.colorTemp)
            }
            
            // White Balance (미구현 - 플레이스홀더)
            VStack(spacing: 4) {
                Text("0K")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray.opacity(0.5))
                
                Image(systemName: "thermometer")
                    .font(.system(size: 24))
                    .foregroundColor(.gray.opacity(0.5))
            }
            .frame(width: 60, height: 60)
            .background(Color.white.opacity(0.05))
            .clipShape(Circle())
        }
    }
    
    // MARK: - Helper Methods
    private func buttonBackgroundColor(for type: SettingType) -> Color {
        switch vm.getButtonState(for: type) {
        case .active:
            return vm.activeSlider == type ? .white : Color.white.opacity(0.2)
        case .disabled:
            return Color.black.opacity(0.3)
        case .viewOnly:
            return Color.yellow.opacity(0.3)
        }
    }
    
    private func buttonTextColor(for type: SettingType) -> Color {
        switch vm.getButtonState(for: type) {
        case .active:
            return vm.activeSlider == type ? .black : .white
        case .disabled:
            return Color.gray.opacity(0.5)
        case .viewOnly:
            return .black
        }
    }
    
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
