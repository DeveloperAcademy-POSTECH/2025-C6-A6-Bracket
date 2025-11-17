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
    case goToPresetCreation
}

@Observable
final class TrishotSettingViewModel {
    private let container: DIContainer

    var allSelectedPresets: [Preset] = []

    init(container: DIContainer) {
        self.container = container
        loadPresets()
    }

    func loadPresets() {
        do {
            allSelectedPresets = try container.managers.presetManager.fetchSelectedPresets()
        } catch {
            Logger.error("Failed to load selected presets: \(error.localizedDescription)", category: .trishot)
        }
    }
}

extension TrishotSettingViewModel {
    func send(action: TrishotSettingAction) {
        switch action {
        case .goToTrishotSelection(let order):
            container.navigationRouter.push(to: .trishotSelection(order: order))
        case .goToTrishotActivation:
            container.navigationRouter.push(to: .trishotActivation)
        case .goToPresetCreation:
            container.navigationRouter.push(to: .presetEditor(.create, nil))
        }
    }
}
