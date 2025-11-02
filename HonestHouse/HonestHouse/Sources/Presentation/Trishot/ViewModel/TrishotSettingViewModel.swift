//
//  RemoteControllerViewModel.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

import Foundation
import SwiftUI

@Observable
final class TrishotSettingViewModel {
    var container: DIContainer
    
    var trishotItems: [TrishotItem] = [
        .init(preset: .stub1, isSelected: true),
        .init(preset: .stub2, isSelected: false),
        .init(preset: .stub3, isSelected: false)
    ]
    
    enum Action {
        case goToTrishotSelection
        case togglePreset(UUID)
    }
    
    init(container: DIContainer) {
        self.container = container
    }
}

extension TrishotSettingViewModel {
    func send(action: Action) {
        switch action {
        case .goToTrishotSelection:
            container.navigationRouter.push(to: .trishotSelection)
        case .togglePreset(let id):
            if let index = trishotItems.firstIndex(where: { $0.id == id }) {
                trishotItems[index].isSelected.toggle()
            }
        }
    }
}
