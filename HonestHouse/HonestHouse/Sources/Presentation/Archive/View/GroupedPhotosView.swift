//
//  GroupedPhotosView.swift
//  HonestHouse
//
//  Created by Rama on 10/22/25.
//

import SwiftUI
import Kingfisher

struct GroupedPhotosView: View {
    @State var vm: GroupedPhotosViewModel
    
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    
    let columnCount: Int = 2
    
    var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 9), count: columnCount)
    }
    
    var body: some View {
        ZStack {
            // 메인 상태 (Grouping)
            switch vm.state {
            case .idle, .loading:
                ZStack {
                    GroupedPhotosSkeletonView()
                    ProgressWithTextView(text: "비슷한 사진끼리 분류중")
                }
            case .success(let groupedPhotos):
                ZStack {
                    groupedPhotosGridView(groupedPhotos: groupedPhotos)
                    selectionCompleteButtonView()
                }
            case .failure(_):
                Color.clear
            }

            // 저장 상태 Overlay
            switch vm.savingState {
            case .idle:
                Color.clear
            case .saving(let current, let total):
                savingProgressView(current: current, total: total)
            case .success:
                SuccessSavingView()
            case .failure:
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
        .onChange(of: vm.state) { _, newState in
            if case .failure(let groupingError) = newState {
                toastMessage = "오류 발생: \(groupingError.localizedDescription)"
                showToast = true
            } else {
                showToast = false
            }
        }
        .onChange(of: vm.savingState) { _, newState in
            switch newState {
            case .success:
                // 성공 후 메인으로 이동
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    vm.goToMain()
                }
            case .failure(let error):
                toastMessage = "저장 실패: \(error)"
                showToast = true
            default:
                break
            }
        }
        .navigationBarWithBack(title: "", showShadow: true, rightView: {
           EmptyView()
        })
    }
    
    private func groupedPhotosGridView(groupedPhotos: [SimilarPhotoGroup]) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 9) {
                ForEach(groupedPhotos) { group in
                    GroupedPhotosGridCellView(
                        group: group
                    )
                    .environment(vm)
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
                    .ignoresSafeArea(edges: [.top, .bottom])

                Button {
                    vm.saveSelectedPhotos()
                } label: {
                    Text("저장")
                }
                .buttonStyle(DefaultButtonStyle(vm.selectedPhotosInGroup.isEmpty ? .deactivated : .activated))
                .screenPadding()
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private func savingProgressView(current: Int, total: Int) -> some View {
        ZStack {
            // 반투명 배경
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("\(current)/\(total)")
                    .font(.num2)
                    .foregroundColor(.white)

                // 프로그레스 바
                ProgressView(value: Double(current), total: Double(total))
                    .progressViewStyle(LinearProgressViewStyle(tint: Color.yellow1))
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 32)
        }
    }
    
    private func SuccessSavingView() -> some View {
        ZStack {
            // 반투명 배경
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            VStack(alignment: .center, spacing: 16) {
                Image(.checkBtnLYellow)
                    .resizable()
                    .frame(width: 40, height: 40)

                Text("앨범에 저장되었습니다!")
                    .font(.num2)
                    .foregroundStyle(.white)
            }
        }
    }
}
