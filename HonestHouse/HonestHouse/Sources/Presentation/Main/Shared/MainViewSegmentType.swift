//
//  MainViewSegmentType.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/26/25.
//

import Foundation

enum MainViewSegmentType: CaseIterable {
    case trishot
    case preset
    
    var displayName: String {
        switch self {
        case .trishot:
            return "Tri-shot"
        case .preset:
            return "Preset"
        }
    }
}
