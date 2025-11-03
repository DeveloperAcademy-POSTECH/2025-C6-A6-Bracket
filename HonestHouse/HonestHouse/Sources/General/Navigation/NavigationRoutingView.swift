//
//  NavigationRoutingView.swift
//  HonestHouse
//
//  Created by Subeen on 10/29/25.
//

import SwiftUI

struct NavigationRoutingView: View {
    @EnvironmentObject var container: DIContainer
    @State var destination: NavigationDestination
    
    var body: some View {
        switch destination {
            
        // Trishot
        case .trishotSelection:
            Text("trimode selection")
        case .trimode:
            Text("trimode")
                
        // Preset
        case .presetEditor(let mode, let preset):
            PresetDetailView(vm: PresetDetailViewModel(container: container, presetDetailMode: mode, selectedPreset: preset))
        // Photos
        case .photoSelection:
            PhotoSelectionView(vm: PhotoSelectionViewModel(container: container))
            
        case .groupedPhotos(let selectedPhotos): // ModeType을 switch로 관리하거나, 뷰 내에서 분기처리
            GroupedPhotosView(vm: GroupedPhotosViewModel(container: container, selectedPhotos: selectedPhotos))
        }
    }
}
