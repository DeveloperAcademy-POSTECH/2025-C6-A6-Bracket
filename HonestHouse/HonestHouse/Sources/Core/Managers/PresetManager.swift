//
//  PresetManager.swift
//  HonestHouse
//
//  Created by Subeen on 11/3/25.
//

import Foundation
import CoreData

protocol PresetManagerType {
    /// 모든 Preset 조회
    func fetchAllPresets() throws -> [Preset]
    
    /// ID로 Preset 조회
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

final class PresetManager: PresetManagerType {
    
    // MARK: - Properties
    
    private let viewContext: NSManagedObjectContext
    
    // MARK: - Initialization
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    // MARK: - Fetch
    
    /// 모든 Preset 조회 (생성일 기준 오름차순)
    func fetchAllPresets() throws -> [Preset] {
        let request = PresetEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PresetEntity.createdAt, ascending: true)]
        
        let entities = try viewContext.fetch(request)
        return entities.map { $0.toPreset() }
    }
    
    /// ID로 Preset 조회
    func fetchPreset(by id: UUID) throws -> Preset? {
        let request = PresetEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        let entities = try viewContext.fetch(request)
        return entities.first?.toPreset()
    }
    
    // MARK: - Create
    
    /// 새 Preset 생성
    func createPreset(_ preset: Preset) throws {
        let entity = PresetEntity(context: viewContext)
        updateEntityFromPreset(entity, preset: preset)
        
        try saveContext()
    }
    
    // MARK: - Update
    
    /// Preset 업데이트
    func updatePreset(_ preset: Preset) throws {
        let request = PresetEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", preset.id as CVarArg)
        request.fetchLimit = 1
        
        guard let entity = try viewContext.fetch(request).first else {
            throw PresetManagerError.presetNotFound(preset.id)
        }
        
        updateEntityFromPreset(entity, preset: preset)
        
        try saveContext()
    }
    
    // MARK: - Delete
    
    /// Preset 삭제
    func deletePreset(_ preset: Preset) throws {
        try deletePreset(by: preset.id)
    }
    
    /// ID로 Preset 삭제
    func deletePreset(by id: UUID) throws {
        let request = PresetEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        guard let entity = try viewContext.fetch(request).first else {
            throw PresetManagerError.presetNotFound(id)
        }
        
        viewContext.delete(entity)
        
        try saveContext()
    }
    
    // MARK: - Private Helpers
    
    /// Preset → PresetEntity 변환 (업데이트용)
    private func updateEntityFromPreset(_ entity: PresetEntity, preset: Preset) {
        entity.presetId = preset.id
        entity.name = preset.name
        entity.pictureStyle = preset.pictureStyle.rawValue
        entity.shootingMode = preset.shootingMode.rawValue
        entity.aperture = preset.aperture
        entity.shutterSpeed = preset.shutterSpeed
        entity.iso = preset.iso
        entity.exposureCompensation = preset.exposureCompensation
        entity.colorTemperature = preset.colorTemperature.map { Int16($0) } ?? 0
        entity.tintBlueAmber = preset.tintBlueAmber.map { Int16($0) } ?? 0
        entity.tintMagentaGreen = preset.tintMagentaGreen.map { Int16($0) } ?? 0
        entity.createdAt = preset.createdAt
        entity.updatedAt = preset.updatedAt
    }
    
    /// Context 저장
    private func saveContext() throws {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                throw PresetManagerError.saveFailed(error)
            }
        }
    }
}

// MARK: - Error

enum PresetManagerError: LocalizedError {
    case presetNotFound(UUID)
    case saveFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .presetNotFound(let id):
            return "Preset not found: \(id.uuidString)"
        case .saveFailed(let error):
            return "Failed to save context: \(error.localizedDescription)"
        }
    }
}

// MARK: - StubPresetManager

final class StubPresetManager: PresetManagerType {
    private var presets: [Preset] = [.stub1, .stub2, .stub3]
    
    func fetchAllPresets() throws -> [Preset] {
        return presets
    }
    
    func fetchPreset(by id: UUID) throws -> Preset? {
        return presets.first { $0.id == id }
    }
    
    func createPreset(_ preset: Preset) throws {
        presets.append(preset)
    }
    
    func updatePreset(_ preset: Preset) throws {
        if let index = presets.firstIndex(where: { $0.id == preset.id }) {
            presets[index] = preset
        }
    }
    
    func deletePreset(_ preset: Preset) throws {
        presets.removeAll { $0.id == preset.id }
    }
    
    func deletePreset(by id: UUID) throws {
        presets.removeAll { $0.id == id }
    }
}
