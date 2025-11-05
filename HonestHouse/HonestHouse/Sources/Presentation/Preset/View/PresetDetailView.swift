//
//  PresetDetailView.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/27/25.
//

import SwiftUI
import SwiftData

//TODO: Preset CRUD 확인용 임시 뷰입니다. 추후 실제 PresetDetailView(가제) 구현 시 삭제 혹은 변경해주세요.

struct PresetDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State var vm: PresetDetailViewModel

    private let shootingModes: [ShootingModeType] = [.av, .tv, .p]
    private let pictureStyles: [PictureStyleType] = [.auto, .standard, .portrait, .landscape, .finedetail, .neutral, .faithful, .monochrome]
    
    var body: some View {
        Group {
            switch vm.presetDetailMode {
            case .view:
                generalView
            case .edit, .create:
                editView
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(vm.presetDetailMode == .create)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                if vm.presetDetailMode == .create {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button(toolbarButtonTitle) {
                    //TODO: switch vm.presetDetailMode 구현 필요
                }
            }
        }
    }
    
    private var editView: some View {
        VStack { }
    }
    
    private var generalView: some View {
        VStack { }
    }
    
    private var navigationTitle: String {
        switch vm.presetDetailMode {
        case .view:
            return vm.selectedPreset!.name
        case .edit:
            return "프리셋 편집"
        case .create:
            return "프리셋 생성"
        }
    }
    
    private var toolbarButtonTitle: String {
        switch vm.presetDetailMode {
        case .view:
            return "편집"
        case .edit, .create:
            return "저장"
        }
    }
}
