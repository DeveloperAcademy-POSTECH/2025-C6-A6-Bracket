//
//  MainViewModel.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/24/25.
//

import SwiftUI

enum MainAction {
    case goToPresetEditor(PresetDetailViewMode, Preset?)
    case goToPhotoSelection
    case goToSettings
}

@Observable
final class MainViewModel {
    private let container: DIContainer

    var selectedSegment: MainViewSegmentType = .trishot
    var segments: [MainViewSegmentType] = [.trishot, .preset]
    var isPresetEditMode: Bool = false
    var selectedPreset: Preset?
    var showModeChange: Bool = false
    var showDeleteAlert: Bool = false
    var showPresetApply: Bool = false
    
    var presets: [Preset] = []
    var selectedPresets: Set<UUID> = []
    var viewMode: PresetViewMode = .list
    var currentError: PresetError?
    var currentlyAppliedPreset: Preset?
    var presetToApply: Preset?

    var showEditButton: Bool {
        selectedSegment == .preset
    }
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func send(action: MainAction) {
        switch action {
        case .goToPresetEditor(let mode, let preset):
            container.navigationRouter.push(to: .presetEditor(mode, preset))
            
        case .goToPhotoSelection:
            container.navigationRouter.push(to: .photoSelection)
            
        case .goToSettings:
            container.navigationRouter.push(to: .settings)
        }
    }
    
    func setSelectedSegment(_ segment: MainViewSegmentType) {
        guard selectedSegment != segment else { return }
        selectedSegment = segment
        exitEditMode()
        currentlyAppliedPreset = nil
    }
    
    func toggleEditMode() {
        selectedPresets.removeAll()
        isPresetEditMode.toggle()
    }
    
    func exitEditMode() {
        isPresetEditMode = false
        selectedPresets.removeAll()
    }
    
    func setViewMode(_ mode: PresetViewMode) {
        selectedPresets.removeAll()
        withAnimation(.easeInOut(duration: 0.3)) {
            viewMode = mode
        }
    }

    func loadPresets() {
        do {
            presets = try container.managers.presetManager.fetchAllPresets()
            currentError = nil
        } catch let presetManagerError as PresetManagerError {
            currentError = PresetError.fromPresetManager(presetManagerError)
        } catch let presetError as PresetError {
            currentError = presetError
        } catch {
            currentError = .unknown
        }
    }

    func toggleSelection(for preset: Preset) {
        if selectedPresets.contains(preset.id) {
            selectedPresets.remove(preset.id)
        } else {
            selectedPresets.insert(preset.id)
        }
    }

    func selectAllPresets() {
        selectedPresets = Set(presets.map { $0.id })
    }

    func deleteSelectedPresets() {
        do {
            for id in selectedPresets {
                try container.managers.presetManager.deletePreset(by: id)
            }
            selectedPresets.removeAll()
            loadPresets()
            showDeleteAlert = false
            exitEditMode()
        } catch let presetManagerError as PresetManagerError {
            currentError = PresetError.fromPresetManager(presetManagerError)
        } catch let presetError as PresetError {
            currentError = presetError
        } catch {
            currentError = .unknown
        }
    }

    func getDisplayType(for preset: Preset) -> PresetCapsuleDisplayType {
        if isPresetEditMode && selectedPresets.contains(preset.id) {
            return .selected
        } else if currentlyAppliedPreset == preset {
            return .currentlyApplied
        } else {
            return .default
        }
    }

    func setCurrentPreset(_ preset: Preset) async {
        let shootingMode = preset.shootingMode
        let pictureStyle = preset.pictureStyle

        do {
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

            if let colorTemperature = preset.colorTemperature {
                try await setColorTemperature(value: colorTemperature)
            }

            if let tintBlueAmber = preset.tintBlueAmber, let tintMagentaGreen = preset.tintMagentaGreen {
                try await setWbShift(blueAmber: tintBlueAmber, magentaGreen: tintMagentaGreen)
            }

            currentError = nil
            currentlyAppliedPreset = preset
            try await ignoreShootingMode(action: "off")
        } catch let ccapiError as CCAPIError {
            try? await ignoreShootingMode(action: "off")
            currentError = PresetError.fromCCAPI(ccapiError)
        } catch let presetError as PresetError {
            try? await ignoreShootingMode(action: "off")
            currentError = presetError
        } catch {
            try? await ignoreShootingMode(action: "off")
            currentError = .unknown
        }
    }

    private func ignoreShootingMode(action: String) async throws {
        let request = ShootingControl.IgnoreShootingModeRequest(action: action)
        try await container.services.shootingControlService.ignoreShootingMode(request: request)
    }

    private func setShootingMode(value: String) async throws {
        let request = ShootingSettings.ShootingModeRequest(value: value)
        _ = try await container.services.shootingSettingsService.putShootingMode(request: request)
        let response = try await container.services.shootingSettingsService.putShootingMode(request: request)
        Logger.debug("Shooting Mode Response: \(response)", category: .viewModel)
    }

    private func setPictureStyle(value: String) async throws {
        let request = ShootingSettings.PictureStyleRequest(value: value)
        let response = try await container.services.shootingSettingsService.putPictureStyle(request: request)
        Logger.debug("Picture Style Response: \(response)", category: .viewModel)
    }

    private func setAperture(value: String) async throws {
        let request = ShootingSettings.AVRequest(value: value)
        let response = try await container.services.shootingSettingsService.putAV(request: request)
        Logger.debug("Aperture Response: \(response)", category: .viewModel)
    }

    private func setShutterSpeed(value: String) async throws {
        let request = ShootingSettings.TVRequest(value: value)
        _ = try await container.services.shootingSettingsService.putTV(request: request)
    }

    private func setISO(value: String) async throws {
        let request = ShootingSettings.ISORequest(value: value)
        let response = try await container.services.shootingSettingsService.putISO(request: request)
        Logger.debug("ISO Response: \(response)", category: .viewModel)
    }

    private func setExposureCompensation(value: String) async throws {
        let request = ShootingSettings.ExposureCompensationRequest(value: value)
        let response = try await container.services.shootingSettingsService.putExposureCompensation(request: request)
        Logger.debug("Exposure Compensation Response: \(response)", category: .viewModel)
    }

    private func setColorTemperature(value: Int) async throws {
        let request = ShootingSettings.ColorTemperatureRequest(value: value)
        let response = try await container.services.shootingSettingsService.putColorTemperature(request: request)
        Logger.debug("Color Temperature Response: \(response)", category: .viewModel)
    }

    private func setWbShift(blueAmber: Int, magentaGreen: Int) async throws {
        let wbShift = ShootingSettings.WBShiftRequest.WBShift(blueAmber: blueAmber, magentaGreen: magentaGreen)
        let request = ShootingSettings.WBShiftRequest(value: wbShift)
        let response = try await container.services.shootingSettingsService.putWbShift(request: request)
        Logger.debug("WB Shift Response: \(response)", category: .viewModel)
    }
    
    // Options Menu
    
    func getMenuItems() -> [MenuItem] {
        let editModeItem = MenuItem(
            icon: .presetSelect,
            label: "Preset 선택",
            action: { [weak self] in
                self?.handleEditModeToggle()
            }
        )
        
        let viewModeItem = MenuItem(
            icon: viewMode == .grid ? .list : .squareGrid,
            label: viewMode == .grid ? "목록으로 보기" : "갤러리로 보기",
            action: { [weak self] in
                self?.handleViewModeToggle()
            }
        )
        
        return [editModeItem, viewModeItem]
    }
    
    func handleEditModeToggle() {
        toggleEditMode()
        showModeChange = false
    }
    
    func handleViewModeToggle() {
        viewMode = viewMode == .grid ? .list : .grid
        showModeChange = false
    }
}
