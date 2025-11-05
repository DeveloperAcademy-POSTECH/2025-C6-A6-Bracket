//
//  PresetManagerType.swift
//  HonestHouse
//
//  Created by Rama on 11/5/25.
//

import Foundation

protocol PresetManagerType {
    // 모든 Preset 조회
    func fetchAllPresets() throws -> [Preset]
    
    // ID로 Preset 조회
    func fetchPreset(by id: UUID) throws -> Preset?
    
    /// 새 Preset 생성
    func createPreset(_ preset: Preset) throws
    
    /// Preset 업데이트
    func updatePreset(_ preset: Preset) throws
    
    /// Preset 삭제
    func deletePreset(_ preset: Preset) throws
    
    /// ID로 Preset 삭제
    func deletePreset(by id: UUID) throws
}
