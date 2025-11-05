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
        case .trishotSelection(let order):
            TrishotSelectionView(vm: .init(container: container, targetOrder: order))
        case .trishotActivation:
            TrishotActivationView(vm: .init(container: container))
                
        // Preset
        case .presetEditor(let mode, let preset):
            PresetDetailView(preset: .init(name: "preset1"), mode: mode)

        // Photos
        case .photoSelection:
            PhotoSelectionView(vm: PhotoSelectionViewModel(container: container))
            
        case .groupedPhotos(let selectedPhotos): // ModeType을 switch로 관리하거나, 뷰 내에서 분기처리
            GroupedPhotosView(vm: GroupedPhotosViewModel(container: container, selectedPhotos: selectedPhotos))
        }
    }
}
