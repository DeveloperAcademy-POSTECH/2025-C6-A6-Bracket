//
//  MainView.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/24/25.
//

import SwiftUI
import SwiftData

struct MainView: View {
    //TODO: App 파일에서 주입하도록 설정
    @EnvironmentObject private var container: DIContainer
    @EnvironmentObject var cameraConnectionManager: CameraConnectionManager
    
    @State var vm: MainViewModel
    @State var isPresetEditMode: Bool = false
    
    var body: some View {
        NavigationStack(path: $container.navigationRouter.destinations) {
            ZStack {
                Color.g12.ignoresSafeArea(.all)
                VStack(spacing: 12) {
                    cameraAndArchiveHeaderView()
                    CustomSegmentedControl(selection: $vm.selectedSegment)
                        .padding(.bottom, 24)
                    selectedSegmentView()
                }
                .screenPadding()
                .navigationDestination(for: NavigationDestination.self) {
                    NavigationRoutingView(destination: $0)
                }

                if vm.showModeChange {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            vm.showModeChange = false
                        }

                    modeChangeView()
                        .safeAreaPadding(.top, 34)
                        .safeAreaPadding(.trailing, 52)
                }
            }
        }
        .onAppear {
            if cameraConnectionManager.connectionState != .connected {
                cameraConnectionManager.showConnectionSheet = true
            }
        }
        .sheet(isPresented: $cameraConnectionManager.showConnectionSheet) {
            CameraConnectionView()
        }
    }
    
    private func cameraAndArchiveHeaderView() -> some View {
        HStack {
            Button {
                if cameraConnectionManager.connectionState != .connected {
                    cameraConnectionManager.showConnectionSheet = true
                }
            } label: {
                Image(.setting)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
            Spacer()

            if vm.showEditButton {
                Button {
                    vm.toggleEditMode()
                } label: {
                    Text(vm.isPresetEditMode ? "완료" : "편집")
                        .font(.system(size: 16, weight: .bold))
                }
                .padding(.trailing, 12)
            }

    private func modeChangeView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                vm.toggleEditMode()
                vm.showModeChange = false
            } label: {
                HStack(spacing: 10) {
                    Image(.presetSelect)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    Text("Preset 선택")
                        .font(.num3)
                        .foregroundStyle(Color.g0)
                }
            }
            Divider()
                .foregroundStyle(Color.g7)
                .frame(height: 0.5)
            Button {
                vm.viewMode = vm.viewMode == .grid ? .list : .grid
                vm.showModeChange = false
            } label: {
                HStack(spacing: 10) {
                    Image(vm.viewMode == .grid ? .list : .squareGrid)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    Text(vm.viewMode == .grid ? "목록으로 보기" : "갤러리로 보기")
                        .font(.num3)
                        .foregroundStyle(Color.g0)
                }
            }
        }
        .frame(width: 250)
        .padding(.vertical, 24)
        .padding(.horizontal, 21)
        .background {
            VisualEffectBlurView()
                .blur(radius: 6, opaque: true)
                .overlay {
                    (Color.g10.opacity(0.8))
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(radius: 20, x: 0, y: 4)
    }
    
    private func segmentedControlView() -> some View {
        Picker("", selection: Binding(
            get: { vm.selectedSegment },
            set: { vm.setSelectedSegment($0) }
        )) {
            ForEach(vm.segments, id: \.self) {
                Text($0.displayName)
                    .font(.system(size: 14, weight: .semibold))
            }
        }
        .pickerStyle(.palette)
    }
    
    @ViewBuilder
    private func selectedSegmentView() -> some View {
        if vm.selectedSegment == .trishot {
            TrishotSettingView(
                vm: TrishotSettingViewModel(container: container)
            )
        } else if vm.selectedSegment == .preset {
            PresetView(
                vm: PresetViewModel(
                    container: container,
                    isPresetEditMode: isPresetEditMode,
                    onEditModeChange: { newValue in
                        isPresetEditMode = newValue
                    }
                )
            )
        }
    }
}

#Preview {
    MainView(vm: .init(container: .stub), isPresetEditMode: false)
        .environmentObject(DIContainer.stub)
}
