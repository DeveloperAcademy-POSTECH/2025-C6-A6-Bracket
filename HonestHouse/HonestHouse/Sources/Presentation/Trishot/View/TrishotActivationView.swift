//
//  TrishotActivationView.swift
//  HonestHouse
//
//  Created by Subeen on 11/3/25.
//

import SwiftUI

struct TrishotActivationView: View {
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
            // TODO: Custom Alert(카메라로 촬영을 시작해보세요) 연결
            vm.activateTrishot()
        }
        .onAppear {
            NavigationSwipeBackControl.disableSwipeBack()
        }
        .onDisappear {
            NavigationSwipeBackControl.enableSwipeBack()
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func triCircleListView(_ index: Int) -> some View {
        VStack(spacing: 32) {
            ForEach(Array(vm.activatedPresets.enumerated()), id: \.element.id) { index, preset in
                VStack(alignment: .leading, spacing: 12) {
                    Text(preset.name)
                        .font(.num4)
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
