//
//  SelectionGridCellView.swift
//  HonestHouse
//
//  Created by Rama on 10/22/25.
//

import SwiftUI
import Kingfisher

struct SelectionGridCellView: View {
    let photo: Photo
    let isSelected: Bool
    let onTapSelectionGridCell: () -> Void
    @Environment(PhotoSelectionViewModel.self) var vm
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationLink(destination: PhotoSelectionDetailView(initialPhoto: photo).environment(vm)) {
                CachedThumbnailImageView(url: photo.thumbnailURL)
                    .frame(height: 78)
            }
            
            Button(action: onTapSelectionGridCell) {
                Group {
                    ZStack(alignment: .bottomTrailing) {
                        if isSelected {
                            Image(.checkSelectBtnS)
                                .resizable()
                        } else {
                            Image(.checkUnselectBtnS)
                                .resizable()
                        }
                    }
                    .frame(width: 20, height: 20)
                    .padding(.bottom, 8)
                    .padding(.trailing, 8)
                }
                .contentShape(Rectangle())
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    SelectionGridCellView(photo: Photo.mockPhoto(), isSelected: true, onTapSelectionGridCell: {
        print("Tapped")
    })
    .environment(PhotoSelectionViewModel(container: DIContainer.stub))
}
