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
    
    private let columnCount: Int = 2
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 9), count: columnCount)
    }
    
    var body: some View {
        groupingStateView()
            .background(Color.g12.ignoresSafeArea(.all))
            .navigationBarWithBack(title: "", showShadow: true, rightView: {
                EmptyView()
            })
            .overlay {
                savingStateView()
            }
            .task {
                vm.startGrouping()
            }
            .onChange(of: vm.groupingState) { _, newState in
                if case .failure(let error) = newState {
                    vm.currentError = error
                }
            }
            .onChange(of: vm.savingState) { _, newState in
                switch newState {
                case .success:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        vm.goToMain()
                    }
                case .failure(let error):
                    vm.currentError = error
                default:
                    break
                }
            }
            .customErrorAlert(error: $vm.currentError) { error in
                switch error {
                case .photoLoadingFailed:
                    AlertButton.cancel("취소") { vm.goToBack() }
                    AlertButton.default("재시도") { vm.startGrouping() }
                case .visionAnalysisFailed:
                    AlertButton.cancel("취소") { vm.goToBack() }
                    AlertButton.default("재시도") { vm.startGrouping() }
                case .photoPermissionDenied:
                    AlertButton.cancel("취소") { }
                    AlertButton.default("설정으로 이동") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                case .photoProcessingError:
                    AlertButton.cancel("취소") { }
                    AlertButton.default("재시도") { vm.saveSelectedPhotos() }
                    
                default:
                    AlertButton.default("확인")
                }
            }
    }
    
    @ViewBuilder
    private func groupingStateView() -> some View {
        switch vm.groupingState {
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
        case .failure:
            GroupedPhotosSkeletonView()
        }
    }
    
    @ViewBuilder
    private func savingStateView() -> some View {
        switch vm.savingState {
        case .idle:
            Color.clear
        case .loading:
            savingProgressView()
        case .success:
            successSavingView()
        case .failure:
            Color.clear
        }
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
        .contentMargins(.bottom, 80, for: .scrollContent)
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
                    Text("\(vm.selectedPhotosInGroup.count)장 사진에 저장")
                }
                .buttonStyle(DefaultButtonStyle(vm.selectedPhotosInGroup.isEmpty ? .deactivated : .activated))
                .disabled(vm.selectedPhotosInGroup.isEmpty)
                .screenPadding()
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private func savingProgressView() -> some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("\(vm.savingProgress.current)/\(vm.savingProgress.total)")
                    .fontStyle(.num2)
                    .foregroundColor(.white)
                
                // 프로그레스 바
                ProgressView(value: Double(vm.savingProgress.current),
                             total: Double(vm.savingProgress.total))
                .progressViewStyle(LinearProgressViewStyle(tint: Color.yellow1))
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 32)
        }
    }
    
    private func successSavingView() -> some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 16) {
                Image(.checkBtnLYellow)
                    .resizable()
                    .frame(width: 40, height: 40)
                
                Text("사진의 Bracket 앨범에\n저장되었습니다!")
                    .fontStyle(.num2)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
        }
    }
}
