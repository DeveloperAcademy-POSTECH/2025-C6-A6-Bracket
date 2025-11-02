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
    var selectedPreset: Preset

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
        selectedPreset: Preset
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
