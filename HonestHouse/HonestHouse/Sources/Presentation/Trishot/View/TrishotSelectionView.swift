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

            VStack(spacing: 0) {
                headerView()

                if vm.allPresets.isEmpty {
                    emptyStateView()
                } else {
                    ScrollView {
                        trishotItemListView()
                    }
                    .scrollIndicators(.hidden)
                }

                Spacer()

                doneButton()
            }
        }
        .navigationBarBackButtonHidden(true)
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
        VStack(spacing: 12) {
            ForEach(vm.allPresets) { preset in
                trishotItemView(preset)
            }
        }
        .padding()
    }

    private func trishotItemView(_ preset: Preset) -> some View {
        let isSelected = vm.isPresetSelected(preset.id)
        let isOccupied = vm.isPresetOccupied(preset.id)

        return Button {
            if !isOccupied {
                vm.selectPreset(preset.id)
            }
        } label: {
            HStack(alignment: .bottom, spacing: 16) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .yellow1 : .g7)

                VStack(alignment: .leading, spacing: 14) {
                    nameView(preset.name, isSelected: isSelected)
                    iconListView()
                    shootingDescriptionView(preset, isSelected: isSelected)
                }

                Spacer()
            }
            .padding(.leading, 14)
            .padding(.trailing, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.yellow1.opacity(0.1) : Color.g11)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.yellow1 : Color.clear, lineWidth: 2)
            )
        }
        .disabled(isOccupied)
        .opacity(isOccupied ? 0.3 : 1.0)
    }

    private func nameView(_ name: String, isSelected: Bool) -> some View {
        Text(name)
            .font(.labelL)
            .foregroundStyle(isSelected ? Color.g0 : Color.g5)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func iconListView() -> some View {
        HStack {
            Circle().frame(width: 32, height: 32).foregroundStyle(Color.yellow1)
            Circle().frame(width: 32, height: 32).foregroundStyle(Color.g0)
            Circle().frame(width: 32, height: 32).foregroundStyle(Color.g0)
            Circle().frame(width: 32, height: 32).foregroundStyle(Color.g0)
            Circle().frame(width: 32, height: 32).foregroundStyle(Color.g0)
        }
    }

    private func shootingDescriptionView(_ preset: Preset, isSelected: Bool) -> some View {
        HStack(spacing: 19) {
            if let modeDescription = preset.modeDescription {
                Text(modeDescription)
                    .font(.num6)
                    .foregroundColor(Color.g0)
                    .frame(alignment: .center)
            }
            Text(preset.isoDescription)
                .font(.num6)
                .foregroundColor(Color.g0)
                .frame(alignment: .center)

        }
    }

    private func doneButton() -> some View {
        Button {
            vm.send(.popToTrishotSetting)
        } label: {
            HStack {
                Spacer()
                Text("완료")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
            }
            .frame(height: 50)
            .background(vm.currentSelectedPresetId != nil ? Color.yellow1 : Color.gray)
            .cornerRadius(12)
        }
        .disabled(vm.currentSelectedPresetId == nil)
        .padding()
    }
}

#Preview {
    TrishotSelectionView(vm: .init(container: .stub, targetOrder: 0))
}
