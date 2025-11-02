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

            // 저장 중 Progress Overlay
            if case .saving(let current, let total) = vm.savingState {
                savingProgressView(current: current, total: total)
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
        .onChange(of: vm.savingState) { _, newState in
            if case .success = newState {
                toastMessage = "저장 완료!"
                showToast = true

                // 성공 후 메인으로 이동
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    vm.goToMain()
                }
            } else if case .failure(let error) = newState {
                toastMessage = "저장 실패: \(error)"
                showToast = true
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

    private func savingProgressView(current: Int, total: Int) -> some View {
        ZStack {
            // 반투명 배경
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            // Progress UI
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)

                Text("\(current) / \(total)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("사진을 저장하는 중...")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(40)
            .background(Color.black.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

