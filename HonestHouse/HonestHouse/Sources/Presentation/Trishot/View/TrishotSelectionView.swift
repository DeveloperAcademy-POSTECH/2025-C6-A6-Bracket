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
            LazyVStack(spacing: 32) {
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
        let occupiedOrder = vm.getOccupiedOrder(preset.id)

        return VStack(alignment: .leading, spacing: 12) {
            Text(preset.name)
                .fontStyle(.num4)
                .foregroundStyle(isOccupied ? Color.g9 : Color.g0)
            Button {
                if !isOccupied {
                    vm.selectPreset(preset.id)
                }
            } label: {
                TrishotCapsuleView(
                    preset: preset,
                    isOccupied: isOccupied,
                    occupiedOrder: occupiedOrder
                )
                .frame(height: 122)
                .background(
                    Capsule()
                        .fill(Color.g11)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.yellow1 : Color.clear, lineWidth: 1)
                )
            }
            .disabled(isOccupied)
        }
    }

}

#Preview {
    TrishotSelectionView(vm: .init(container: .stub, targetOrder: 0))
}
