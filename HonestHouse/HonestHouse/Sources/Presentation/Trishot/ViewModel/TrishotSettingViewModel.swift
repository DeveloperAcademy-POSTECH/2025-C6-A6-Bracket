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
    
    init(container: DIContainer) {
        self.container = container
        loadPresets()
    }

    func loadPresets() {
        do {
            allSelectedPresets = try container.managers.presetManager.fetchSelectedPresets()
            activatedPresets = try container.managers.presetManager.fetchActivatedPresets()
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

        if isCurrentlyActivated && activatedPresets.count <= 2 {
            if activatedPresets.count == 1 {
                error = .insufficientPresets
                return
            }

            let deactivatedPresets = allSelectedPresets.filter { preset in
                !activatedPresets.contains { $0.id == preset.id }
            }

            guard let presetToActivate = deactivatedPresets.first else {
                error = .noDeactivatedPresetAvailable
                return
            }

            do {
                try container.managers.presetManager.toggleSelectedPresetActivation(presetId: presetId)
                try container.managers.presetManager.toggleSelectedPresetActivation(presetId: presetToActivate.id)
                loadPresets()
            } catch {
                handleError(error)
            }
        } else {
            do {
                try container.managers.presetManager.toggleSelectedPresetActivation(presetId: presetId)
                loadPresets()
            } catch {
                handleError(error)
            }
        }
    }
}
