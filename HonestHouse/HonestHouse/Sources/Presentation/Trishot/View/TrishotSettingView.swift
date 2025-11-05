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
    }
    
    /// 프리셋 3개 목록 (트라이샷)
    private func presetListView() -> some View {
        VStack(spacing: 32) {
            ForEach(vm.trishotItems.indices, id: \.self) { index in
                presetView(vm.trishotItems[index], index)
                    .onTapGesture {
                        vm.send(action: .togglePreset(vm.trishotItems[index].id))
                    }
            }
        }
    }
    
    /// 프리셋 타이틀 + 내용
    private func presetView(_ item: TrishotItem, _ index: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            titleView(name: item.preset.name)
            contentView(item, index)
        }
    }
    
    /// 프리셋 타이틀
    private func titleView(name: String) -> some View {
        Button {
            vm.send(action: .goToTrishotSelection)
        } label: {
            HStack {
                Text(name)
                    .font(.title3)
                    .foregroundStyle(Color.g0)
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.g7)
            }
        }
    }
    
    /// 프리셋 내용
    private func contentView(_ item: TrishotItem, _ index: Int) -> some View {
        HStack {
            contentSettingsView(item.preset)
            Spacer()
            contentCircleView(num: index + 1)
        }
        .environment(\.layoutDirection, item.isSelected ? .leftToRight : .rightToLeft)
        .animation(.default, value: item.isSelected)
        .background(Color.g11)
        .clipShape(RoundedRectangle(cornerRadius: 100))
    }
    
    /// 프리셋 내용 - 세팅 종류
    private func contentSettingsView(_ preset: Preset) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle().frame(width: 32, height: 32).foregroundStyle(Color.blue)
                Circle().frame(width: 32, height: 32).foregroundStyle(Color.white)
                Circle().frame(width: 32, height: 32).foregroundStyle(Color.white)
                Circle().frame(width: 32, height: 32).foregroundStyle(Color.white)
                Circle().frame(width: 32, height: 32).foregroundStyle(Color.white)
            }
            shootingDescriptionView(preset)
        }
        .frame(maxWidth: .infinity)
        .environment(\.layoutDirection, .leftToRight)
        .padding(.leading, 39)
    }
    
    private func filterIcon(iso: ISO) -> some View {
        Image("")
    }
    
    private func shootingModeIcon() -> some View {
        Image("")
    }
    
    private func blueAmberIcon() -> some View {
        Image("")
    }
    
    private func exposureIcon() -> some View {
        Image("")
    }
    
    private func tintIcon() -> some View {
        Image("")
    }
    
    /// 프리셋 내용 - 원
    private func contentCircleView(num: Int) -> some View {
        Circle()
            .stroke(lineWidth: 0.5)
            .frame(width: 110, height: 110)
            .overlay {
                Text("\(num)")
                    .font(.num1)
            }
            .padding(.vertical, 6)
            .padding(.trailing, 8)
            .foregroundStyle(Color.yellow1)
    }
    
    private func shootingDescriptionView(_ preset: Preset) -> some View {
        Text(preset.settingsDescription)
            .foregroundStyle(Color.g0)
            .font(.num4)
    }
    
    private func startButtonView() -> some View {
        Button {
            vm.send(action: .goToTrishotMode)
        } label: {
            Text("시작하기")
        }
        .buttonStyle(DefaultButtonStyle(.activated))
    }
}

#Preview {
    TrishotSettingView(vm: .init(container: .stub))
}
