//
//  MainView.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/24/25.
//

import SwiftUI
import SwiftData

struct MainView: View {
    //TODO: App 파일에서 주입하도록 설정
    @EnvironmentObject private var container: DIContainer
    @EnvironmentObject var cameraConnectionManager: CameraConnectionManager
    
    @State var vm: MainViewModel
    @State var isPresetEditMode: Bool = false
    
    var body: some View {
        NavigationStack(path: $container.navigationRouter.destinations) {
            ZStack {
                Color.g12.ignoresSafeArea(.all)
                VStack(spacing: 18) {
                    cameraAndArchiveHeaderView()
                    CustomSegmentedControl(selection: $vm.selectedSegment)
                    selectedSegmentView()
                }
                .padding(.horizontal, 16)
                .navigationDestination(for: NavigationDestination.self) {
                    NavigationRoutingView(destination: $0)
                }
            }
        }
        .onAppear {
            if cameraConnectionManager.connectionState != .connected {
                cameraConnectionManager.showConnectionSheet = true
            }
        }
        .sheet(isPresented: $cameraConnectionManager.showConnectionSheet) {
            CameraConnectionView()
        }
    }
    
    private func cameraAndArchiveHeaderView() -> some View {
        HStack {
            Button {
                // TODO: 카메라 연결
            } label: {
                Image(systemName: "camera.badge.ellipsis")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24)
            }
            Spacer()

            if vm.showEditButton {
                Button {
                    vm.toggleEditMode()
                } label: {
                    Text(vm.isPresetEditMode ? "완료" : "편집")
                        .font(.system(size: 16, weight: .bold))
                }
                .padding(.trailing, 12)
            }

            Button {
                // TODO: 사진 불러오기 연결
                vm.send(action: .goToPhotoSelection)
            } label: {
                Image(systemName: "photo.badge.plus")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24)
            }
        }
        .foregroundStyle(.black)
    }
    
    private func segmentedControlView() -> some View {
        Picker("", selection: Binding(
            get: { vm.selectedSegment },
            set: { vm.setSelectedSegment($0) }
        )) {
            ForEach(vm.segments, id: \.self) {
                Text($0.displayName)
                    .font(.system(size: 14, weight: .semibold))
            }
        }
        .pickerStyle(.palette)
    }
    
    @ViewBuilder
    private func selectedSegmentView() -> some View {
        switch vm.selectedSegment {
        case .trishot:
            TrishotSettingView(
                vm: TrishotSettingViewModel(container: container)
            )
            
        case .preset:
            PresetView(
                vm: PresetViewModel(
                    container: container,
                    isPresetEditMode: isPresetEditMode,
                    onEditModeChange: { newValue in
                        isPresetEditMode = newValue
                    }
                )
            )
        }
    }
}

#Preview {
    MainView(vm: .init(container: .stub), isPresetEditMode: false)
        .environmentObject(DIContainer.stub)
}
