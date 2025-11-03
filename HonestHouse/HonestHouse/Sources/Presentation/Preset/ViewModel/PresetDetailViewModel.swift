//
//  PresetViewModel.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/27/25.
//

import SwiftUI
import SwiftData

@Observable
final class PresetDetailViewModel {
    var container: DIContainer
    var presetDetailMode: PresetDetailMode
    var newPreset: Preset?
    var selectedPreset: Preset?

    var showingCreateSheet = false
    var showingShootAlert = false
    var shootAlertPreset: Preset?
    
    var error: PresetError?

    private var shootingControlService: ShootingControlServiceType
    private var shootingSettingsService: ShootingSettingsServiceType
    private var presetManager: PresetManagerType
    
    enum Action {
        case popToPresetView
    }
    
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
}

//MARK: - Navigation
extension PresetDetailViewModel {
    func send(action: Action) {
        switch action {
        case .popToPresetView:
            container.navigationRouter.pop()
        }
    }
    

}

// MARK: - PresetManager CRUD
extension PresetDetailViewModel {
    
    /// Preset 생성
    func createPreset() {
        do {
            // updatedAt을 현재 시간으로 설정
            newPreset?.updatedAt = Date()
            
            if let newPreset = newPreset {
                try presetManager.createPreset(newPreset)
            }
            
            
            error = nil
            
            // 생성 후 목록으로 돌아가기
            send(action: .popToPresetView)
        } catch {
//            handleError(error)
        }
    }
    
    /// Preset 업데이트
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
//            handleError(error)
        }
    }
    
    /// Preset 삭제
    func deletePreset() {
        do {
            guard let selectedPreset else { return }
            try presetManager.deletePreset(selectedPreset)
            error = nil
            
            // 삭제 후 목록으로 돌아가기
            send(action: .popToPresetView)
        } catch {
//            handleError(error)
        }
    }
    
    /// 특정 Preset 조회 (필요 시)
    func loadPreset(by id: UUID) {
        do {
            if let preset = try presetManager.fetchPreset(by: id) {
                selectedPreset = preset
                error = nil
            }
        } catch {
//            handleError(error)
        }
    }
}
