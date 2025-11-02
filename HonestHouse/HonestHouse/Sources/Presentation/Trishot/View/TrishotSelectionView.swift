//
//  TrishotSelectionView.swift
//  HonestHouse
//
//  Created by Subeen on 10/30/25.
//

import SwiftUI

struct TrishotSelectionView: View {
    
    // TODO: - Preset 전체 목록 어떻게 넘길지 정하기
//    var preset: Preset = .stub1
    var presetList: [Preset] = [.stub1, .stub2, .stub3, .stub1, .stub2, .stub3, .stub1, .stub2, .stub3, .stub1, .stub2, .stub3, .stub1, .stub2, .stub3, .stub1, .stub2, .stub3]
    
    var body: some View {
        ZStack {
            Color.g12.ignoresSafeArea(.all)
            ScrollView {
                trishotItemListView(presetList)
            }
            .scrollIndicators(.hidden)
        }
    }
    
    // (트라이샷을 위한) 프리셋 아이템 리스트
    private func trishotItemListView(_ presetList: [Preset]) -> some View {
        VStack {
            ForEach(presetList, id: \.self) { item in
                trishotItemView(item)
            }
        }
    }
    
    // (트라이샷을 위한) 프리셋 아이템
    private func trishotItemView(_ preset: Preset) -> some View {
        HStack(alignment: .bottom, spacing: 4) {
            VStack(alignment: .leading, spacing: 14) {
                nameView(preset.name)
                iconListView()
                shootingDescriptionView(preset)
            }
            // TODO: info icon
            Text("i")
        }
        .padding(.leading, 14)
        .padding(.trailing, 16)
        .padding(.vertical, 14)
    }
    
    // 프리셋 이름
    private func nameView(_ name: String) -> some View {
        Text(name)
            .font(.labelL)
            .foregroundStyle(Color.g0)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // TODO: - 아이콘 대입하기
    // 촬영 세팅 아이콘 리스트
    private func iconListView() -> some View {
        HStack {
            Circle().frame(width: 32, height: 32).foregroundStyle(Color.g0)
            Circle().frame(width: 32, height: 32).foregroundStyle(Color.g0)
            Circle().frame(width: 32, height: 32).foregroundStyle(Color.g0)
            Circle().frame(width: 32, height: 32).foregroundStyle(Color.g0)
            Circle().frame(width: 32, height: 32).foregroundStyle(Color.g0)
        }
    }
    
    // TODO: - component로 빼기
    // F: [ ] ISO: [   ]
    private func shootingDescriptionView(_ preset: Preset) -> some View {
        Text(preset.settingsDescription)
            .foregroundStyle(Color.g0)
            .font(.num4)
    }
}

#Preview {
    TrishotSelectionView()
}
