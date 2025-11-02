//
//  PhotoSelectionDetailView.swift
//  HonestHouse
//
//  Created by Rama on 10/22/25.
//

import SwiftUI
import Kingfisher

struct PhotoSelectionDetailView: View {
    let initialPhoto: Photo
    @Environment(PhotoSelectionViewModel.self) var vm

    @State private var selectedURL: String
    @State private var photos: [Photo] = []  // 스냅샷 (chunk 변경 무시)

    init(initialPhoto: Photo) {
        self.initialPhoto = initialPhoto
        self._selectedURL = State(initialValue: initialPhoto.url)
    }

    var body: some View {
        TabView(selection: $selectedURL) {
            ForEach(photos) { photo in
                photoDetailView(photo: photo)
                    .tag(photo.url)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never)) // PageControl 숨김
        .task {
            // 진입 시 현재 photos 스냅샷 저장 (chunk 변경 무시)
            if photos.isEmpty {
                photos = vm.allPhotos
            }
        }
    }

    private func photoDetailView(photo: Photo) -> some View {
        ZStack(alignment: .bottomTrailing) {
            ProgressiveDisplayImageView(
                thumbnailURL: photo.thumbnailURL,
                displayURL: photo.displayURL,
                originalURL: photo.url
            )

            selectionButtonView(photo: photo)
                .padding(16)
        }
        .task {
            // 현재 사진이 나타날 때 좌우 1장씩 prefetch
            vm.prefetchAdjacentPhotos(current: photo)
        }
    }

    private func selectionButtonView(photo: Photo) -> some View {
        Button {
            vm.toggleGridCell(for: photo)
        } label: {
            if vm.selectedPhotos.contains(photo) {
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
