//
//  PresetViewModel.swift
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
    var viewMode: ViewMode
    var isLoading: Bool = false
    var errorMessage: String?
    var showCameraModeSelector: Bool = false
    var activePicker: SettingType?
    
    private var originalPreset: Preset?
    
    init(
        container: DIContainer,
        mode: ViewMode,
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

    func getButtonState(for type: SettingType) -> ButtonState {
        // 조회 모드에서는 모든 버튼이 viewOnly
        // TODO: 값에 따라 노란색 / 비활성화
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
    
    // Formatting Values
//    func formatAperture(_ value: String?) -> String {
//        guard let value = value else { return "Auto" }
//        // 소수점 처리
//        if value.truncatingRemainder(dividingBy: 1) == 0 {
//            return "f/\(Int(value))"
//        } else {
//            return "f/\(String(format: "%.1f", value))"
//        }
//    }
    
//    func formatShutterSpeed(_ value: Double?) -> String {
//        guard let value = value else { return "Auto" }
//        
//        if value < 1 {
//            let denominator = Int(1/value)
//            return "1/\(denominator)"
//        } else if value.truncatingRemainder(dividingBy: 1) == 0 {
//            return "\(Int(value))\""
//        } else {
//            return "\(String(format: "%.1f", value))\""
//        }
//    }
    
//    func formatISO(_ value: Int) -> String {
//        return "\(value)"
//    }
    
//    func formatExposureCompensation(_ value: Double) -> String {
//        if value > 0 {
//            return "+\(String(format: "%.1f", value))"
//        } else if value < 0 {
//            return String(format: "%.1f", value)
//        } else {
//            return "+0.0"
//        }
//    }
    
    func formatColorTemperature(_ value: Int) -> String {
        return "\(value)K"
    }
    
    // Data Persistence
    func savePreset() async throws {
        isLoading = true
        defer { isLoading = false }
        
        // 실제 저장 로직 구현
        currentPreset.updatedAt = Date()
        
        // API 호출 또는 로컬 저장 로직
        try await Task.sleep(nanoseconds: 500_000_000) // 시뮬레이션
        
        switchToViewMode()
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
    
    // 임시 세팅값 가져오기
    func getISOValues() -> [String] {
        return CameraConstants.isoValues
    }
    
    func getApertureValues() -> [String] {
        return CameraConstants.apertureValues
    }
    
    func getShutterSpeedValues() -> [String] {
        return CameraConstants.shutterSpeedValues
    }
    
    func getPictureStyleValues() -> [String] {
        return CameraConstants.pictureStyleValues
    }
    
    func getTintMagentGreenValues() -> [Int] {
        return CameraConstants.tintMagentaGreenValues
    }
    
    func getExposureCompensationValues() -> [String] {
        return CameraConstants.exposureCompensationRange
            .map(\.description)
    }
    
    func getColorTemperatureValues() -> [String] {
        return CameraConstants.colorTemperatureRange
            .map(\.description)
    }
}
//MARK: - Navigation
//extension PresetDetailViewModel {
//    func send(action: Action) {
//        switch action {
//        case .popToPresetView:
//            container.navigationRouter.pop()
//        }
//    }
//}

// MARK: - PresetManager CRUD
//extension PresetDetailViewModel {
//    
//    /// Preset 생성
//    func createPreset() {
//        do {
//            // updatedAt을 현재 시간으로 설정
//            newPreset?.updatedAt = Date()
//            
//            if let newPreset = newPreset {
//                try presetManager.createPreset(newPreset)
//            }
//            
//            
//            error = nil
//            
//            // 생성 후 목록으로 돌아가기
//            send(action: .popToPresetView)
//        } catch {
////            handleError(error)
//        }
//    }
//    
//    /// Preset 업데이트
//    func updatePreset() {
//        do {
//            // updatedAt을 현재 시간으로 설정
//            guard let selectedPreset else { return }
//            selectedPreset.updatedAt = Date()
//            
//            try presetManager.updatePreset(selectedPreset)
//            error = nil
//            
//            // 업데이트 후 목록으로 돌아가기
//            send(action: .popToPresetView)
//        } catch {
////            handleError(error)
//        }
//    }
//    
//    /// Preset 삭제
//    func deletePreset() {
//        do {
//            guard let selectedPreset else { return }
//            try presetManager.deletePreset(selectedPreset)
//            error = nil
//            
//            // 삭제 후 목록으로 돌아가기
//            send(action: .popToPresetView)
//        } catch {
////            handleError(error)
//        }
//    }
//    
//    /// 특정 Preset 조회 (필요 시)
//    func loadPreset(by id: UUID) {
//        do {
//            if let preset = try presetManager.fetchPreset(by: id) {
//                selectedPreset = preset
//                error = nil
//            }
//        } catch {
////            handleError(error)
//        }
//    }
//}
