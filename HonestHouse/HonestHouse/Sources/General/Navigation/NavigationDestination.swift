//
//  NavigationDestination.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

enum NavigationDestination: Hashable {
    // Trishot
    case trishotSelection(order: Int)
    case trishotActivation
    
    // Preset
    case presetEditor(ViewMode, Preset?)
    
    // Photos
    case photoSelection
    case groupedPhotos([Photo])
}
