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
                noticeTextView()
                Spacer()
                triCircleListView(vm.currentPresetIndex)
                Spacer()
                deactivateButtonView()
            }
            .allowsHitTesting(!vm.isScreenLocked)

            VStack {
                Spacer()
                HStack {
                    lockButtonView()
                        .padding(.leading, 16)
                        .padding(.bottom, 86)
                    Spacer()
                }
            }
        }
        .task {
            vm.activateTrishot()
        }
    }
    
    private func noticeTextView() -> some View {
        Text("Tri-shot 사용 중에는\n다른 기능을 이용할 수 없습니다.")
            .multilineTextAlignment(.center)
            .font(.num6)
            .foregroundStyle(Color.g7)
            .padding(.top, 41)
    }
    
    private func triCircleListView(_ index: Int) -> some View {
        VStack(spacing: 40) {
            ForEach(Array(vm.selectedPresets.enumerated()), id: \.element.id) { index, preset in
                if vm.isCurrentPreset(index) {
                    yellowCircle(index)
                } else {
                    darkCircle(index)
                }
            }
        }
        .animation(.default, value: index)
    }
    
    private func yellowCircle(_ circleIndex: Int) -> some View {
        Circle()
            .foregroundStyle(Color.yellow1)
            .frame(width: 110, height: 110)
            .overlay {
                Text("\(circleIndex + 1)")
                    .foregroundStyle(Color.g12)
            }
    }
    
    private func darkCircle(_ circleIndex: Int) -> some View {
        Circle()
            .strokeBorder(Color.yellow1)
            .foregroundStyle(Color.g12)
            .frame(width: 110, height: 110)
            .overlay {
                Text("\(circleIndex + 1)")
                    .foregroundStyle(Color.yellow1)
            }
    }
    
    private func deactivateButtonView() -> some View {
        VStack {
            Button {
                vm.deactivateTrishot()
                vm.send(.popToTrishotSetting)
            } label: {
                Text("중단하기")
            }
            .buttonStyle(DefaultButtonStyle(.activated))
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    TrishotActivationView(vm: .init(container: .stub))
}
