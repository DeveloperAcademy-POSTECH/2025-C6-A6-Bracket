//
//  MainView.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/24/25.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @State var vm: MainViewModel
    
    @EnvironmentObject private var container: DIContainer
    @EnvironmentObject var cameraConnectionManager: CameraConnectionManager
    
    var body: some View {
        NavigationStack(path: $container.navigationRouter.destinations) {
            ZStack(alignment: .topTrailing) {
                Color.g12.ignoresSafeArea(.all)
                VStack(spacing: 12) {
                    headerView()
                    VStack(spacing: vm.selectedSegment == .trishot ? 0 : 12){
                        CustomSegmentedControl(selection: $vm.selectedSegment)
                        selectedSegmentView()
                    }
                }
                .safeAreaPadding(.vertical, 0)
                .screenPadding()
                .navigationDestination(for: NavigationDestination.self) {
                    NavigationRoutingView(destination: $0)
                }

                if vm.selectedSegment == .preset && vm.presets.isEmpty {
                    presetEmptyStateView
                }

                if vm.showModeChange {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            vm.showModeChange = false
                        }

                    OptionsMenuView(items: vm.getMenuItems())
                        .safeAreaPadding(.top, 34)
                        .safeAreaPadding(.trailing, 52)
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
        .customAlert(
            title: "카메라와의 연결이 해제되었습니다.",
            message: "카메라를 다시 연결해주세요.",
            isPresented: $cameraConnectionManager.showDisconnectionAlert
        ) {
            AlertButton.cancel("취소")
            AlertButton.default("재연결") {
                cameraConnectionManager.reconnectCamera()
            }
        }
        .customAlert(title: "이 프리셋을 적용하시겠습니까?", isPresented: $vm.showPresetApply) {
            AlertButton.cancel("취소")
            AlertButton.default("확인") {
                guard let preset = vm.presetToApply else { return }
                Task {
                    await vm.setCurrentPreset(preset)
                    vm.presetToApply = nil
                }
            }
        }
        .customErrorAlert(error: $vm.currentError) { error in
            switch error {
            case .settingApplicationFailed:
                AlertButton.default("확인")
            default:
                AlertButton.default("확인")
            }
        }
    }
    
    private func headerView() -> some View {
        HStack(spacing: 20) {
            if vm.selectedSegment == .preset && vm.isPresetEditMode {
                Button {
                    vm.selectAllPresets()
                } label: {
                    Text("전체선택")
                        .foregroundStyle(Color.g0)
                        .fontStyle(.num4)
                }
            } else {
                Button {
                    vm.send(action: .goToSettings)
                } label: {
                    Image(.setting)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
            }
            Spacer()
            if vm.selectedSegment == .preset && !vm.isPresetEditMode {
                Button {
                    vm.showModeChange.toggle()
                } label: {
                    Image(.modeEllipsis)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
            }

            if vm.selectedSegment == .preset && vm.isPresetEditMode {
                Button {
                    vm.isPresetEditMode = false
                } label: {
                    Text("완료")
                        .foregroundStyle(Color.g0)
                        .fontStyle(.num4)
                }
            } else {
                Button {
                    Task {
                        if await cameraConnectionManager.checkConnection() {
                            Logger.info("Camera connected", category: .connection)
                            vm.send(action: .goToPhotoSelection)
                        } else {
                            Logger.info("Camera disconnected", category: .connection)
                            cameraConnectionManager.showConnectionLostAlert()
                        }
                    }
                } label: {
                    Image(.importPhoto)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
            }
        }
        .padding(.vertical, 10)
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
        if vm.selectedSegment == .trishot {
            TrishotSettingView(
                vm: TrishotSettingViewModel(container: container)
            )
        } else if vm.selectedSegment == .preset {
            PresetView(vm: vm)
        }
    }

    private var presetEmptyStateView: some View {
        VStack(spacing: 0) {
            Spacer()
            HStack(spacing: 0) {
                Text("하단의")
                    .fontStyle(.num4)
                    .foregroundStyle(Color.g9)
                    .padding(.trailing, 8)
                Image(.plus)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .foregroundStyle(Color.g9)
                    .padding(2.5)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.g9, lineWidth: 1)
                    )
                Text("버튼을 눌러")
                    .fontStyle(.num4)
                    .foregroundStyle(Color.g9)
                    .padding(.leading, 4)
            }

            Text("Preset을 생성해보세요!")
                .fontStyle(.num4)
                .foregroundStyle(Color.g9)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
    }
}

#Preview {
    MainView(vm: .init(container: .stub))
        .environmentObject(DIContainer.stub)
        .environmentObject(CameraConnectionManager.init())
}
