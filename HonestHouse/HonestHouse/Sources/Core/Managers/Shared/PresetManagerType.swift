//
//  PresetManagerType.swift
//  HonestHouse
//
//  Created by Rama on 11/5/25.
//

import Foundation

protocol PresetManagerType {
    /// 모든 Preset 조회
    func fetchAllPresets() throws -> [Preset]
    
    /// ID로 Preset 조회
    func fetchPreset(by id: UUID) throws -> Preset?
    
    /// 모든 SelectedPreset 조회 (order 기준 오름차순)
    func fetchSelectedPresets() throws -> [Preset]
    
    /// 활성화된 SelectedPreset 조회 (order 기준 오름차순)
    func fetchActivatedPresets() throws -> [Preset]

    /// SelectedPreset의 isActivated toggle
    func toggleSelectedPresetActivation(presetId: UUID) throws

    /// 특정 order의 SelectedPreset 업데이트 (프리셋 변경)
    func updateSelectedPresetAtOrder(order: Int, presetId: UUID) throws

    /// 새 Preset 생성
    func createPreset(_ preset: Preset) throws
    
    /// Preset 업데이트
    func updatePreset(_ preset: Preset) throws
    
    /// Preset 삭제
    func deletePreset(_ preset: Preset) throws
    
    /// ID로 Preset 삭제
    func deletePreset(by id: UUID) throws
}
