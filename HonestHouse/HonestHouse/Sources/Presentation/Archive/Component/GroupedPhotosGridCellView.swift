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
        NavigationLink(destination: GroupedPhotosDetailView(groupedPhotos: group).environment(vm)) {
            if let firstPhoto = group.photos.first {
                CachedThumbnailImage(url: firstPhoto.thumbnailURL)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 160, height: 120)
                    .overlay(
                        ZStack(alignment: .topTrailing) {
                            Text("\(group.photos.count)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                                .padding(8)
                        }
                    )
            }
        }
    }
}
