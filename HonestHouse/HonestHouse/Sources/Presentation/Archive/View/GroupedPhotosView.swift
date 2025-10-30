//
//  GroupedPhotosView.swift
//  HonestHouse
//
//  Created by Rama on 10/22/25.
//

import SwiftUI
import Kingfisher

struct GroupedPhotosView: View {
    @EnvironmentObject var container: DIContainer
    @State var vm: GroupedPhotosViewModel
    
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    
    var columns: [GridItem] {
        Array(repeating: GridItem(.flexible()), count: 2)
    }
    
    var body: some View {
        ZStack {
            switch vm.groupingState {
            case .idle, .loading:
                ProgressView()
            case .success(let groupedPhotos):
                groupedPhotosGridView(groupedPhotos: groupedPhotos)
                selectionCompleteButtonView()
            case .failure(_):
                Color.clear
            }
            
            if showToast {
                ToastView(message: toastMessage, isShowing: $showToast)
                    .transition(.move(edge: .bottom))
            }
        }
        .task {
            vm.startGrouping()
        }
        .onChange(of: vm.groupingState) { _, newState in
            if case .failure(let groupingError) = newState {
                toastMessage = "오류 발생: \(groupingError.localizedDescription)"
                showToast = true
            } else {
                showToast = false
            }
        }
    }
    
    private func groupedPhotosGridView(groupedPhotos: [SimilarPhotoGroup]) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(groupedPhotos) { group in
                    GroupedPhotosGridCellView(
                        group: group
//                        selectedPhotosInGroup: vm.selectedPhotosInGroup,
//                        onTapGroupedPhoto: vm.toggleGroupedPhotoView
                    )
                    .environment(vm)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 32)
        }
    }
    
    private func selectionCompleteButtonView() -> some View {
        VStack {
            Spacer()
            if !vm.selectedPhotosInGroup.isEmpty {
                Button {
                    vm.saveSelectedPhotos()
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

