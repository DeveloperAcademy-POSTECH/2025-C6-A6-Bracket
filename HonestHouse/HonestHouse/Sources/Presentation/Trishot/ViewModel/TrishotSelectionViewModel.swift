//
//  TrishotSelectionViewModel.swift
//  HonestHouse
//
//  Created by Subeen on 11/3/25.
//

import Foundation
import SwiftUI
import CoreData

@Observable
final class TrishotSelectionViewModel {
    var container: DIContainer

    var allPresets: [Preset] = []
    var targetOrder: Int
    var currentSelectedPresetId: UUID?
    var otherSelectedPresetIds: Set<UUID> = []

    enum Action {
        case popToTrishotSetting
    }

    init(container: DIContainer, targetOrder: Int) {
        self.container = container
        self.targetOrder = targetOrder
        loadPresets()
        loadSelectedPresets()
    }

    private func loadPresets() {
        do {
            allPresets = try container.managers.presetManager.fetchAllPresets()
        } catch {
            print("Failed to load presets: \(error.localizedDescription)")
        }
    }

    private func loadSelectedPresets() {
        do {
            let selectedPresets = try container.managers.presetManager.fetchSelectedPresets()

            for (index, preset) in selectedPresets.enumerated() {
                if index == targetOrder {
                    currentSelectedPresetId = preset.id
                } else {
                    otherSelectedPresetIds.insert(preset.id)
                }
            }
        } catch {
            print("Failed to load selected presets: \(error.localizedDescription)")
        }
    }

    func selectPreset(_ presetId: UUID) {
        do {
            try container.managers.presetManager.updateSelectedPresetAtOrder(order: targetOrder, presetId: presetId)
            currentSelectedPresetId = presetId
        } catch {
            print("Failed to select preset: \(error.localizedDescription)")
        }
    }

    func isPresetSelected(_ presetId: UUID) -> Bool {
        currentSelectedPresetId == presetId
    }

    func isPresetOccupied(_ presetId: UUID) -> Bool {
        otherSelectedPresetIds.contains(presetId)
    }
}

extension TrishotSelectionViewModel {
    func send(_ action: TrishotSelection) {
        switch action {
        case .popToTrishotSetting:
            container.navigationRouter.pop()
        }
    }
}
