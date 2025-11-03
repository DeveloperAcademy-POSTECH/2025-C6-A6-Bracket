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
    @State private var loadedImages: Set<String> = []  // 로딩 완료된 이미지 URL

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
                originalURL: photo.url,
                onImageLoaded: {
                    loadedImages.insert(photo.url)
                }
            )

            if loadedImages.contains(photo.url) {
                selectionButtonView(photo: photo)
                    .padding(16)
                    .transition(.opacity)
            }
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
            Group {
                if vm.selectedPhotos.contains(photo) {
                    Image(.checkSelectBtnM)
                        .resizable()
                        .shadow(color: .black.opacity(0.2), radius: 2.5, x: 0, y: 0)
                } else {
                    Image(.checkUnselectBtnM)
                        .resizable()
                }
            }
            .frame(width: 24, height: 24)
        }
    }
}
