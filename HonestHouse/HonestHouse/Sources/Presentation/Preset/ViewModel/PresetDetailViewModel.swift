//
//  PresetViewModel.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/27/25.
//

import SwiftUI

enum PresetDetailAction {
    case popToPresetView
}

@Observable
final class PresetDetailViewModel {
    private let container: DIContainer
    private let shootingControlService: ShootingControlServiceType
    private let shootingSettingsService: ShootingSettingsServiceType
    private let presetManager: PresetManagerType
    
    var presetDetailMode: PresetDetailMode
    var newPreset: Preset?
    var selectedPreset: Preset?
    var showingCreateSheet = false
    var showingShootAlert = false
    var shootAlertPreset: Preset?
    var error: PresetError?
    
    init(
        container: DIContainer,
        presetDetailMode: PresetDetailMode,
        selectedPreset: Preset?
    ) {
        self.container = container
        self.presetDetailMode = presetDetailMode
        self.selectedPreset = selectedPreset

        self.shootingControlService = container.services.shootingControlService
        self.shootingSettingsService = container.services.shootingSettingsService
        self.presetManager = container.managers.presetManager
    }
    
    func send(action: PresetDetailAction) {
        switch action {
        case .popToPresetView:
            container.navigationRouter.pop()
        }
    }
    
    func createPreset() {
        do {
            newPreset?.updatedAt = Date()  // updatedAt을 현재 시간으로 설정
        
            if let newPreset = newPreset {
                try presetManager.createPreset(newPreset)
            }
            
            error = nil
            
            
            send(action: .popToPresetView)  // 생성 후 목록으로 돌아가기
        } catch {
            //TODO: handleError 구현 필요
        }
    }
    
    func updatePreset() {
        do {
            // updatedAt을 현재 시간으로 설정
            guard let selectedPreset else { return }
            selectedPreset.updatedAt = Date()
            
            try presetManager.updatePreset(selectedPreset)
            error = nil
            
            // 업데이트 후 목록으로 돌아가기
            send(action: .popToPresetView)
        } catch {
            //TODO: handleError 구현 필요
        }
    }
    
    func deletePreset() {
        do {
            guard let selectedPreset else { return }
            try presetManager.deletePreset(selectedPreset)
            error = nil
            
            send(action: .popToPresetView)  // 삭제 후 목록으로 돌아가기
        } catch {
            //TODO: handleError 구현 필요
        }
    }
    
    func loadPreset(by id: UUID) {
        do {
            if let preset = try presetManager.fetchPreset(by: id) {
                selectedPreset = preset
                error = nil
            }
        } catch {
            //TODO: handleError 구현 필요
        }
    }
}
