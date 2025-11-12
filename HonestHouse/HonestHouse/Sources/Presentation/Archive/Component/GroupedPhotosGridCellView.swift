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
            ZStack(alignment: .topTrailing) {
                ZStack(alignment: .bottomLeading) {
                    NavigationLink(destination: GroupedPhotosDetailView(groupedPhotos: group).environment(vm)) {
                        CachedGridCellImageView(url: firstPhoto.displayURL, originalURL: firstPhoto.url)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(vm.hasSelectedPhotoInGroup(in: group) ? Color.yellow1 : Color.clear, lineWidth: 1.5)
                            )
                    }
                    
                    selectNumBadge()
                        .padding(8)
                }
                if group.isExtra {
                    extraGroupBadge()
                        .padding(8)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    private func selectNumBadge() -> some View {
        Text("\(vm.selectedCountInGroup(in: group))/\(vm.totalCountInGroup(in: group))장")
            .font(.num6)
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
            .font(.num7)
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
