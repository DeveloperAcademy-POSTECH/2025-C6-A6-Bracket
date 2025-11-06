//
//  TrishotSelectionView.swift
//  HonestHouse
//
//  Created by Subeen on 10/30/25.
//

import SwiftUI

struct TrishotSelectionView: View {
    @State var vm: TrishotSelectionViewModel

    var body: some View {
        ZStack {
            Color.g12.ignoresSafeArea(.all)
            trishotItemListView()
        }
        .navigationBarWithBack(title: "프리셋 \(vm.targetOrder + 1)", showShadow: true) {
            vm.send(.popToTrishotSetting)
        } rightView: {
            EmptyView()
        }
    }

    private func headerView() -> some View {
        VStack(spacing: 8) {
            Text("트라이샷에 사용할 프리셋을 선택하세요")
                .font(.labelM)
                .foregroundColor(.g7)

            Text("프리셋 \(vm.targetOrder + 1) 선택")
                .font(.labelM)
                .foregroundColor(.yellow1)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.g11)
    }

    private func emptyStateView() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.metering.unknown")
                .font(.system(size: 48))
                .foregroundColor(.g7)

            Text("프리셋이 없습니다")
                .font(.labelL)
                .foregroundColor(.g7)

            Text("프리셋을 먼저 생성해주세요")
                .font(.labelM)
                .foregroundColor(.g7)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func trishotItemListView() -> some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(vm.allPresets) { preset in
                    trishotItemView(preset)
                }
            }
            .screenPadding()
        }
    }

    private func trishotItemView(_ preset: Preset) -> some View {
        let isSelected = vm.isPresetSelected(preset.id)
        let isOccupied = vm.isPresetOccupied(preset.id)

        return Button {
            if !isOccupied {
                vm.selectPreset(preset.id)
            }
        } label: {
            ZStack {
                Capsule()
                    .fill(isSelected ? Color.yellow1.opacity(0.08) : Color.clear)
                HStack {
                    Spacer()
                    VStack(alignment: .center, spacing: 12) {
                        nameView(preset.name, isSelected: isSelected)
                        iconListView(for: preset)
                        shootingDescriptionView(preset, isSelected: isSelected)
                    }
                    Spacer()
                }
                .padding(.horizontal, 31)
                .padding(.vertical, 15)
                HStack {
                    Spacer()
                    Image(.chevronRight)
                        .renderingMode(isOccupied ? .template : .original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(isSelected ? Color.g0 : Color.g7)
                }
                .padding(.trailing, 8)
            }
            
            .frame(height: 122)
            .background(
                Capsule()
                    .fill(Color.g11)
            )
            .overlay(
                CapsuleRoundStroke()
                    .stroke(isSelected ? Color.yellow1 : Color.clear, lineWidth: 1)
            )
        }
        .disabled(isOccupied)
    }

    private func nameView(_ name: String, isSelected: Bool) -> some View {
        Text(name)
            .font(.num6)
            .foregroundStyle(isSelected ? Color.g0 : Color.g7)
            .frame(alignment: .center)
    }

    private func iconListView(for preset: Preset) -> some View {
        HStack(spacing: 4) {
            Group {
                Image(vm.isPresetOccupied(preset.id) ? .picturestyleCircleIconGray : .picturestyleCircleIconWhite)
                    .resizable()
                Image(shootingModeIcon(for: preset))
                    .resizable()
                Image(vm.isPresetOccupied(preset.id) ? .colortemperatureCircleIconGray : .colortemperatureCircleIconWhite)
                    .resizable()
                Image(vm.isPresetOccupied(preset.id) ? .exposureCircleIconGray : .exposureCircleIconWhite)
                    .resizable()
                Image(vm.isPresetOccupied(preset.id) ? .wbshiftCircleIconGray : .wbshiftCircleIconWhite)
                    .resizable()
            }
            .scaledToFit()
            .frame(width: 32, height: 32)
        }
    }

    private func shootingModeIcon(for preset: Preset) -> ImageResource {
        switch preset.shootingMode {
        case .av: return vm.isPresetOccupied(preset.id) ? .shootingmodeAVCircleIconGray : .shootingmodeAVCircleIconWhite
        case .tv: return vm.isPresetOccupied(preset.id) ? .shootingmodeTVCircleIconGray : .shootingmodeTVCircleIconWhite
        case .p: return vm.isPresetOccupied(preset.id) ? .shootingmodePCircleIconGray : .shootingmodePCircleIconWhite
        }
    }

    private func shootingDescriptionView(_ preset: Preset, isSelected: Bool) -> some View {
        HStack(spacing: 19) {
            if let modeDescription = preset.modeDescription {
                Text(modeDescription)
                    .font(.num6)
                    .foregroundColor(isSelected ? Color.g0 : Color.g7)
                    .frame(alignment: .center)
            }
            Text(preset.isoDescription)
                .font(.num6)
                .foregroundColor(isSelected ? Color.g0 : Color.g7)
                .frame(alignment: .center)

        }
    }

}

#Preview {
    TrishotSelectionView(vm: .init(container: .stub, targetOrder: 0))
}
