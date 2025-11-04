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

final class PresetManager: PresetManagerType {
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
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

    /// 모든 SelectedPreset 조회 (order 기준 오름차순)
    func fetchSelectedPresets() throws -> [Preset] {
        let request = SelectedPresetEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SelectedPresetEntity.order, ascending: true)]

        let selectedEntities = try viewContext.fetch(request)
        return selectedEntities.compactMap { $0.preset?.toPreset() }
    }
    
    /// 활성화된 SelectedPreset 조회 (order 기준 오름차순)
    func fetchActivatedPresets() throws -> [Preset] {
        let request = SelectedPresetEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isActivated == YES")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SelectedPresetEntity.order, ascending: true)]

        let selectedEntities = try viewContext.fetch(request)
        return selectedEntities.compactMap { $0.preset?.toPreset() }
    }

    /// SelectedPreset의 isActivated toggle
    func toggleSelectedPresetActivation(presetId: UUID) throws {
        let request = SelectedPresetEntity.fetchRequest()
        request.predicate = NSPredicate(format: "preset.presetId == %@", presetId as CVarArg)
        request.fetchLimit = 1

        guard let selectedPresetEntity = try viewContext.fetch(request).first else {
            throw PresetManagerError.selectedPresetNotFound(presetId)
        }

        selectedPresetEntity.isActivated.toggle()

        try saveContext()
    }

    /// 특정 order의 SelectedPreset 업데이트 (프리셋 변경)
    func updateSelectedPresetAtOrder(order: Int, presetId: UUID) throws {
        guard order >= 0 && order < 3 else {
            throw PresetManagerError.invalidOrder(order)
        }

        let selectedRequest = SelectedPresetEntity.fetchRequest()
        selectedRequest.predicate = NSPredicate(format: "order == %d", Int16(order))
        selectedRequest.fetchLimit = 1

        let presetRequest = PresetEntity.fetchRequest()
        presetRequest.predicate = NSPredicate(format: "presetId == %@", presetId as CVarArg)
        presetRequest.fetchLimit = 1

        guard let presetEntity = try viewContext.fetch(presetRequest).first else {
            throw PresetManagerError.presetNotFound(presetId)
        }

        if let selectedPresetEntity = try viewContext.fetch(selectedRequest).first {
            selectedPresetEntity.preset = presetEntity
            selectedPresetEntity.isActivated = true
        } else {
            let newSelectedPreset = SelectedPresetEntity(context: viewContext)
            newSelectedPreset.preset = presetEntity
            newSelectedPreset.isActivated = true
            newSelectedPreset.order = Int16(order)
        }

        try saveContext()
    }
    
    // MARK: - Create
    
    /// 새 Preset 생성
    func createPreset(_ preset: Preset) throws {
        let entity = PresetEntity(context: viewContext)
        updateEntityFromPreset(entity, preset: preset)
        
        try saveContext()
    }
    
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
    case selectedPresetNotFound(UUID)
    case invalidOrder(Int)
    case saveFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .presetNotFound(let id):
            return "Preset not found: \(id.uuidString)"
        case .selectedPresetNotFound(let id):
            return "SelectedPreset not found: \(id.uuidString)"
        case .invalidOrder(let order):
            return "Invalid order: \(order). Order must be between 0 and 2"
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

    func fetchActivatedSelectedPresets() throws -> [Preset] {
        return [.stub1, .stub2, .stub3]
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
