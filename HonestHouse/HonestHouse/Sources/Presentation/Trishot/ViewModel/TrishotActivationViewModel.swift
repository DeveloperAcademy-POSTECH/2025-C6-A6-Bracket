//
//  TrishotActivationViewModel.swift
//  HonestHouse
//
//  Created by Bomin Lee on 11/3/25.
//

import Foundation

enum TrishotActivationAction {
    case popToTrishotSetting
}

@MainActor
@Observable
final class TrishotActivationViewModel {
    private let container: DIContainer
    
    var currentPresetIndex: Int = 0 /// 현재 적용된 프리셋의 인덱스 ( 0 ~ 2 )
    var activatedPresets: [Preset] = []
    var isMonitoring: Bool = false
    var error: TrishotError?
    
    init(container: DIContainer) {
        self.container = container
    }
}

/// Trishot 기능 관련
extension TrishotActivationViewModel: TrishotErrorHandleable {
    var errorMessage: String? {
        error?.errorDescription
    }
    
    func isCurrentPreset(_ index: Int) -> Bool {
        isMonitoring && index == currentPresetIndex
    }
    
    func activateTrishot() {
        loadActivatedPresets()
        
        guard !activatedPresets.isEmpty else {
            error = .noPresetsSelected
            return
        }

        currentPresetIndex = 0
        error = nil

        Task {
            await applyPreset(at: currentPresetIndex)
            await startMonitoring()
        }
    }

    func deactivateTrishot() {
        error = nil
        Task {
            await stopMonitoring()
            currentPresetIndex = 0
        }
    }
    
    private func loadActivatedPresets() {
        do {
            activatedPresets = try container.managers.presetManager.fetchActivatedPresets()
        } catch {
            handleError(error)
        }
    }
    
    private func startMonitoring() async {
        guard !isMonitoring else {
            error = .monitoringAlreadyActive
            return
        }

        let success = await container.services.eventMonitorService.startMonitoring(
            onEvent: { [weak self] event in
                self?.handleEvent(event)
            },
            onError: { [weak self] monitorError in
                self?.handleMonitoringError(monitorError)
            }
        )

        if success {
            isMonitoring = true
            error = nil
        } else {
            error = .monitoringStartFailed
        }
    }

    private func stopMonitoring() async {
        guard isMonitoring else { return }

        do {
            try await container.services.eventMonitorService.stopMonitoring()
            isMonitoring = false
            error = nil
        } catch {
            handleError(error)
        }
    }

    private func handleEvent(_ event: CameraStatus.EventMonitorResponse) {
        guard let addedContents = event.addedcontents, !addedContents.isEmpty else {
            return
        }

        Logger.info("PHOTO CAPTURED: \(addedContents.joined(separator: ", "))", category: .trishot)

        Task {
            currentPresetIndex = (currentPresetIndex + 1) % activatedPresets.count
            await applyPreset(at: currentPresetIndex)
        }
    }

    private func handleMonitoringError(_ monitorError: Error) {
        isMonitoring = false
        handleError(monitorError)
    }

    /// 프리셋 적용
    private func applyPreset(at index: Int) async {
        guard index < activatedPresets.count else { return }
        
        let preset = activatedPresets[index]
                
        let shootingMode = preset.shootingMode
        let pictureStyle = preset.pictureStyle

        do {
            try await ignoreShootingMode(action: "on")
            
            defer {
                Task {
                    do {
                        try await ignoreShootingMode(action: "off")
                    } catch {
                        handleError(error)
                    }
                }
            }

            try await setShootingMode(value: shootingMode.apiValue)
            try await setPictureStyle(value: pictureStyle.apiValue)
            
            switch preset.shootingMode {
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
        } catch {
            handleError(error)
        }
    }
}

/// Shooting Control, Shooting Settings 관련
extension TrishotActivationViewModel {
    private func ignoreShootingMode(action: String) async throws {
        do {
            let request = ShootingControl.IgnoreShootingModeRequest(action: action)
            try await container.services.shootingControlService.ignoreShootingMode(request: request)
        } catch let ccapiError as CCAPIError {
            throw TrishotError.from(ccapiError: ccapiError)
        } catch {
            throw TrishotError.shootingModeIgnoreFailed
        }
    }

    private func setShootingMode(value: String) async throws {
        do {
            let request = ShootingSettings.ShootingModeRequest(value: value)
            _ = try await container.services.shootingSettingsService.putShootingMode(request: request)
        } catch let ccapiError as CCAPIError {
            throw TrishotError.from(ccapiError: ccapiError)
        } catch {
            throw TrishotError.shootingModeSetFailed
        }
    }

    private func setPictureStyle(value: String) async throws {
        do {
            let request = ShootingSettings.PictureStyleRequest(value: value)
            _ = try await container.services.shootingSettingsService.putPictureStyle(request: request)
        } catch let ccapiError as CCAPIError {
            throw TrishotError.from(ccapiError: ccapiError)
        } catch {
            throw TrishotError.pictureStyleSetFailed
        }
    }

    private func setAperture(value: String) async throws {
        do {
            let request = ShootingSettings.AVRequest(value: value)
            _ = try await container.services.shootingSettingsService.putAV(request: request)
        } catch let ccapiError as CCAPIError {
            throw TrishotError.from(ccapiError: ccapiError)
        } catch {
            throw TrishotError.apertureSetFailed
        }
    }

    private func setShutterSpeed(value: String) async throws {
        do {
            let request = ShootingSettings.TVRequest(value: value)
            _ = try await container.services.shootingSettingsService.putTV(request: request)
        } catch let ccapiError as CCAPIError {
            throw TrishotError.from(ccapiError: ccapiError)
        } catch {
            throw TrishotError.shutterSpeedSetFailed
        }
    }

    private func setISO(value: String) async throws {
        do {
            let request = ShootingSettings.ISORequest(value: value)
            _ = try await container.services.shootingSettingsService.putISO(request: request)
        } catch let ccapiError as CCAPIError {
            throw TrishotError.from(ccapiError: ccapiError)
        } catch {
            throw TrishotError.isoSetFailed
        }
    }

    private func setExposureCompensation(value: String) async throws {
        do {
            let request = ShootingSettings.ExposureCompensationRequest(value: value)
            _ = try await container.services.shootingSettingsService.putExposureCompensation(request: request)
        } catch let ccapiError as CCAPIError {
            throw TrishotError.from(ccapiError: ccapiError)
        } catch {
            throw TrishotError.exposureCompensationSetFailed
        }
    }

    private func setColorTemperature(value: Int) async throws {
        do {
            let request = ShootingSettings.ColorTemperatureRequest(value: value)
            _ = try await container.services.shootingSettingsService.putColorTemperature(request: request)
        } catch let ccapiError as CCAPIError {
            throw TrishotError.from(ccapiError: ccapiError)
        } catch {
            throw TrishotError.colorTemperatureSetFailed
        }
    }

    private func setWbShift(blueAmber: Int, magentaGreen: Int) async throws {
        do {
            let wbShift = ShootingSettings.WBShiftRequest.WBShift(blueAmber: blueAmber, magentaGreen: magentaGreen)
            let request = ShootingSettings.WBShiftRequest(value: wbShift)
            _ = try await container.services.shootingSettingsService.putWbShift(request: request)
        } catch let ccapiError as CCAPIError {
            throw TrishotError.from(ccapiError: ccapiError)
        } catch {
            throw TrishotError.wbShiftSetFailed
        }
    }
    
    /// Ability Information 가져오기, 확인용
    private func getAbilityInformation() async throws {
        let r1 = try await container.services.shootingSettingsService.getAV()
        let r2 = try await container.services.shootingSettingsService.getTV()
        let r3 = try await container.services.shootingSettingsService.getISO()
        let r4 = try await container.services.shootingSettingsService.getExposureCompensation()
        let r5 = try await container.services.shootingSettingsService.getColorTemperature()
        let r6 = try await container.services.shootingSettingsService.getWbShift()
        
        print(r1)
        print(r2)
        print(r3)
        print(r4)
        print(r5)
        print(r6)
    }
}

extension TrishotActivationViewModel {
    func send(_ action: TrishotActivationAction) {
        switch action {
        case .popToTrishotSetting:
            container.navigationRouter.pop()
        }
    }
}
