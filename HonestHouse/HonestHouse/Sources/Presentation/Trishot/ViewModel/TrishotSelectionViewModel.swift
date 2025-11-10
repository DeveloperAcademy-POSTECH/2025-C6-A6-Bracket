//
//  TrishotSelectionViewModel.swift
//  HonestHouse
//
//  Created by Subeen on 11/3/25.
//

import Foundation
import SwiftUI
import CoreData

enum TrishotSelectionAction {
    case popToTrishotSetting
}

@Observable
final class TrishotSelectionViewModel {
    private let container: DIContainer

    var allPresets: [Preset] = []
    var targetOrder: Int
    var selectedPresets: [Preset] = []

    var currentSelectedPreset: Preset? {
        selectedPresets.indices.contains(targetOrder) ? selectedPresets[targetOrder] : nil
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
            selectedPresets = try container.managers.presetManager.fetchSelectedPresets()
        } catch {
            print("Failed to load selected presets: \(error.localizedDescription)")
        }
    }

    func selectPreset(_ presetId: UUID) {
        do {
            try container.managers.presetManager.updateSelectedPresetAtOrder(order: targetOrder, presetId: presetId)
            loadSelectedPresets()
        } catch {
            print("Failed to select preset: \(error.localizedDescription)")
        }
    }

    func isPresetSelected(_ presetId: UUID) -> Bool {
        currentSelectedPreset?.id == presetId
    }

    func isPresetOccupied(_ presetId: UUID) -> Bool {
        selectedPresets.enumerated().contains { index, preset in
            index != targetOrder && preset.id == presetId
        }
    }

    func getOccupiedOrder(_ presetId: UUID) -> Int? {
        selectedPresets.enumerated().first { index, preset in
            index != targetOrder && preset.id == presetId
        }?.offset
    }
}

extension TrishotSelectionViewModel {
    func send(_ action: TrishotSelectionAction) {
        switch action {
        case .popToTrishotSetting:
            container.navigationRouter.pop()
        }
    }
}
