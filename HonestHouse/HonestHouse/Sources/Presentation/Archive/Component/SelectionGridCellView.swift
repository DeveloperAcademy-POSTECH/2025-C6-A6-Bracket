//
//  SelectionGridCellView.swift
//  HonestHouse
//
//  Created by Rama on 10/22/25.
//

import SwiftUI
import Kingfisher

struct SelectionGridCellView: View {
    @Environment(PhotoSelectionViewModel.self) var vm
    
    let photo: Photo
    let isSelected: Bool
    let onTapSelectionGridCell: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationLink(destination: PhotoSelectionDetailView(initialPhoto: photo).environment(vm)) {
                CachedGridCellImageView(url: photo.thumbnailURL, originalURL: photo.url)
            }
            
            Button(action: onTapSelectionGridCell) {
                Group {
                    if isSelected {
                        Image(.checkSelectBtnS)
                            .resizable()
                    } else {
                        Image(.checkUnselectBtnS)
                            .resizable()
                    }
                }
                .frame(width: 24, height: 24)
                .padding(6)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
