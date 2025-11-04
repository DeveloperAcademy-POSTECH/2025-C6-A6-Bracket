//
//  MainViewModel.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/24/25.
//

import SwiftUI

enum MainAction {
    case goToTriShotSelection
    case goToTriMode
    case goToPresetEditor(PresetDetailMode, Preset)
    case goToPhotoSelection
}

@Observable
final class MainViewModel {
    enum Action {
        case goToPresetEditor(PresetDetailMode, Preset)
        case goToPhotoSelection
    }
    
    var selectedSegment: MainViewSegmentType = .trishot
    var segments: [MainViewSegmentType] = [.trishot, .preset]
    var isPresetEditMode: Bool = false
    var selectedPreset: Preset?
    
    var showEditButton: Bool {
        selectedSegment == .preset
    }
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func send(action: MainAction) {
        switch action {
        case .goToPresetEditor(let mode, let preset):
            container.navigationRouter.push(to: .presetEditor(mode, preset))
            
        case .goToPhotoSelection:
            container.navigationRouter.push(to: .photoSelection)
        }
    }
    
    func setSelectedSegment(_ segment: MainViewSegmentType) {
        guard selectedSegment != segment else { return }
        selectedSegment = segment
        exitEditMode()
    }
    
    func toggleEditMode() {
        isPresetEditMode.toggle()
    }
    
    func exitEditMode() {
        isPresetEditMode = false
    }
}

extension MainViewModel {
    
    
}
