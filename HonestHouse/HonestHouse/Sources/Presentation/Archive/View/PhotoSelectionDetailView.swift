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
        .tabViewStyle(.page(indexDisplayMode: .never))
        .task {
            // 진입 시 현재 photos 스냅샷 저장 (chunk 변경 무시)
            if photos.isEmpty {
                photos = vm.allPhotos
            }
        }
        .navigationBarWithBack(title: "", showShadow: false) {
            dismiss()
        } rightView: {
            Text("\(vm.selectedPhotos.count)장")
                .font(.num4)
                .foregroundStyle(Color.g0)
        }
    }

    private func photoDetailView(photo: Photo) -> some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                Spacer()
                
                ProgressiveDisplayImageView(
                    photo: photo
                )
                
                Spacer()
            }
            
            VStack(spacing: 0) {
                selectionButtonView(photo: photo)
                    .padding(16)
                
                Spacer()
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
                } else {
                    Image(.checkUnselectBtnM)
                        .resizable()
                }
            }
            .frame(width: 30, height: 30)
        }
    }
}
