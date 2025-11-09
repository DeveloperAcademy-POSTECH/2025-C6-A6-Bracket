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
        ZStack {
            // 메인 상태 (Grouping)
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
            
            // 저장 상태 Overlay
            switch vm.savingState {
            case .idle:
                Color.clear
            case .loading(let progress):
                if let progress = progress {
                    savingProgressView(progress: progress)
                } else {
                    ProgressView()
                }
            case .success:
                successSavingView()
            case .failure:
                Color.clear
            }
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    vm.goToMain()
                }
            case .failure(let error):
                vm.currentError = error
            default:
                break
            }
        }
        .errorAlert(error: $vm.currentError) { error in
            switch error {
            case .photoLoadingFailed:
                Button("취소", role: .cancel) { vm.goToBack() }
                Button("재시도") {
                    vm.startGrouping()
                }
                
            case .visionAnalysisFailed:
                Button("취소", role: .cancel) { vm.goToBack() }
                Button("재시도") {
                    vm.startGrouping()
                }
                
            case .photoPermissionDenied:
                Button("취소", role: .cancel) { }
                Button("설정으로 이동") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                
            case .photoProcessingError:
                Button("취소", role: .cancel) { }
                Button("재시도") {
                    vm.saveSelectedPhotos()
                }
                
            default:
                Button("확인") { }
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
    
    private func savingProgressView(progress: Double) -> some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("\(Int(progress * 100))%")
                    .font(.num2)
                    .foregroundColor(.white)

                // 프로그레스 바
                ProgressView(value: progress, total: 1.0)
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
                
                Text("앨범에 저장되었습니다!")
                    .font(.num2)
                    .foregroundStyle(.white)
            }
        }
    }
}
