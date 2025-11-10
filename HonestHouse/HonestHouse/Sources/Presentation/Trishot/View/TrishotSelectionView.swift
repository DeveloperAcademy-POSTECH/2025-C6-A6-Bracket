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
        .navigationBarWithBack(title: "", showShadow: true) {
            vm.send(.popToTrishotSetting)
        } rightView: {
            EmptyView()
        }
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
            VStack(alignment: .center, spacing: 12) {
                nameView(preset.name, isSelected: isSelected)
                iconListView(for: preset)
                shootingDescriptionView(preset, isSelected: isSelected)
            }
            .padding(.horizontal, 37)
            .frame(maxWidth: .infinity)
            .overlay(alignment: .trailing) {
                Image(.chevronRight)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(isSelected ? Color.g0 : Color.g7)
                    .padding(.trailing, 8)
            }
            .padding(.vertical, 15)
            .frame(height: 122)
            .background(
                Capsule()
                    .fill(Color.g11)
            )
            .overlay(
                Capsule()
                    .fill(isSelected ? Color.yellow1.opacity(0.08) : Color.clear)
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
