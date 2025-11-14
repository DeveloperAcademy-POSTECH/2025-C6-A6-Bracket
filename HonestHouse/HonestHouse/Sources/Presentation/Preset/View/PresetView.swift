//
//  PresetView.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/27/25.
//

import SwiftUI
import SwiftData

struct PresetView: View {
    @State var vm: MainViewModel
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @Namespace private var namespace
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            mainView

            Group {
                HStack {
                    Spacer()
                    if vm.isPresetEditMode {
                        deleteButtonView()
                    } else {
                        addButtonView()
                    }
                }
                .safeAreaPadding(.bottom, 28)
            }

            if vm.showDeleteAlert {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        vm.showDeleteAlert = false
                    }
                deleteConfirmAlertView()
                    .safeAreaPadding(.bottom, 28)
            }
        }
        .onAppear {
            vm.loadPresets()
        }
    }
    
    @ViewBuilder
    private var mainView: some View {
        ScrollView {
            if vm.viewMode == .grid {
                gridView
            } else {
                listView
            }
        }
        .contentMargins(.top, 24, for: .scrollContent)
        .scrollIndicators(.hidden)
        .animation(.easeInOut(duration: 0.3), value: vm.viewMode)
    }
    
    private var gridView: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10)
            ],
            spacing: 10
        ) {
            ForEach(vm.presets) { preset in
                PresetGridItemView(
                    preset: preset,
                    isSelected: vm.selectedPresets.contains(preset.id),
                    isEditMode: vm.isPresetEditMode,
                    onTap: {
                        if vm.isPresetEditMode {
                            vm.toggleSelection(for: preset)
                        } else {
                            vm.send(action: .goToPresetEditor(.view, preset))
                        }
                    },
                    onActionTap: {
                        if vm.isPresetEditMode {
                            vm.toggleSelection(for: preset)
                        } else {
                            Task {
                                // TODO: Custom Alert("이 프리셋을 적용하시겠습니까?") 적용
                                await vm.setCurrentPreset(preset)
                            }
                        }
                    }
                )
                .matchedGeometryEffect(id: preset.id, in: namespace)
            }
        }
        .padding(.top, 16)
    }

    private var listView: some View {
        LazyVStack(spacing: 28) {
            ForEach(vm.presets) { preset in
                PresetListItemView(
                    preset: preset,
                    isSelected: vm.selectedPresets.contains(preset.id),
                    isEditMode: vm.isPresetEditMode,
                    onTap: {
                        if vm.isPresetEditMode {
                            vm.toggleSelection(for: preset)
                        } else {
                            vm.send(action: .goToPresetEditor(.view, preset))
                        }
                    },
                    onActionTap: {
                        if vm.isPresetEditMode {
                            vm.toggleSelection(for: preset)
                        } else {
                            Task {
                                // TODO: Custom Alert("이 프리셋을 적용하시겠습니까?") 적용
                                await vm.setCurrentPreset(preset)
                            }
                        }
                    }
                )
                .matchedGeometryEffect(id: preset.id, in: namespace)
            }
        }
    }
    
    private var viewModeMenuView: some View {
        Menu {
            switch vm.viewMode {
            case .grid:
                Button {
                    vm.setViewMode(.list)
                } label: {
                    Label("리스트 보기", systemImage: "list.bullet")
                }
            case .list:
                Button {
                    vm.setViewMode(.grid)
                } label: {
                    Label("그리드 보기", systemImage: "square.grid.2x2")
                }
            }
        } label: {
            Image(systemName: vm.viewMode == .grid ? "square.grid.2x2" : "list.bullet")
                .font(.system(size: 18))
                .foregroundColor(.primary)
        }
    }
    
    // Buttons
    private func addButtonView() -> some View {
        Button {
            vm.send(action: .goToPresetEditor(.create, nil))
        } label: {
            Image(.plus)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .padding(13)
                .background(Color.g0)
                .clipShape(Circle())
                .shadow(color: .black, radius: 10)
        }
    }

    private func deleteButtonView() -> some View {
        Button {
            vm.showDeleteAlert = true
        } label: {
            Image(.trash)
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(vm.selectedPresets.isEmpty ? Color.g5 : Color.g12)
                .scaledToFit()
                .frame(width: 24, height: 24)
                .padding(13)
                .background(Color.g0)
                .clipShape(Circle())
                .shadow(color: .black, radius: 10)
        }
        .disabled(vm.selectedPresets.isEmpty)
    }

    private func deleteConfirmAlertView() -> some View {
        VStack(alignment: .center, spacing: 12) {
            Text("정말 삭제하시겠습니까?")
                .font(.num3)
                .foregroundStyle(Color.g0)

            Text("삭제된 프리셋은\n복구할 수 없습니다.")
                .font(.captionL)
                .foregroundStyle(Color.g5)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.bottom, 14)

            Button {
                vm.deleteSelectedPresets()
            } label: {
                Text("프리셋 삭제")
                    .font(.num3)
                    .foregroundStyle(Color.red1)
                    .padding(.vertical, 13)
                    .padding(.horizontal, 60)
                    .background(
                        Capsule()
                            .strokeBorder(Color.g0, lineWidth: 1)
                    )
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .background {
            VisualEffectBlurView()
                .blur(radius: 6, opaque: true)
                .overlay {
                    Color.g10.opacity(0.8)
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(radius: 20, x: 0, y: 4)
    }
}

#Preview {
    PresetView(vm: .init(container: .stub))
}
