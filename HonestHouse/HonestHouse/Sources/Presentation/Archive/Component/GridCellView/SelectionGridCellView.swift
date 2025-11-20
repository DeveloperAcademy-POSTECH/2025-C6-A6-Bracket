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
                CachedGridCellImageView(url: photo.thumbnailURL, fallbackURL: photo.thumbnailURL)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(isSelected ? Color.yellow1 : Color.clear, lineWidth: 1)
                    )
                
            }
        
            checkButtonView()
                .padding(6)
            
            GeometryReader { geo in
                Color.clear
                    .frame(width: geo.size.width / 2, height: geo.size.height / 2)
                    .contentShape(Rectangle())
                    .onTapGesture(perform: onTapSelectionGridCell)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func checkButtonView() -> some View {
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
    }
}
