//
//  TrishotItem.swift
//  HonestHouse
//
//  Created by Subeen on 10/30/25.
//

import Foundation

struct TrishotItem: Identifiable {
    let id: UUID
    let preset: Preset
    var isSelected: Bool
    
    init(preset: Preset, isSelected: Bool = false) {
        self.id = preset.id
        self.preset = preset
        self.isSelected = isSelected
    }
}
