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
    // MARK: - Published Properties
    var currentPreset: CameraPreset
    var viewMode: ViewMode
    var isLoading: Bool = false
    var errorMessage: String?
    var showCameraModeSelector: Bool = false
    var activeSlider: SettingType?
    
    // MARK: - Private Properties
    private var originalPreset: CameraPreset?
    
    // MARK: - Initialization
    init(preset: CameraPreset? = nil, mode: ViewMode = .view) {
        if let preset = preset {
            self.currentPreset = preset
            self.viewMode = mode
        } else {
            // Create mode with default preset
            self.currentPreset = CameraPreset(name: "새 프리셋")
            self.viewMode = .create
        }
    }
    
    // MARK: - View Mode Management
    func switchToEditMode() {
        guard viewMode == .view else { return }
        originalPreset = currentPreset.copy()
        viewMode = .edit
    }
    
    func switchToViewMode() {
        viewMode = .view
        activeSlider = nil
        showCameraModeSelector = false
    }
    
    func initializeForCreate() {
        currentPreset = CameraPreset(name: "새 프리셋")
        viewMode = .create
        originalPreset = nil
    }
    
    // MARK: - Camera Mode Management
    func changeCameraMode(to mode: CameraMode) {
        
        
        
        guard currentPreset.cameraMode != mode else { return }
        
        currentPreset.cameraMode = mode
        
        // Auto 값 처리
        switch mode {
        case .P:
            // P모드: 조리개와 셔터스피드 Auto
            currentPreset.aperture = nil
            currentPreset.shutterSpeed = nil
            
        case .Av:
            // Av모드: 셔터스피드 Auto
            currentPreset.shutterSpeed = nil
            if currentPreset.aperture == nil {
                currentPreset.aperture = 2.8 // 기본값
            }
            
        case .Tv:
            // Tv모드: 조리개 Auto
            currentPreset.aperture = nil
            if currentPreset.shutterSpeed == nil {
                currentPreset.shutterSpeed = 1/125 // 기본값
            }
        }
    }
    
    // MARK: - Button State Management
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
            return currentPreset.cameraMode == .Av ? .active : .disabled
            
        case .shutterSpeed:
            return currentPreset.cameraMode == .Tv ? .active : .disabled
            
        case .iso, .filter, .tint, .exposure, .colorTemp:
            return .active
        }
    }
    
    func isSettingEditable(_ type: SettingType) -> Bool {
        return getButtonState(for: type) == .active
    }
    
    // MARK: - Value Updates
    func updateAperture(_ value: Double) {
        guard isSettingEditable(.aperture) else { return }
        currentPreset.aperture = value
    }
    
    func updateShutterSpeed(_ value: Double) {
        guard isSettingEditable(.shutterSpeed) else { return }
        currentPreset.shutterSpeed = value
    }
    
    func updateISO(_ value: Int) {
        guard isSettingEditable(.iso) else { return }
        currentPreset.iso = value
    }
    
    func updateExposureCompensation(_ value: Double) {
        currentPreset.exposureCompensation = value
    }
    
    func updateColorTemperature(_ value: Int) {
        currentPreset.colorTemperature = value
    }
    
//    func toggleFilter() {
//        guard isSettingEditable(.filter) else { return }
//        currentPreset.filterEnabled.toggle()
//    }
    
    // MARK: - Value Formatting
    func formatAperture(_ value: Double?) -> String {
        guard let value = value else { return "Auto" }
        // 소수점 처리
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return "f/\(Int(value))"
        } else {
            return "f/\(String(format: "%.1f", value))"
        }
    }
    
    func formatShutterSpeed(_ value: Double?) -> String {
        guard let value = value else { return "Auto" }
        
        if value < 1 {
            let denominator = Int(1/value)
            return "1/\(denominator)"
        } else if value.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(value))\""
        } else {
            return "\(String(format: "%.1f", value))\""
        }
    }
    
    func formatISO(_ value: Int) -> String {
        return "\(value)"
    }
    
    func formatExposureCompensation(_ value: Double) -> String {
        if value > 0 {
            return "+\(String(format: "%.1f", value))"
        } else if value < 0 {
            return String(format: "%.1f", value)
        } else {
            return "+0.0"
        }
    }
    
    func formatColorTemperature(_ value: Int) -> String {
        return "\(value)K"
    }
    
    // MARK: - Data Persistence
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
    
    private func arePresetsEqual(_ lhs: CameraPreset, _ rhs: CameraPreset) -> Bool {
        return lhs.cameraMode == rhs.cameraMode &&
               lhs.aperture == rhs.aperture &&
               lhs.shutterSpeed == rhs.shutterSpeed &&
               lhs.iso == rhs.iso &&
               lhs.tint == rhs.tint &&
               lhs.exposureCompensation == rhs.exposureCompensation &&
               lhs.colorTemperature == rhs.colorTemperature
    }
    
    // MARK: - Slider Ranges
    func getISOValues() -> [Int] {
        return CameraConstants.isoValues
    }
    
    func getApertureValues() -> [Double] {
        return CameraConstants.apertureValues
    }
    
    func getShutterSpeedValues() -> [Double] {
        return CameraConstants.shutterSpeedValues
    }
    
    func getClosestIndex(for value: Double, in array: [Double]) -> Int {
        guard !array.isEmpty else { return 0 }
        
        var closestIndex = 0
        var minDifference = abs(array[0] - value)
        
        for (index, element) in array.enumerated() {
            let difference = abs(element - value)
            if difference < minDifference {
                minDifference = difference
                closestIndex = index
            }
        }
        
        return closestIndex
    }
    
    func getClosestIndex(for value: Int, in array: [Int]) -> Int {
        guard !array.isEmpty else { return 0 }
        
        var closestIndex = 0
        var minDifference = abs(array[0] - value)
        
        for (index, element) in array.enumerated() {
            let difference = abs(element - value)
            if difference < minDifference {
                minDifference = difference
                closestIndex = index
            }
        }
        
        return closestIndex
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
