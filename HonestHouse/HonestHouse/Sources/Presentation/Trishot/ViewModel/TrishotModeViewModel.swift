//
//  TrishotModeViewModel.swift
//  HonestHouse
//
//  Created by Subeen on 11/3/25.
//

import Foundation

enum TrishotAction {
    case popToSetting
}

@Observable
final class TrishotModeViewModel {
    var container: DIContainer
    var currentPresetIndex: Int = 0 // 현재 적용된 프리셋의 인덱스 ( 0 ~ 2 )
    
    init(container: DIContainer) {
        self.container = container
    }
}

extension TrishotModeViewModel {
    func send(_ action: TrishotAction) {
        switch action {
        case .popToSetting:
            container.navigationRouter.pop()
        }
    }
    
    func deactivate() {
        // TODO: - Stop trishot
        send(.popToSetting)
    }
}
