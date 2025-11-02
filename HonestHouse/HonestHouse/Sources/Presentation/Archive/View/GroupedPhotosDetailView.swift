//
//  GroupedPhotosDetailView.swift
//  HonestHouse
//
//  Created by Rama on 10/22/25.
//

import SwiftUI
import Kingfisher

struct GroupedPhotosDetailView: View {
    let groupedPhotos: SimilarPhotoGroup
    @Environment(GroupedPhotosViewModel.self) var vm

    var body: some View {
        TabView {
            ForEach(groupedPhotos.photos) { photo in
                photoDetailView(photo: photo)
                    .tag(photo)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never)) // PageControl 숨김
    }

    private func photoDetailView(photo: Photo) -> some View {
        ZStack(alignment: .bottomTrailing) {
            // Progressive Display Image (Thumbnail → Display → Display 실패 시 원본)
            ProgressiveDisplayImage(
                thumbnailURL: photo.thumbnailURL,
                displayURL: photo.displayURL,
                originalURL: photo.url
            )

            // 선택/해제 버튼
            selectionButton(photo: photo)
                .padding(16)
        }
        .task {
            // 현재 사진이 나타날 때 좌우 1-2장 prefetch
            vm.prefetchAdjacentPhotosInGroup(group: groupedPhotos, current: photo)
        }
    }

    private func selectionButton(photo: Photo) -> some View {
        Button {
            vm.toggleGroupedPhotoView(for: photo)
        } label: {
            if vm.selectedPhotosInGroup.contains(where: { $0.id == photo.id }) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 32, height: 32)

                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 32))
                }
            } else {
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 32, height: 32)
            }
        }
    }
}
