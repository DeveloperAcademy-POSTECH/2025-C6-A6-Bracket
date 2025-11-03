//
//  GroupedPhotosGridCellView.swift
//  HonestHouse
//
//  Created by Rama on 10/25/25.
//

import SwiftUI
import Kingfisher

struct GroupedPhotosGridCellView: View {
    let group: SimilarPhotoGroup
    @Environment(GroupedPhotosViewModel.self) var vm

    var body: some View {
        if let firstPhoto = group.photos.first {
            ZStack(alignment: .bottomLeading) {
                NavigationLink(destination: GroupedPhotosDetailView(groupedPhotos: group).environment(vm)) {
                    CachedThumbnailImageView(url: firstPhoto.thumbnailURL)
                        .frame(height: 118)
                }

                selectNumBadge()
                    .padding(8)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    private func selectNumBadge() -> some View {
        Text("\(vm.selectedCount(in: group))/\(vm.totalCount(in: group))")
            .font(.num4)
            .foregroundStyle(Color.g0)
            .frame(width: 42, height: 24)
            .background {
                Capsule()
                    .fill(Color.black.opacity(0.2))
                    .strokeBorder(Color.g0, lineWidth: 0.5)
            }
    }
}
