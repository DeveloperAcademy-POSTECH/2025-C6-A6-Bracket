//
//  TrishotSelectionViewModel.swift
//  HonestHouse
//
//  Created by Subeen on 11/3/25.
//

import Foundation

final class TrishotSelectionViewModel {
    var container: DIContainer
    
    enum Action {
        case popToPresetSetting
    }
    
    init(container: DIContainer) {
        self.container = container
    }
}

extension TrishotSelectionViewModel {
    func send(_ action: Action) {
        switch action {
        case .popToPresetSetting:
            container.navigationRouter.pop()
        }
    }
}
