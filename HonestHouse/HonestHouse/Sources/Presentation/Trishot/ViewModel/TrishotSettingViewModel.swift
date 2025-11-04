//
//  RemoteControllerViewModel.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

import Foundation
import SwiftUI
import CoreData

@Observable
final class TrishotSettingViewModel {
    enum Action {
        case goToTrishotSelection(order: Int)
        case goToTrishotActivation
        case togglePreset(UUID)
    }

    var container: DIContainer

    var allSelectedPresets: [Preset] = []
    var activatedPresets: [Preset] = []
    var error: TrishotError?

    private var presetManager: PresetManagerType
    
    init(container: DIContainer) {
        self.container = container
        self.presetManager = container.managers.presetManager
        loadPresets()
    }

    func loadPresets() {
        do {
            allSelectedPresets = try presetManager.fetchSelectedPresets()
            activatedPresets = try presetManager.fetchActivatedPresets()
            error = nil
        } catch {
            handleError(error)
        }
    }

    func isPresetActivated(_ presetId: UUID) -> Bool {
        return activatedPresets.contains { $0.id == presetId }
    }
}

extension TrishotSettingViewModel: TrishotErrorHandleable {
    var errorMessage: String? {
        error?.errorDescription
    }
}

extension TrishotSettingViewModel {
    func send(action: TrishotSettingAction) {
        switch action {
        case .goToTrishotSelection(let order):
            container.navigationRouter.push(to: .trishotSelection(order: order))

        case .goToTrishotActivation:
            container.navigationRouter.push(to: .trishotActivation)

        case .togglePreset(let id):
            togglePresetSelection(id)
        }
    }

    private func togglePresetSelection(_ presetId: UUID) {
        let isCurrentlyActivated = isPresetActivated(presetId)


        if isCurrentlyActivated && activatedPresets.count == 2 {
            let deactivatedPresets = allSelectedPresets.filter { preset in
                !activatedPresets.contains { $0.id == preset.id }
            }

            guard let presetToActivate = deactivatedPresets.first else {
                error = .noDeactivatedPresetAvailable
                return
            }

            do {
                try presetManager.toggleSelectedPresetActivation(presetId: presetId)
                try presetManager.toggleSelectedPresetActivation(presetId: presetToActivate.id)
                loadPresets()
            } catch {
                handleError(error)
            }
        } else {
            do {
                try presetManager.toggleSelectedPresetActivation(presetId: presetId)
                loadPresets()
            } catch {
                handleError(error)
            }
        }
    }
}
