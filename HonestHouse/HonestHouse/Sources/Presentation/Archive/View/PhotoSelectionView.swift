//
//  PhotoSelectionView.swift
//  HonestHouse
//
//  Created by Rama on 10/22/25.
//

import SwiftUI
import Kingfisher

struct PhotoSelectionView: View {
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
            if vm.allPhotos.isEmpty {
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
            EmptyView()
        })
    }
    
    private func photoSelectionGridView() -> some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(vm.photoSections) { section in
                    VStack(spacing: 0) {
                        sectionHeaderView(section: section)

                        LazyVGrid(columns: columns, spacing: 5) {
                            ForEach(section.photos) { photo in
                                SelectionGridCellView(
                                    photo: photo,
                                    isSelected: vm.selectedPhotos.contains(photo),
                                    onTapSelectionGridCell: { vm.toggleGridCell(for: photo) }
                                )
                                .environment(vm)
                                .id(photo.url)
                            }
                        }
                    }
                }
            }
            .screenPadding()
        }
        .contentMargins(.bottom, 70, for: .scrollContent)
    }
    
    private func sectionHeaderView(section: PhotoSection) -> some View {
        HStack {
            Text(section.dateString)
                .font(.num6)
                .foregroundStyle(Color.g0)
            
            Spacer()
            
            Button {
                vm.toggleSectionSelection(for: section)
            } label: {
                
                HStack(spacing: 6) {
                    Text("전체 선택")
                        .font(.num6)
                        .foregroundStyle(Color.g0)
                }
                Image(vm.isAllSelected(in: section) ? .checkSelectBtnS : .checkUnselectBtnS)
            }
        }
        .padding(.vertical, 15)
        .background(Color.clear)
    }
    
    private func selectionCompleteButtonView() -> some View {
        VStack {
            Spacer()
            
            ZStack {
                ShadowView(startBottom: true)
                
                Button {
                    vm.goToGroupedPhotos()
                } label: {
                    Text("\(vm.selectedPhotos.count)장 분류하러 가기")
                }
                .buttonStyle(DefaultButtonStyle(vm.selectedPhotos.isEmpty ? .deactivated : .activated))
                .screenPadding()
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
