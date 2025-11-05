//
//  RemoteControllerViewModel.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

import Foundation
import SwiftUI

enum TrishotSettingAction {
    case goToTrishotSelection
    case goToTrishotMode
    case togglePreset(UUID)
}

@Observable
final class TrishotSettingViewModel {
    var container: DIContainer
    
    var trishotItems: [TrishotItem] = [
        .init(preset: .stub1, isSelected: true),
        .init(preset: .stub2, isSelected: false),
        .init(preset: .stub3, isSelected: false)
    ]
    
    init(container: DIContainer) {
        self.container = container
    }
}

extension TrishotSettingViewModel {
    func send(action: TrishotSettingAction) {
        switch action {
        case .goToTrishotSelection:
            container.navigationRouter.push(to: .trishotSelection)
        
        case .goToTrishotMode:
            container.navigationRouter.push(to: .trimode)
            
        case .togglePreset(let id):
            if let index = trishotItems.firstIndex(where: { $0.id == id }) {
                trishotItems[index].isSelected.toggle()
            }
        }
    }
}
