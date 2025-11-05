//
//  PhotoSelectionView.swift
//  HonestHouse
//
//  Created by Rama on 10/22/25.
//

import SwiftUI
import Kingfisher

struct PhotoSelectionView: View {
    @EnvironmentObject var container: DIContainer
    
    @State var vm: PhotoSelectionViewModel
    
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    
    private let columnCount: Int = 3
    
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 5), count: columnCount)
    }
    
    var body: some View {
        ZStack {
            switch vm.state {
            case .idle, .loading:
                ZStack {
                    PhotoSelectionSkeletonView()
                    ProgressWithTextView(text: "사진 가져오는 중")
                }
            case .success:
                ZStack {
                    photoSelectionGridView()
                    selectionCompleteButtonView()
                }

            case .failure(_):
                Color.clear
            }

            if showToast {
                ToastView(message: toastMessage, isShowing: $showToast)
                    .transition(.move(edge: .bottom))
            }
        }
        .task {
            if vm.entireContentUrls.isEmpty {
                await vm.fetchAllImages()
            }
        }
        .onChange(of: vm.state) { _, newState in
            if case .failure(let error) = newState {
                toastMessage = error.localizedDescription
                showToast = true
            } else {
                showToast = false
            }
        }
        .navigationBarWithBack(title: "", showShadow: true, rightView: {
            Text("\(vm.selectedPhotos.count)장")
                .font(.num4)
                .foregroundStyle(Color.g0)
        })
    }
    
    private func photoSelectionGridView() -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(vm.entireContentUrls.indices, id: \.self) { index in
                    let url = vm.entireContentUrls[index]
                    let photo = Photo(url: url)
                    SelectionGridCellView(
                        photo: photo,
                        isSelected: vm.selectedPhotos.contains(photo),
                        onTapSelectionGridCell: { vm.toggleGridCell(for: photo) }
                    )
                    .environment(vm)
                    .id(url)
                }
            }
            .screenPadding()
        }
    }
    
    private func selectionCompleteButtonView() -> some View {
        VStack {
            Spacer()
            
            ZStack {
                ShadowView(startBottom: true)
                
                Button {
                    vm.goToGroupedPhotos()
                } label: {
                    Text("완료")
                }
                .buttonStyle(DefaultButtonStyle(vm.selectedPhotos.isEmpty ? .deactivated : .activated))
                .screenPadding()
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
