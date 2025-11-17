//
//  TrishotActivationViewModel.swift
//  HonestHouse
//
//  Created by Bomin Lee on 11/3/25.
//

import Foundation
import Combine

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
    var currentError: TrishotError?
    var showGuide: Bool = false

    private var presetApplicationFailureCount: Int = 0
    private let maxPresetApplicationFailures: Int = 3

    init(container: DIContainer) {
        self.container = container
    }

    func isCurrentPreset(_ index: Int) -> Bool {
        isMonitoring && index == currentPresetIndex
    }

    func showInitialGuide() {
        Logger.info("TrishotActivation appeared, resetting state", category: .trishot)
        currentError = nil
        showGuide = true
    }

    func activateTrishot() {
        Logger.info("Activating Trishot", category: .trishot)
        loadActivatedPresets()

        currentPresetIndex = 0

        Task {
            await applyPreset(at: currentPresetIndex)
            await startMonitoring()
        }
    }

    func deactivateTrishot() {
        Logger.info("Deactivating Trishot", category: .trishot)

        Task {
            await stopMonitoring()
            currentPresetIndex = 0
        }
    }
    
    func loadActivatedPresets() {
        do {
            activatedPresets = try container.managers.presetManager.fetchActivatedPresets()
        } catch {
            Logger.error("Failed to load activated presets: \(error.localizedDescription)", category: .trishot)
        }
    }

    private func startMonitoring() async {
        guard !isMonitoring else {
            Logger.warning("Monitoring already active, ignoring start request", category: .trishot)
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
            Logger.info("Event monitoring started successfully", category: .trishot)
        } else {
            Logger.error("Failed to start event monitoring - startMonitoring returned false", category: .trishot)
            currentError = .monitoringStartFailed
        }
    }

    private func stopMonitoring() async {
        do {
            try await container.services.eventMonitorService.stopMonitoring()
            isMonitoring = false
            Logger.info("Event monitoring stopped successfully", category: .trishot)
        } catch {
            Logger.error("Failed to stop monitoring: \(error.localizedDescription)", category: .trishot)
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
        Logger.error("EventMonitor error occurred: \(monitorError.localizedDescription)", category: .trishot)
        isMonitoring = false

        if let ccapiError = monitorError as? CCAPIError {
            Logger.error("CCAPI Error type: \(ccapiError)", category: .trishot)
            currentError = TrishotError.fromCCAPI(ccapiError)
        } else {
            Logger.error("Unknown monitoring error: \(monitorError)", category: .trishot)
        }
    }

    /// 프리셋 적용
    private func applyPreset(at index: Int, retryCount: Int = 0) async {
        guard index < activatedPresets.count else {
            Logger.error("Invalid preset index: \(index)", category: .trishot)
            return
        }

        let preset = activatedPresets[index]
        Logger.info("Applying preset '\(preset.name)' (index: \(index))", category: .trishot)
        let maxRetries = 3

        let shootingMode = preset.shootingMode
        let pictureStyle = preset.pictureStyle

        do {
            // Logger.debug("Setting ignoreShootingMode to ON", category: .trishot)
            try await ignoreShootingMode(action: "on")

            // Logger.debug("Setting shootingMode to \(shootingMode.apiValue)", category: .trishot)
            try await setShootingMode(value: shootingMode.apiValue)

            // Logger.debug("Setting pictureStyle to \(pictureStyle.apiValue)", category: .trishot)
            try await setPictureStyle(value: pictureStyle.apiValue)

            switch preset.shootingMode {
            case .av:
                if let aperture = preset.aperture {
                    // Logger.debug("Setting aperture to \(aperture)", category: .trishot)
                    try await setAperture(value: aperture)
                }
            case .tv:
                if let shutterSpeed = preset.shutterSpeed {
                    // Logger.debug("Setting shutterSpeed to \(shutterSpeed)", category: .trishot)
                    try await setShutterSpeed(value: shutterSpeed)
                }
            case .p:
                break
            }

            if let iso = preset.iso {
                // Logger.debug("Setting ISO to \(iso)", category: .trishot)
                try await setISO(value: iso)
            }

            if let exposureCompensation = preset.exposureCompensation {
                // Logger.debug("Setting exposureCompensation to \(exposureCompensation)", category: .trishot)
                try await setExposureCompensation(value: exposureCompensation)
            }

            if let colorTemperature = preset.colorTemperature {
                // Logger.debug("Setting colorTemperature to \(colorTemperature)", category: .trishot)
                try await setColorTemperature(value: colorTemperature)
            }

            if let tintBlueAmber = preset.tintBlueAmber, let tintMagentaGreen = preset.tintMagentaGreen {
                // Logger.debug("Setting WB shift to BA:\(tintBlueAmber), MG:\(tintMagentaGreen)", category: .trishot)
                try await setWbShift(blueAmber: tintBlueAmber, magentaGreen: tintMagentaGreen)
            }

            // Logger.debug("Setting ignoreShootingMode to OFF", category: .trishot)
            try await ignoreShootingMode(action: "off")

            Logger.info("Preset '\(preset.name)' applied successfully", category: .trishot)
            presetApplicationFailureCount = 0
        } catch let ccapiError as CCAPIError {
            try? await ignoreShootingMode(action: "off")

            let trishotError = TrishotError.fromCCAPI(ccapiError)

            // 카메라 연결 끊김이면 즉시 에러 표시
            if case .cameraDisconnected = trishotError {
                Logger.error("Camera disconnected during preset application", category: .trishot)
                currentError = .cameraDisconnected
                return
            }

            // cameraBusy는 기존처럼 재시도
            if case .cameraBusy = trishotError, retryCount < maxRetries {
                Logger.warning("Preset application busy, retrying (\(retryCount + 1)/\(maxRetries))", category: .trishot)
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                await applyPreset(at: index, retryCount: retryCount + 1)
                return
            }

            // 그 외 에러는 실패 카운터 증가
            presetApplicationFailureCount += 1
            Logger.error("Preset application failed (\(presetApplicationFailureCount)/\(maxPresetApplicationFailures)): \(ccapiError.errorDescription ?? "")", category: .trishot)

            // 3회 이상 실패 시 Alert 표시
            if presetApplicationFailureCount >= maxPresetApplicationFailures {
                currentError = .presetApplicationFailed
                presetApplicationFailureCount = 0
            }
        } catch {
            try? await ignoreShootingMode(action: "off")

            // 일반 에러도 실패 카운터 증가
            presetApplicationFailureCount += 1
            Logger.error("Preset application failed (\(presetApplicationFailureCount)/\(maxPresetApplicationFailures)): \(error.localizedDescription)", category: .trishot)

            if presetApplicationFailureCount >= maxPresetApplicationFailures {
                currentError = .presetApplicationFailed
                presetApplicationFailureCount = 0
            }
        }
    }
}

/// Shooting Control, Shooting Settings 관련
extension TrishotActivationViewModel {
    private func ignoreShootingMode(action: String) async throws {
        let request = ShootingControl.IgnoreShootingModeRequest(action: action)
        try await container.services.shootingControlService.ignoreShootingMode(request: request)
    }

    private func setShootingMode(value: String) async throws {
        let request = ShootingSettings.ShootingModeRequest(value: value)
        _ = try await container.services.shootingSettingsService.putShootingMode(request: request)
    }

    private func setPictureStyle(value: String) async throws {
        let request = ShootingSettings.PictureStyleRequest(value: value)
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

    private func setExposureCompensation(value: String) async throws {
        let request = ShootingSettings.ExposureCompensationRequest(value: value)
        _ = try await container.services.shootingSettingsService.putExposureCompensation(request: request)
    }

    private func setColorTemperature(value: Int) async throws {
        let request = ShootingSettings.ColorTemperatureRequest(value: value)
        _ = try await container.services.shootingSettingsService.putColorTemperature(request: request)
    }

    private func setWbShift(blueAmber: Int, magentaGreen: Int) async throws {
        let wbShift = ShootingSettings.WBShiftRequest.WBShift(blueAmber: blueAmber, magentaGreen: magentaGreen)
        let request = ShootingSettings.WBShiftRequest(value: wbShift)
        _ = try await container.services.shootingSettingsService.putWbShift(request: request)
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
