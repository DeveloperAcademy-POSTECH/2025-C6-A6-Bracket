//
//  PresetViewModel.swift
//  HonestHouse
//
//  Created by Subeen on 10/29/25.
//

import Foundation
import SwiftUI

enum PresetAction {
    case goToPresetDetail(ViewMode, Preset?)
}

@Observable
final class PresetViewModel {
    
    private let container: DIContainer
    private let shootingControlService: ShootingControlServiceType
    private let shootingSettingsService: ShootingSettingsServiceType
    private let presetManager: PresetManagerType
    
    var isPresetEditMode: Bool
    var onEditModeChange: ((Bool) -> Void)?
    var presets: [Preset] = []
    var selectedPresets: Set<UUID> = []
    var error: PresetError?
    
    // 뷰 모드 관련 추가 속성
    var viewMode: PresetViewMode = .list
    var isViewModeMenuPresented: Bool = false

    enum Action {
        case goToPresetDetail(ViewMode, Preset?)
    }
    
    init(
        container: DIContainer,
        isPresetEditMode: Bool,
        onEditModeChange: ((Bool) -> Void)? = nil
    ) {
        self.container = container
        self.isPresetEditMode = isPresetEditMode
        self.onEditModeChange = onEditModeChange
        
        self.shootingControlService = container.services.shootingControlService
        self.shootingSettingsService = container.services.shootingSettingsService
        self.presetManager = container.managers.presetManager
        
        // 초기 데이터 로드
        loadPresets()
    }
}

// MARK: - View Mode Methods
extension PresetViewModel {
    func toggleViewMode() {
        withAnimation(.easeInOut(duration: 0.3)) {
            viewMode = viewMode == .grid ? .list : .grid
        }
    }
    
    func setViewMode(_ mode: PresetViewMode) {
        withAnimation(.easeInOut(duration: 0.3)) {
            viewMode = mode
        }
    }
}

// MARK: - Actions
extension PresetViewModel {
    
    func send(action: PresetAction) {
        switch action {
        case .goToPresetDetail(let mode, let preset):
            container.navigationRouter.push(to: .presetEditor(mode, preset))
        }
    }
    
    /// View 진입 시 처음 호출할 용도로 만든 getAperture
    func getAperture() async {
        do {
            let res = try await shootingSettingsService.getAV(with: .ver100)
            Logger.debug("Aperture: \(res)", category: .viewModel)
        } catch {
            handleError(error)
        }
    }
    
    /// 현재 프리셋 적용
    func setCurrentPreset(_ preset: Preset) async {
        let shootingMode = preset.shootingMode
        let pictureStyle = preset.pictureStyle
        
        do {
            // 현재 슈팅 모드 무시 on
            try await ignoreShootingMode(action: "on")
            try await setShootingMode(value: shootingMode.apiValue)
            
            try await setPictureStyle(value: pictureStyle.apiValue)
            
            switch shootingMode {
            case .av:
                if let aperture = preset.aperture {
                    try await setAperture(value: aperture)
                }
                
            case .tv:
                if let shutterSpeed = preset.shutterSpeed {
                    try await setShutterSpeed(value: shutterSpeed)
                }
            case .p:
                break
            }
            
            if let iso = preset.iso {
                try await setISO(value: iso)
            }
            
            if let exposureCompensation = preset.exposureCompensation {
                try await setExposureCompensation(value: exposureCompensation)
            }
            
            Logger.debug("Color Temperature: \(preset.colorTemperature ?? -1)", category: .viewModel)
            
            if let colorTemperature = preset.colorTemperature {
                try await setColorTemperature(value: colorTemperature)
            }
            
            if let tintBlueAmber = preset.tintBlueAmber, let tintMagentaGreen = preset.tintMagentaGreen {
                try await setWbShift(blueAmber: tintBlueAmber, magentaGreen: tintMagentaGreen)
            }
            
            error = nil
            
            // 현재 슈팅 모드 무시 off
            try await ignoreShootingMode(action: "off")
        } catch {
            handleError(error)
        }
    }

    func toggleSelection(for preset: Preset) {
        if selectedPresets.contains(preset.id) {
            selectedPresets.remove(preset.id)
        } else {
            selectedPresets.insert(preset.id)
        }
    }
    
    func setEditMode(_ value: Bool) {
        isPresetEditMode = value
        onEditModeChange?(value)
    }
    
    func onShoot(preset: Preset) -> Void { }
    
    func onToggleSelection(preset: Preset) { }

    func deleteSelectedPresets() {
        do {
            for id in selectedPresets {
                try presetManager.deletePreset(by: id)
            }
            selectedPresets.removeAll()
            loadPresets()
        } catch {
            handleError(error)
        }
    }
}

// MARK: - Data Loading
extension PresetViewModel {
    func loadPresets() {
        do {
            presets = try presetManager.fetchAllPresets()
            error = nil
        } catch {
            handleError(error)
        }
    }
}

// MARK: - API Methods
extension PresetViewModel: PresetErrorHandleable {
    private func ignoreShootingMode(action: String) async throws {
        let request = ShootingControl.IgnoreShootingModeRequest(action: action)
        try await shootingControlService.ignoreShootingMode(with: .ver100, request: request)
    }
    
    private func getShootingMode() async throws {
        do {
            let res = try await shootingSettingsService.getShootingMode(with: .ver110)
            Logger.debug("Shooting Mode: \(res)", category: .viewModel)
        } catch {
            handleError(error)
        }
    }

    private func setShootingMode(value: String) async throws {
        let request = ShootingSettings.ShootingModeRequest(value: value)
        _ = try await shootingSettingsService.putShootingMode(with: .ver100, request: request)
        let response = try await shootingSettingsService.putShootingMode(with: .ver110, request: request)
        Logger.debug("Shooting Mode Response: \(response)", category: .viewModel)
    }

    private func setPictureStyle(value: String) async throws {
        let request = ShootingSettings.PictureStyleRequest(value: value)
        let response = try await shootingSettingsService.putPictureStyle(with: .ver100, request: request)
        Logger.debug("Picture Style Response: \(response)", category: .viewModel)
    }

    private func setAperture(value: String) async throws {
        let request = ShootingSettings.AVRequest(value: value)
        let response = try await shootingSettingsService.putAV(with: .ver100, request: request)
        Logger.debug("Aperture Response: \(response)", category: .viewModel)
    }

    private func setShutterSpeed(value: String) async throws {
        let request = ShootingSettings.TVRequest(value: value)
        _ = try await shootingSettingsService.putTV(with: .ver100, request: request)
    }

    private func setISO(value: String) async throws {
        let request = ShootingSettings.ISORequest(value: value)
        let response = try await shootingSettingsService.putISO(with: .ver100, request: request)
        Logger.debug("ISO Response: \(response)", category: .viewModel)
    }

    private func setExposureCompensation(value: String) async throws {
        let request = ShootingSettings.ExposureCompensationRequest(value: value)
        let response = try await shootingSettingsService.putExposureCompensation(with: .ver100, request: request)
        Logger.debug("Exposure Compensation Response: \(response)", category: .viewModel)
    }

    private func setColorTemperature(value: Int) async throws {
        let request = ShootingSettings.ColorTemperatureRequest(value: value)
        let response = try await shootingSettingsService.putColorTemperature(with: .ver100, request: request)
        Logger.debug("Color Temperature Response: \(response)", category: .viewModel)
    }

    private func setWbShift(blueAmber: Int, magentaGreen: Int) async throws {
        let wbShift = ShootingSettings.WBShiftRequest.WBShift(blueAmber: blueAmber, magentaGreen: magentaGreen)
        let request = ShootingSettings.WBShiftRequest(value: wbShift)
        let response = try await shootingSettingsService.putWbShift(with: .ver100, request: request)
        Logger.debug("WB Shift Response: \(response)", category: .viewModel)
    }
}
