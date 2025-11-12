//
//  PhotoSelectionDetailView.swift
//  HonestHouse
//
//  Created by Rama on 10/22/25.
//

import SwiftUI
import Kingfisher

struct PhotoSelectionDetailView: View {
    @Environment(PhotoSelectionViewModel.self) var vm
    @Environment(\.dismiss) private var dismiss

    @State private var selectedURL: String // TabView 현재 페이지
    @State private var photos: [Photo] = [] // 스냅샷 (vm chunk append시, 무시 목적)
    
    let initialPhoto: Photo
    
    private var currentPhoto: Photo {
        photos.first { $0.url == selectedURL } ?? initialPhoto
    }

    init(initialPhoto: Photo) {
        self.initialPhoto = initialPhoto
        self._selectedURL = State(initialValue: initialPhoto.url)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            TabView(selection: $selectedURL) {
                ForEach(photos) { photo in
                    photoDetailView(photo: photo)
                        .tag(photo.url)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .task {
                if photos.isEmpty {
                    photos = vm.allPhotos
                }
            }
            
            selectionButtonView(photo: currentPhoto)
                .padding(.trailing, 16)
            
        }
        .navigationBarWithBack(title: currentPhoto.detailDateString, showShadow: false) {
            dismiss()
        } rightView: {
            EmptyView()
        }
    }

    private func photoDetailView(photo: Photo) -> some View {
        ProgressiveDisplayImageView(
            photo: photo
        )
        .zoomableGesture()
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
                } else {
                    Image(.checkUnselectBtnM)
                        .resizable()
                }
            }
            .frame(width: 30, height: 30)
        }
    }
}
