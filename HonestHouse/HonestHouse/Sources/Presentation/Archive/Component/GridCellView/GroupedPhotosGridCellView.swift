//
//  GroupedPhotosGridCellView.swift
//  HonestHouse
//
//  Created by Rama on 10/25/25.
//

import SwiftUI
import Kingfisher

struct GroupedPhotosGridCellView: View {
    @Environment(GroupedPhotosViewModel.self) var vm
    
    let group: SimilarPhotoGroup
    
    var body: some View {
        if let firstPhoto = group.photos.first {
            NavigationLink {
                destinationView()
            } label: {
                thumbnailView(for: firstPhoto)
            }
        }
    }
    
    private func destinationView() -> some View {
        GroupedPhotosDetailView(groupedPhotos: group)
            .environment(vm)
    }
    
    private func thumbnailView(for photo: Photo) -> some View {
        CachedGridCellImageView(url: photo.displayURL, originalURL: photo.url)
            .overlay {
                thumbnailBorder()
            }
            .overlay(alignment: .bottomLeading) {
                selectNumBadge()
                    .padding(8)
            }
            .overlay(alignment: .topTrailing) {
                if group.isExtra {
                    extraGroupBadge()
                        .padding(8)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func thumbnailBorder() -> some View {
        RoundedRectangle(cornerRadius: 8)
            .strokeBorder(
                vm.hasSelectedPhotoInGroup(in: group) ? Color.yellow1 : Color.clear,
                lineWidth: 1.5
            )
    }
    
    private func selectNumBadge() -> some View {
        Text("\(vm.selectedCountInGroup(in: group))/\(vm.totalCountInGroup(in: group))장")
            .fontStyle(.num6)
            .foregroundStyle(vm.hasSelectedPhotoInGroup(in: group) ? Color.g12 : Color.g0 )
            .padding(.vertical, 3)
            .padding(.horizontal, 8)
            .background {
                ZStack {
                    VisualEffectBlurView()
                        .blur(radius: 6, opaque: vm.hasSelectedPhotoInGroup(in: group) ? false : true)
                        .overlay {
                            (vm.hasSelectedPhotoInGroup(in: group) ? Color.yellow1 : Color.black.opacity(0.2))
                        }
                }
            }
            .clipShape(Capsule())
    }
    
    private func extraGroupBadge() -> some View {
        Text("기타")
            .fontStyle(.num7)
            .foregroundStyle(Color.g0)
            .padding(.vertical, 3)
            .padding(.horizontal, 8)
            .background {
                ZStack {
                    VisualEffectBlurView()
                        .blur(radius: 6, opaque: true)
                        .overlay {
                            Color.black.opacity(0.2)
                        }
                }
            }
            .clipShape(Capsule())
    }
}
