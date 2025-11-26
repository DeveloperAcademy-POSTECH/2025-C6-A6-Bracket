//
//  PresetStateObserver.swift
//  HonestHouse
//
//  Created by BoMin Lee on 11/25/25.
//

import Foundation
import Combine

final class PresetStateObserver: ObservableObject {
    @Published var didChange: Bool = false

    func notifyPresetChanged() {
        didChange.toggle()
    }
}
