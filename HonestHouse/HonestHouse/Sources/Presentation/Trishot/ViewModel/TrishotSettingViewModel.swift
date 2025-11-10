//
//  RemoteControllerViewModel.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

import Foundation
import SwiftUI
import CoreData

enum TrishotSettingAction {
    case goToTrishotSelection(order: Int)
    case goToTrishotActivation
}

@Observable
final class TrishotSettingViewModel {
    private let container: DIContainer

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
        }
    }
}
