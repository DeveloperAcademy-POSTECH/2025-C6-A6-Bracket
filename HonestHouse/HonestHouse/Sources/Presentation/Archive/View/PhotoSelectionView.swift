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
    
    let columnCount: Int = 3
    
    var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 2), count: columnCount)
    }
    
    var body: some View {
            ZStack {
                switch vm.state {
                case .idle, .loading:
                    ProgressView("사진을 불러오는 중...")
                    
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
            .navigationTitle("카메라 이름")
            .navigationBarTitleDisplayMode(.large)
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

    }
    
    private func photoSelectionGridView() -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(vm.entireContentUrls.indices, id: \.self) { index in
                    let url = vm.entireContentUrls[index]
                    let photo = Photo(url: url)
                    SelectionGridCellView(
                        item: photo,
                        isSelected: vm.selectedPhotos.contains(where: { $0.url == url }),
                        onTapSelectionGridCell: { vm.toggleGridCell(for: photo) }
                    )
                    .id(url)
                }
            }
            .padding(.horizontal, 2)
        }
    }
    
    private func selectionCompleteButtonView() -> some View {
        VStack {
            Spacer()
            if !vm.selectedPhotos.isEmpty {
                Button {
                    vm.goToGroupedPhotos()
                } label: {
                    Text("완료")
                        .font(.title3)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.gray)
                        .foregroundStyle(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
        }
    }
}
