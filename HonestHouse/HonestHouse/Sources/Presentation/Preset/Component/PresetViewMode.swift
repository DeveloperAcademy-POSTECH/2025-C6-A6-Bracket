//
//  PresetViewMode.swift
//  HonestHouse
//
//  Created by Subeen on 11/6/25.
//

import Foundation

enum PresetViewMode: String, CaseIterable {
    case grid = "그리드"
    case list = "리스트"
    
    var iconName: String {
        switch self {
        case .grid:
            return "square.grid.2x2"
        case .list:
            return "list.bullet"
        }
    }
    
    var alternativeIconName: String {
        switch self {
        case .grid:
            return "rectangle.grid.1x2"
        case .list:
            return "square.grid.2x2"
        }
    }
}
