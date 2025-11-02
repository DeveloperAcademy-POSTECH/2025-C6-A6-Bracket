//
//  PresetView.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/27/25.
//

import SwiftUI
import SwiftData

struct PresetView: View {
    @Query(sort: \Preset.createdAt, order: .reverse) private var presets: [Preset]
    
    @EnvironmentObject private var container: DIContainer
    
    @State var vm: PresetViewModel
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    
    var body: some View {
        ZStack(alignment: .bottom) {
            presetGridScrollView()

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

        }
        .task {
            NetworkManager.shared.configure(cameraIP: BaseURLConstants.cameraIP)
            Task {
                try await NetworkManager.shared.initializeAuthentication()
            }
            
            await vm.getAperture()
        }
        .environment(vm)
    }
    
    private func presetGridScrollView() -> some View {
        ScrollView {
            presetGridView()
            .padding(.top, 3)
            .padding(.horizontal, 2)
        }
        .scrollIndicators(.hidden)
    }
    
    private func presetGridView() -> some View {
        
        let columns = [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10)
        ]
        
        return LazyVGrid(columns: columns, spacing: 10) {
            ForEach(presets) { preset in
                PresetGridCellView(
                    preset: preset,
                    isEditMode: vm.isPresetEditMode,
                    isSelected: vm.selectedPresets.contains(preset.id)
                )
                .environment(vm)
            }
        }
    }

    private func addButton() -> some View {
        Button {
            
        } label: {
            if #available(iOS 26.0, *) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(width: 48, height: 48)
//                    .glassEffect()
            } else {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(width: 48, height: 48)
                    .background(Circle().fill(.gray))
            }
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
    }
}

#Preview {
    PresetView(vm: .init(container: .stub, isPresetEditMode: false))
        .environmentObject(DIContainer.stub)
}
