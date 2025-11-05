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
//        NavigationStack {
            ZStack(alignment: .bottom) {
                // 메인 컨텐츠
                mainContent
                
                // 하단 버튼
                Group {
                    if vm.isPresetEditMode {
                        deleteButton()
                    } else {
                        HStack {
                            Spacer()
                            addButton()
                        }
                    }
                }
                .padding(.bottom, 24)
                .padding(.horizontal)
            }
            .navigationTitle("프리셋")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    viewModeMenu
                }
            }
            .environment(vm)
            .onAppear {
                vm.loadPresets()
            }
//        }
    }
    
    // MARK: - Main Content
    @ViewBuilder
    private var mainContent: some View {
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
    
    // MARK: - Grid View
    private var gridView: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10)
            ],
            spacing: 10
        ) {
            ForEach(vm.presets) { preset in
                PresetGridItem(
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
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
    
    // MARK: - List View
    private var listView: some View {
        LazyVStack(spacing: 10) {
            ForEach(vm.presets) { preset in
                PresetListItem(
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
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
    
    // MARK: - View Mode Menu
    private var viewModeMenu: some View {
        Menu {
            Button {
                vm.setViewMode(.list)
            } label: {
                Label("리스트 보기", systemImage: "list.bullet")
            }
            
            Button {
                vm.setViewMode(.grid)
            } label: {
                Label("그리드 보기", systemImage: "square.grid.2x2")
            }
        } label: {
            Image(systemName: vm.viewMode == .grid ? "square.grid.2x2" : "list.bullet")
                .font(.system(size: 18))
                .foregroundColor(.primary)
        }
    }
    
    // MARK: - Buttons
    private func addButton() -> some View {
        Button {
            vm.send(action: .goToPresetDetail(.create, nil))
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Circle().fill(Color.blue))
                .shadow(radius: 4, y: 2)
        }
    }
    
    private func deleteButton() -> some View {
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
    
    // MARK: - Helper Methods
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

// MARK: - Toast View
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
