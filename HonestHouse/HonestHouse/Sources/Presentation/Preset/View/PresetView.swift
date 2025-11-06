//
//  PresetView.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/27/25.
//

import SwiftUI
import SwiftData

struct PresetView: View {
    @EnvironmentObject private var container: DIContainer
    @State var vm: PresetViewModel
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @Namespace private var namespace
    
    var body: some View {
        ZStack(alignment: .bottom) {
            mainView

            Group {
                if vm.isPresetEditMode {
                    deleteButtonView()
                } else {
                    HStack {
                        Spacer()
                        addButtonView()
                    }
                }
            }
            .padding(.bottom, 24)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                viewModeMenuView
            }
        }
        .environment(vm)
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
                        handlePresetTap(preset)
                    },
                    onActionTap: {
                        Task {
                            await vm.setCurrentPreset(preset)
                            showToastMessage("\(preset.name) 적용됨")
                        }
                    }
                )
                .matchedGeometryEffect(id: preset.id, in: namespace)
            }
        }
        .padding(.top, 16)
    }
    
    private var listView: some View {
        LazyVStack(spacing: 10) {
            ForEach(vm.presets) { preset in
                PresetListItemView(
                    preset: preset,
                    isSelected: vm.selectedPresets.contains(preset.id),
                    isEditMode: vm.isPresetEditMode,
                    onTap: {
                        handlePresetTap(preset)
                    },
                    onActionTap: {
                        Task {
                            await vm.setCurrentPreset(preset)
                            showToastMessage("\(preset.name) 적용됨")
                        }
                    }
                )
                .matchedGeometryEffect(id: preset.id, in: namespace)
            }
        }
        .padding(.top, 16)
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
            vm.send(action: .goToPresetDetail(.create, nil))
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Color.g0)
                .frame(width: 50, height: 50)
                .background(Circle().fill(Color.g0))
        }
    }
    
    private func deleteButtonView() -> some View {
        Button {
            vm.deleteSelectedPresets()
            vm.isPresetEditMode = false
        } label: {
            HStack {
                Spacer()
                Text("삭제 (\(vm.selectedPresets.count))")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
            }
            .frame(height: 50)
            .background(vm.selectedPresets.isEmpty ? Color.gray : Color.red)
            .cornerRadius(12)
        }
        .disabled(vm.selectedPresets.isEmpty)
        .padding(.horizontal)
    }
    
    // Helper Methods
    private func handlePresetTap(_ preset: Preset) {
        if vm.isPresetEditMode {
            vm.toggleSelection(for: preset)
        } else {
            vm.send(action: .goToPresetDetail(.edit, preset))
        }
    }
    
    private func showToastMessage(_ message: String) {
        toastMessage = message
        withAnimation {
            showToast = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showToast = false
            }
        }
    }
}

// Toast View
extension PresetView {
    @ViewBuilder
    private var toastView: some View {
        if showToast {
            Text(toastMessage)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.8))
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

#Preview {
    PresetView(vm: .init(container: .stub, isPresetEditMode: false))
        .environmentObject(DIContainer.stub)
}
