//
//  TrishotSelectionViewModel.swift
//  HonestHouse
//
//  Created by Subeen on 11/3/25.
//

import Foundation

enum TrishotSelection {
    case popToPresetSetting
}

final class TrishotSelectionViewModel {
    var container: DIContainer
    
    init(container: DIContainer) {
        self.container = container
    }
}

extension TrishotSelectionViewModel {
    func send(_ action: TrishotSelection) {
        switch action {
        case .popToPresetSetting:
            container.navigationRouter.pop()
        }
    }
}
