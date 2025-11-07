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
                PhotoSelectionSkeletonView()
            }
        }
        .task {
            if vm.entireContentUrls.isEmpty {
                await vm.fetchAllImages()
            }
        }
        .onChange(of: vm.state) { _, newState in
            if case .failure(let error) = newState {
                vm.currentError = error
            }
        }
        .errorAlert(error: $vm.currentError) { error in
            switch error {
            case .cameraBusy:
                Button("취소", role: .cancel) { vm.goToBack() }
                Button("재시도") {
                    Task {
                        await vm.fetchAllImages()
                    }
                }
            case .cameraDisconnected:
                Button("취소", role: .cancel) { vm.goToBack() }
                Button("재연결") { } //TODO: - 카메라 연결 끊겼을 때
                
            case .photoLoadingFailed:
                Button("취소", role: .cancel) { vm.goToBack() }
                Button("재시도") {
                    Task {
                        await vm.fetchAllImages()
                    }
                }
                
            default:
                Button("확인") { }
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
        .contentMargins(.bottom, 50, for: .scrollContent)
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
