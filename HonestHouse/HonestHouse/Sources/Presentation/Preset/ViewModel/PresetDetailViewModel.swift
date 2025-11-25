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
    var activePicker: PresetSettingType?
    var currentError: PresetError?
    var showDeleteAlert: Bool = false
    var showOptionsMenu: Bool = false
    
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
            self.currentPreset = .init(name: "", pictureStyle: .auto, shootingMode: .av)
            self.viewMode = .create
        }
    }
    
    func switchToEditMode() {
        guard viewMode == .view else { return }
        originalPreset = currentPreset.copy()
        viewMode = .edit
        showOptionsMenu = false
    }
    
    func switchToViewMode() {
        viewMode = .view
        activePicker = nil
        showCameraModeSelector = false
    }
    
    func initializeForCreate() {
        currentPreset = .init(name: "", pictureStyle: .auto, shootingMode: .av)
        viewMode = .create
        originalPreset = nil
    }
    
    // Camera Mode Management
    func changeCameraMode(to mode: ShootingModeType) {
        guard currentPreset.shootingMode != mode else { return }

        Logger.info("Changing camera mode from \(currentPreset.shootingMode) to \(mode)", category: .preset)

        currentPreset.shootingMode = mode
        activePicker = nil

        switch mode {
        case .p:
            // P모드: 조리개와 셔터스피드 Auto (nil)
            currentPreset.aperture = nil
            currentPreset.shutterSpeed = nil

        case .av:
            // AV모드: 셔터스피드 Auto (nil)
            currentPreset.shutterSpeed = nil
            if currentPreset.aperture == nil {
                currentPreset.aperture = CameraConstants.apertureValues.first ?? "f4.5"
            }

        case .tv:
            // TV모드: 조리개 Auto (nil)
            currentPreset.aperture = nil
            if currentPreset.shutterSpeed == nil {
                currentPreset.shutterSpeed = CameraConstants.shutterSpeedValues.first ?? "1/125"
            }
        }

        // viewMode가 view가 아닐 때만 카메라 설정 적용
        guard viewMode != .view else {
            Logger.warning("View mode is .view, skipping camera setting application", category: .preset)
            return
        }

        Task {
            await applyCameraSettings(for: .cameraMode, value: mode)
        }
    }

    // Button State
    func getButtonState(for type: PresetSettingType) -> PresetButtonState {
        // View 모드 처리
        if viewMode == .view {
            if isValueSetToAutoOrZero(for: type) {
                return .deactivated
            }
            return .selected
        }
        
        // Create/Edit 모드 처리
        // 값 설정 불가능한 경우 (촬영 모드에 따라)
        if !isSettingEditable(type) {
            return .deactivated
        }
        
        // 현재 picker가 활성화된 버튼
        if activePicker == type {
            return .selected
        }
        
        return .activated
    }
    
    // Auto 또는 0 값 판단
    private func isValueSetToAutoOrZero(for type: PresetSettingType) -> Bool {
        switch type {
        case .aperture:
            return currentPreset.aperture == nil
            
        case .shutterSpeed:
            return currentPreset.shutterSpeed == nil
            
        case .iso:
            return currentPreset.iso == nil
            
        case .tintMagentaGreen:
            return currentPreset.tintMagentaGreen == 0
            
        case .exposure:
            guard let value = currentPreset.exposureCompensation else { return true }
            return value == "0" || value == "+0" || value.isEmpty
            
        case .colorTemp:
            return currentPreset.colorTemperature == 0
            
        case .pictureStyle, .cameraMode:
            return false
        }
    }
    
    // 설정 편집 가능 여부
    func isSettingEditable(_ type: PresetSettingType) -> Bool {
        // View 모드에서는 모두 편집 불가
        guard viewMode != .view else { return false }
        
        switch type {
        case .cameraMode, .pictureStyle:
            return true
            
        case .aperture:
            return currentPreset.shootingMode == .av
            
        case .shutterSpeed:
            return currentPreset.shootingMode == .tv
            
        case .iso, .tintMagentaGreen, .exposure, .colorTemp:
            return true
        }
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
            
            // 성공 시 View 모드로 전환
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
    
    // Delete Preset
    func deletePreset() {
        do {
            try container.managers.presetManager.deletePreset(by: currentPreset.id)
            Logger.info("Preset deleted successfully: \(currentPreset.id)", category: .preset)
            // 삭제 성공 시 PresetView로 이동
            send(.popToPresetView)
        } catch let presetManagerError as PresetManagerError {
            Logger.error("Failed to delete preset: \(presetManagerError)", category: .preset)
            currentError = PresetError.fromPresetManager(presetManagerError)
            // 에러 발생해도 화면은 pop
            send(.popToPresetView)
        } catch let presetError as PresetError {
            Logger.error("Failed to delete preset: \(presetError)", category: .preset)
            currentError = presetError
            send(.popToPresetView)
        } catch {
            Logger.error("Failed to delete preset with unknown error: \(error)", category: .preset)
            currentError = .unknown
            send(.popToPresetView)
        }
    }
    
    // Options Menu
    func getMenuItems() -> [MenuItem] {
        let editItem = MenuItem(
            icon: .presetSelect,  // 적절한 아이콘으로 변경 필요
            label: "수정",
            action: { [weak self] in
                self?.handleEditMode()
            }
        )
        
        let deleteItem = MenuItem(
            icon: .trash,
            label: "삭제",
            action: { [weak self] in
                self?.handleDeleteMode()
            }
        )
        
        return [editItem, deleteItem]
    }
    
    private func handleEditMode() {
        showOptionsMenu = false
        switchToEditMode()
    }
    
    private func handleDeleteMode() {
        showOptionsMenu = false
        showDeleteAlert = true
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
        currentPreset = .init(name: "", pictureStyle: .auto, shootingMode: .av)
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

extension PresetDetailViewModel {
    func applyCameraSettings(for type: PresetSettingType, value: Any) async {
        Logger.info("Applying camera settings for \(type)", category: .preset)

        do {
            Logger.debug("Setting ignoreShootingMode to ON", category: .preset)
            try await ignoreShootingMode(action: "on")

            switch type {
            case .cameraMode:
                if let mode = value as? ShootingModeType {
                    Logger.debug("Setting camera mode to \(mode.apiValue)", category: .preset)
                    try await setShootingMode(mode: mode)
                    Logger.info("Camera mode set successfully to \(mode.apiValue)", category: .preset)
                }
                
            case .aperture:
                if let aperture = value as? String {
                    Logger.debug("Setting aperture to \(aperture)", category: .preset)
                    try await setAperture(value: aperture)
                    Logger.info("Aperture set successfully to \(aperture)", category: .preset)
                }
                
            case .shutterSpeed:
                if let shutterSpeed = value as? String {
                    Logger.debug("Setting shutter speed to \(shutterSpeed)", category: .preset)
                    try await setShutterSpeed(value: shutterSpeed)
                    Logger.info("Shutter speed set successfully to \(shutterSpeed)", category: .preset)
                }
                
            case .iso:
                if let iso = value as? String {
                    Logger.debug("Setting ISO to \(iso)", category: .preset)
                    try await setISO(value: iso)
                    Logger.info("ISO set successfully to \(iso)", category: .preset)
                }
                
            case .pictureStyle:
                if let style = value as? PictureStyleType {
                    Logger.debug("Setting picture style to \(style.apiValue)", category: .preset)
                    try await setPictureStyle(style: style)
                    Logger.info("Picture style set successfully to \(style.apiValue)", category: .preset)
                }
                
            case .tintMagentaGreen:
                if let tint = value as? Int {
                    Logger.debug("Setting tintMagentaGreen to \(tint)", category: .preset)
                    try await setTintMagentGreen(value: tint)
                    Logger.info("tintMagentaGreen set successfully to \(tint)", category: .preset)
                }
                
            case .exposure:
                if let exposure = value as? String {
                    Logger.debug("Setting exposure to \(exposure)", category: .preset)
                    try await setExposureCompensation(value: exposure)
                    Logger.info("Exposure set successfully to \(exposure)", category: .preset)
                }
                
            case .colorTemp:
                if let temp = value as? Int {
                    Logger.debug("Setting color temp to \(temp)", category: .preset)
                    try await setColorTemperature(value: temp)
                    Logger.info("Color temp set successfully to \(temp)", category: .preset)
                }
                
            default:
                Logger.warning("Unsupported setting type: \(type)", category: .preset)
                break
            }

            Logger.debug("Setting ignoreShootingMode to OFF", category: .preset)
            try await ignoreShootingMode(action: "off")

        } catch let ccapiError as CCAPIError {
            try? await ignoreShootingMode(action: "off")
            Logger.error("Camera setting application failed: \(ccapiError.errorDescription ?? "unknown error")", category: .preset)
            handleSettingApplicationError(ccapiError)
        } catch {
            try? await ignoreShootingMode(action: "off")
            Logger.error("Camera setting application failed with unknown error: \(error.localizedDescription)", category: .preset)
            currentError = .settingApplicationFailed
        }
    }

    private func handleSettingApplicationError(_ error: CCAPIError) {
        currentError = PresetError.fromCCAPI(error)
    }

    private func ignoreShootingMode(action: String) async throws {
        let request = ShootingControl.IgnoreShootingModeRequest(action: action)
        try await container.services.shootingControlService.ignoreShootingMode(request: request)
    }

    private func setShootingMode(mode: ShootingModeType) async throws {
        let request = ShootingSettings.ShootingModeRequest(value: mode.apiValue)
        _ = try await container.services.shootingSettingsService.putShootingMode(request: request)
    }

    private func setPictureStyle(style: PictureStyleType) async throws {
        let request = ShootingSettings.PictureStyleRequest(value: style.apiValue)
        _ = try await container.services.shootingSettingsService.putPictureStyle(request: request)
    }

    private func setAperture(value: String) async throws {
        let request = ShootingSettings.AVRequest(value: value)
        _ = try await container.services.shootingSettingsService.putAV(request: request)
    }

    private func setShutterSpeed(value: String) async throws {
        let request = ShootingSettings.TVRequest(value: value)
        _ = try await container.services.shootingSettingsService.putTV(request: request)
    }

    private func setISO(value: String) async throws {
        let request = ShootingSettings.ISORequest(value: value)
        _ = try await container.services.shootingSettingsService.putISO(request: request)
    }
    
    private func setTintMagentGreen(value: Int) async throws {
        let request = ShootingSettings.WBShiftRequest(value: .init(blueAmber: 0, magentaGreen: value))
        _ = try await container.services.shootingSettingsService.putWbShift(request: request)
    }
    
    private func setExposureCompensation(value: String) async throws {
        let request = ShootingSettings.ExposureCompensationRequest(value: value)
        _ = try await container.services.shootingSettingsService.putExposureCompensation(request: request)
    }
    
    private func setColorTemperature(value: Int) async throws {
        let request = ShootingSettings.ColorTemperatureRequest(value: value)
        _ = try await container.services.shootingSettingsService.putColorTemperature(request: request)
    }
}
