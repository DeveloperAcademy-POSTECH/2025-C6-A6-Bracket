//
//  GroupedPhotosDetailView.swift
//  HonestHouse
//
//  Created by Rama on 10/22/25.
//

import SwiftUI
import Kingfisher

struct GroupedPhotosDetailView: View {
    @Environment(GroupedPhotosViewModel.self) var vm
    @Environment(\.dismiss) private var dismiss
    
    let groupedPhotos: SimilarPhotoGroup

    var body: some View {
        TabView {
            ForEach(groupedPhotos.photos) { photo in
                photoDetailView(photo: photo)
                    .tag(photo)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .navigationBarWithBack(title: "", showShadow: false) {
            dismiss()
        } rightView: {
            EmptyView()
        }
    }

    private func photoDetailView(photo: Photo) -> some View {
        ZStack(alignment: .topLeading) {
            
            ProgressiveDisplayImageView(
                photo: photo
            )
            .zoomableGesture()
            
            VStack(spacing: 0) {
                selectionButtonView(photo: photo)
                    .padding(16)
                
                Spacer()
            }
        }
        .task {
            // 현재 사진이 나타날 때 좌우 1-2장 prefetch
            vm.prefetchAdjacentPhotosInGroup(group: groupedPhotos, current: photo)
        }
    }

    private func selectionButtonView(photo: Photo) -> some View {
        Button {
            vm.toggleGroupedPhotoView(for: photo)
        } label: {
            Group {
                if vm.selectedPhotosInGroup.contains(where: { $0.id == photo.id }) {
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
