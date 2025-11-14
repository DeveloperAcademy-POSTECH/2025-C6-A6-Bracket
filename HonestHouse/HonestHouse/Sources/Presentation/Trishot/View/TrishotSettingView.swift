//
//  RemoteControllerView.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

import SwiftUI

struct TrishotSettingView: View {
    @EnvironmentObject var container: DIContainer

    @State var vm: TrishotSettingViewModel
    
    var body: some View {
        ZStack {
            Color.g12.ignoresSafeArea(.all)
            VStack {
                presetListView()
                Spacer()
                startButtonView()
            }
        }
        .task {
            vm.loadPresets()
        }
    }
    
    /// 프리셋 3개 목록 (트라이샷)
    private func presetListView() -> some View {
        VStack(spacing: 32) {
            ForEach(0..<3, id: \.self) { index in
                if index < vm.allSelectedPresets.count {
                    presetView(vm.allSelectedPresets[index], index)
                } else {
                    emptySlotView(index)
                }
            }
        }
        .padding(.top, 27)
    }
    
    /// 프리셋 타이틀 + 내용
    private func presetView(_ preset: Preset, _ index: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            titleView(name: preset.name, order: index)
            contentView(preset, index)
        }
    }

    /// 등록된 프리셋 없는 경우
    private func emptySlotView(_ index: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("프리셋 \(index + 1)")
                .fontStyle(.title3)
                .foregroundStyle(Color.g0)
            Button {
                // TODO: Preset 생성 뷰로 이동하도록 연결
            } label: {
                HStack {
                    Spacer()
                    Image(systemName: "plus")
                        .foregroundStyle(Color.g0)
                    Spacer()
                }
            }
            .frame(height: 110)
            .background(Color.g11)
            .clipShape(RoundedRectangle(cornerRadius: 100))
        }
    }

    /// 프리셋 타이틀
    private func titleView(name: String, order: Int) -> some View {
        Text(name)
            .fontStyle(.num4)
            .foregroundStyle(Color.g0)
    }
    
    /// 프리셋 내용
    private func contentView(_ preset: Preset, _ index: Int) -> some View {
        Button {
            vm.send(action: .goToTrishotSelection(order: index))
        } label: {
            TrishotCapsuleView(preset: preset)
                .frame(height: 122)
                .frame(maxWidth: .infinity)
                .background(Color.g11)
                .clipShape(RoundedRectangle(cornerRadius: 100))
        }
    }
    
    private func startButtonView() -> some View {
        let canStart = vm.allSelectedPresets.count == 3
        return Button {
            vm.send(action: .goToTrishotActivation)
        } label: {
            Text("Tri-shot 시작하기")
        }
        .buttonStyle(DefaultButtonStyle(canStart ? .activated : .deactivated))
        .disabled(!canStart)
    }
}

#Preview {
    TrishotSettingView(vm: .init(container: .stub))
}
