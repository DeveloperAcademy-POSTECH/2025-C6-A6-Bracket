//
//  TrishotActivationView.swift
//  HonestHouse
//
//  Created by Subeen on 11/3/25.
//

import SwiftUI

struct TrishotActivationView: View {
    @EnvironmentObject var cameraConnectionManager: CameraConnectionManager

    @State var vm: TrishotActivationViewModel
    
    var body: some View {
        ZStack {
            Color.g12.ignoresSafeArea(.all)
            VStack(alignment: .center) {
                Spacer()
                triCircleListView(vm.currentPresetIndex)
                Spacer()
                deactivateButtonView()
            }
            .safeAreaPadding(.all, 0)
        }
        .task {
            vm.showInitialGuide()
        }
        .onAppear {
            NavigationSwipeBackControl.disableSwipeBack()
        }
        .onDisappear {
            NavigationSwipeBackControl.enableSwipeBack()
            vm.deactivateTrishot()
        }
        .navigationBarBackButtonHidden(true)
        .customAlert(
            title: "카메라로 촬영을 시작해보세요",
            message: "세 가지 프리셋을 반복하여 촬영합니다.\nTri-shot을 중단하려면 하단의 슬라이더를 끝까지 밀어주세요.",
            isPresented: $vm.showGuide
        ) {
            AlertButton.default("확인") {
                vm.activateTrishot()
            }
        }
        .customErrorAlert(error: $vm.currentError) { error in
            switch error {
            case .cameraDisconnected:
                AlertButton.cancel("취소") {
                    vm.deactivateTrishot()
                    vm.send(.popToTrishotSetting)
                }
                AlertButton.default("다시 연결") {
                    cameraConnectionManager.reconnectCamera()
                    vm.deactivateTrishot()
                    vm.send(.popToTrishotSetting)
                }
            case .cameraBusy:
                AlertButton.default("확인")
            case .monitoringStartFailed:
                AlertButton.cancel("취소") {
                    vm.send(.popToTrishotSetting)
                }
                AlertButton.default("다시 시도") {
                    Task {
                        try? await Task.sleep(nanoseconds: 500_000_000)
                        vm.activateTrishot()
                    }
                }
            case .presetApplicationFailed:
                AlertButton.cancel("취소") {
                    vm.send(.popToTrishotSetting)
                }
                AlertButton.default("다시 시도") {
                    Task {
                        try? await Task.sleep(nanoseconds: 100_000_000)
                        vm.activateTrishot()
                    }
                }
            case .unknown:
                AlertButton.default("확인") {
                    vm.send(.popToTrishotSetting)
                }
            }
        }
    }
    
    private func triCircleListView(_ index: Int) -> some View {
        VStack(spacing: 32) {
            ForEach(Array(vm.activatedPresets.enumerated()), id: \.element.id) { index, preset in
                VStack(alignment: .leading, spacing: 12) {
                    Text(preset.name)
                        .fontStyle(.num4)
                        .foregroundStyle(Color.g0)
                    if vm.isCurrentPreset(index) {
                        activeCapsule(preset: preset, index: index)
                    } else {
                        inactiveCapsule(preset: preset, index: index)
                    }
                }
            }
        }
        .screenPadding()
        .animation(.default, value: index)
    }

    private func activeCapsule(preset: Preset, index: Int) -> some View {
        TrishotCapsuleView(preset: preset, isOccupied: false)
            .frame(height: 122)
            .background(Capsule().fill(Color.g11))
            .overlay(Capsule().stroke(Color.yellow1, lineWidth: 1))
    }

    private func inactiveCapsule(preset: Preset, index: Int) -> some View {
        TrishotCapsuleView(preset: preset, isOccupied: false)
            .frame(height: 122)
            .background(
                Capsule()
                    .fill(Color.g11)
            )
    }
    
    private func deactivateButtonView() -> some View {
        SwipeToDeactivateButton {
            vm.deactivateTrishot()
            vm.send(.popToTrishotSetting)
        }
        .padding(.horizontal, 46)
        .frame(height: 100)
    }
}

#Preview {
    TrishotActivationView(vm: .init(container: .stub))
}
