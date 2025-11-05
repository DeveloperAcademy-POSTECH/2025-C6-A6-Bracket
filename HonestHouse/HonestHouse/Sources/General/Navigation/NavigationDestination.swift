//
//  NavigationDestination.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

enum NavigationDestination: Hashable {
    // Trishot
    case trishotSelection
    case trimode
    
    // Preset
    case presetEditor(PresetDetailMode, Preset?)
    
    // Photos
    case photoSelection
    case groupedPhotos([Photo])
}
