//
//  PresetDetailViewModel.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/27/25.
//

import Foundation
import SwiftUI
import Observation

enum PresetDetailAction {
    case popToPresetView
}

@Observable
class PresetDetailViewModel {
    var container: DIContainer
    var currentPreset: Preset
    var viewMode: PresetDetailViewMode
    var isLoading: Bool = false
    var showCameraModeSelector: Bool = false
    var activePicker: SettingType?
    var isDimmed: Bool = false
    var currentError: PresetError?

    private var originalPreset: Preset?
    
    init(
        container: DIContainer,
        mode: PresetDetailViewMode,
        preset: Preset?
    ) {
        self.container = container
        
        if let preset = preset {
            self.currentPreset = preset
            self.viewMode = mode
        } else {
            // Create mode with default preset
            self.currentPreset = .init(name: "새 프리셋", pictureStyle: .auto, shootingMode: .av)
            self.viewMode = .create
        }
    }
    
    func switchToEditMode() {
        guard viewMode == .view else { return }
        originalPreset = currentPreset.copy()
        viewMode = .edit
    }
    
    func switchToViewMode() {
        viewMode = .view
        activePicker = nil
        showCameraModeSelector = false
    }
    
    func initializeForCreate() {
        currentPreset = .init(name: "새 프리셋", pictureStyle: .auto, shootingMode: .av)
        viewMode = .create
        originalPreset = nil
    }
    
    // Camera Mode Management
    func changeCameraMode(to mode: ShootingModeType) {
        guard currentPreset.shootingMode != mode else { return }
        
        currentPreset.shootingMode = mode
        activePicker = nil
        
        // Auto 처리를 위해 적절한 nil 설정
        switch mode {
        case .p:
            // P모드: 조리개와 셔터스피드 Auto (nil)
            currentPreset.aperture = nil
            currentPreset.shutterSpeed = nil
            
        case .av:
            // Av모드: 셔터스피드 Auto (nil)
            currentPreset.shutterSpeed = nil
            if currentPreset.aperture == nil {
                currentPreset.aperture = CameraConstants.apertureValues.first ?? "f4.5"
            }
            
        case .tv:
            // Tv모드: 조리개 Auto (nil)
            currentPreset.aperture = nil
            if currentPreset.shutterSpeed == nil {
                currentPreset.shutterSpeed = CameraConstants.shutterSpeedValues.first ?? "1/125"
            }
        }
    }

    // Button State
    func getButtonState(for type: SettingType) -> ButtonState {
        // 조회 모드에서는 모든 버튼이 viewOnly
        if viewMode == .view {
            return .viewOnly
        }
        
        // 수정/생성 모드
        switch type {
        case .cameraMode:
            return .active
            
        case .aperture:
            return currentPreset.shootingMode == .av ? .active : .disabled
            
        case .shutterSpeed:
            return currentPreset.shootingMode == .tv ? .active : .disabled
            
        case .iso, .pictureStyle, .tintMagentaGreen, .exposure, .colorTemp:
            return .active
        }
    }
    
    func isSettingEditable(_ type: SettingType) -> Bool {
        return getButtonState(for: type) == .active
    }
    
    // Value Updates
    func updateAperture(_ value: String) {
        guard isSettingEditable(.aperture) else { return }
        currentPreset.aperture = value
    }
    
    func updateShutterSpeed(_ value: String) {
        guard isSettingEditable(.shutterSpeed) else { return }
        currentPreset.shutterSpeed = value
    }
    
    func updateISO(_ value: String) {
        guard isSettingEditable(.iso) else { return }
        currentPreset.iso = value
    }
    
    func updateExposureCompensation(_ value: String) {
        currentPreset.exposureCompensation = value
    }
    
    func updateColorTemperature(_ value: Int) {
        currentPreset.colorTemperature = value
    }
    
    func formatColorTemperature(_ value: Int) -> String {
        return "\(value)K"
    }
    
    // Data Persistence
    func savePreset() async throws {
        isLoading = true
        defer { isLoading = false }

        let presetManager = container.managers.presetManager
        
        do {
            currentPreset.updatedAt = Date()
            
            switch viewMode {
                
                
            case .create:
                // 새 프리셋 생성
                try presetManager.createPreset(currentPreset)
                
            case .edit:
                // 기존 프리셋 업데이트
                try presetManager.updatePreset(currentPreset)
                
            case .view:
                // 조회 모드에서는 저장 불가 (도달하지 않음)
                break
            }
            
            // 4. 성공 시 View 모드로 전환
            switchToViewMode()

        } catch {
            throw error
        }
    }
    
    func cancelEditing() {
        if let original = originalPreset {
            currentPreset = original
        }
        switchToViewMode()
    }
    
    func hasUnsavedChanges() -> Bool {
        guard let original = originalPreset else { return false }
        return !arePresetsEqual(original, currentPreset)
    }
    
    private func arePresetsEqual(_ lhs: Preset, _ rhs: Preset) -> Bool {
        return lhs.name == rhs.name &&
        lhs.pictureStyle == rhs.pictureStyle &&
        lhs.shootingMode == rhs.shootingMode &&
        lhs.aperture == rhs.aperture &&
        lhs.shutterSpeed == rhs.shutterSpeed &&
        lhs.iso == rhs.iso &&
        lhs.tintMagentaGreen == rhs.tintMagentaGreen &&
        lhs.exposureCompensation == rhs.exposureCompensation &&
        lhs.colorTemperature == rhs.colorTemperature
    }
    
    // Get Setting Values
    func getCameraShootingModeValues() -> [ShootingModeType] {
        return ShootingModeType.allCases
    }
    
    func getISOValues() -> [String] {
        return CameraConstants.isoValues
    }
    
    func getApertureValues() -> [String] {
        return CameraConstants.apertureValues
    }
    
    func getShutterSpeedValues() -> [String] {
        return CameraConstants.shutterSpeedValues
    }
    
    func getPictureStyleValues() -> [PictureStyleType] {
        return PictureStyleType.allCases
    }
    
    func getTintMagentGreenValues() -> [Int] {
        return CameraConstants.tintMagentaGreenValues
    }
    
    func getExposureCompensationValues() -> [String] {
        return CameraConstants.exposureCompensationValues
    }
    
    func getColorTemperatureValues() -> [Int] {
        return CameraConstants.colorTemperatureValues
    }

    @MainActor
    func fetchCurrentCameraSettings() async {
        isLoading = true
        currentError = nil

        do {
            async let shootingModeResponse = container.services.shootingSettingsService.getShootingMode()
            async let pictureStyleResponse = container.services.shootingSettingsService.getPictureStyle()
            async let avResponse = container.services.shootingSettingsService.getAV()
            async let tvResponse = container.services.shootingSettingsService.getTV()
            async let isoResponse = container.services.shootingSettingsService.getISO()
            async let exposureCompResponse = container.services.shootingSettingsService.getExposureCompensation()
            async let colorTempResponse = container.services.shootingSettingsService.getColorTemperature()
            async let wbShiftResponse = container.services.shootingSettingsService.getWbShift()

            let (shootingMode, pictureStyle, av, tv, iso, exposureComp, colorTemp, wbShift) =
                try await (shootingModeResponse, pictureStyleResponse, avResponse, tvResponse,
                           isoResponse, exposureCompResponse, colorTempResponse, wbShiftResponse)

            let mappedShootingMode = ShootingModeType.from(apiValue: shootingMode.value ?? "") ?? .av
            let mappedPictureStyle = PictureStyleType.from(apiValue: pictureStyle.value ?? "") ?? .auto

            currentPreset.pictureStyle = mappedPictureStyle
            currentPreset.shootingMode = mappedShootingMode
            currentPreset.aperture = av.value
            currentPreset.shutterSpeed = tv.value
            currentPreset.iso = iso.value
            currentPreset.exposureCompensation = exposureComp.value
            currentPreset.colorTemperature = colorTemp.value
            currentPreset.tintMagentaGreen = wbShift.value?.magentaGreen

            isLoading = false
        } catch {
            isLoading = false
            handleFetchError(error)
        }
    }

    private func handleFetchError(_ error: Error) {
        if let presetError = error as? PresetError {
            currentError = presetError
        } else if let ccapiError = error as? CCAPIError {
            currentError = PresetError.fromCCAPI(ccapiError)
        } else {
            currentError = .cameraSettingsFetchFailed
        }
    }

    func useDefaultPreset() {
        currentPreset = .init(name: "새 프리셋", pictureStyle: .auto, shootingMode: .av)
        currentError = nil
    }

    func retryFetchCameraSettings() {
        currentError = nil
        Task {
            await fetchCurrentCameraSettings()
        }
    }
}

extension PresetDetailViewModel {
    func send(_ action: PresetDetailAction) {
        switch action {
        case .popToPresetView:
            container.navigationRouter.pop()
        }
    }
}
