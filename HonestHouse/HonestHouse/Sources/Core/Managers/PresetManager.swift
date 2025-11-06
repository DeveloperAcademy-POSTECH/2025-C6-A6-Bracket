//
//  PresetManager.swift
//  HonestHouse
//
//  Created by Subeen on 11/3/25.
//

import Foundation
import CoreData

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
        Logger.debug("Fetched \(entities.count) presets from CoreData", category: .coreData)
        return entities.map { $0.toPreset() }
    }
    
    /// ID로 Preset 조회
    func fetchPreset(by id: UUID) throws -> Preset? {
        let request = PresetEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        let entities = try viewContext.fetch(request)
        if let preset = entities.first?.toPreset() {
            Logger.debug("Fetched preset: \(preset.name) (id: \(id))", category: .coreData)
            return preset
        }
        Logger.warning("Preset not found with id: \(id)", category: .coreData)
        return nil
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
    
    /// ### 새 Preset 생성
    /// 총 프리셋이 3개 미만인 경우 자동적으로 selectedPresetEntity가 된다.
    func createPreset(_ preset: Preset) throws {
        Logger.info("Creating preset: \(preset.name)", category: .coreData)
        
        let entity = PresetEntity(context: viewContext)
        updateEntityFromPreset(entity, preset: preset)

        let selectedPresetCount = try fetchSelectedPresets().count

        if selectedPresetCount < 3 {
            let selectedPresetEntity = SelectedPresetEntity(context: viewContext)
            selectedPresetEntity.preset = entity
            selectedPresetEntity.order = Int16(selectedPresetCount)
            selectedPresetEntity.isActivated = true
        }

        try saveContext()
        
        Logger.info("✅ Preset created successfully: \(preset.name) (id: \(preset.id))", category: .coreData)
//        logPresetDetails(preset)
    }
    
    /// Preset 업데이트
    func updatePreset(_ preset: Preset) throws {
        Logger.info("Updating preset: \(preset.name)", category: .coreData)
        
        let request = PresetEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", preset.id as CVarArg)
        request.fetchLimit = 1
        
        guard let entity = try viewContext.fetch(request).first else {
            throw PresetManagerError.presetNotFound(preset.id)
        }
        
        updateEntityFromPreset(entity, preset: preset)
        
        try saveContext()
        
        Logger.info("✅ Preset updated successfully: \(preset.name) (id: \(preset.id))", category: .coreData)
//        logPresetDetails(preset)
    }
    
    /// Preset 삭제
    func deletePreset(_ preset: Preset) throws {
        try deletePreset(by: preset.id)
    }
    
    /// ID로 Preset 삭제
    func deletePreset(by id: UUID) throws {
        Logger.info("Deleting preset with id: \(id)", category: .coreData)
        
        let request = PresetEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        guard let entity = try viewContext.fetch(request).first else {
            throw PresetManagerError.presetNotFound(id)
        }
        
        viewContext.delete(entity)
        
        try saveContext()
        
        Logger.info("✅ Preset deleted successfully (id: \(id))", category: .coreData)
    }
    
    /// Preset → PresetEntity 변환 (업데이트용)
    private func updateEntityFromPreset(_ entity: PresetEntity, preset: Preset) {
        entity.presetId = preset.id
        entity.name = preset.name
        entity.pictureStyle = preset.pictureStyle.rawValue
        entity.shootingMode = preset.shootingMode.rawValue
        
        // 옵셔널 String → 옵셔널 String (nil 허용)
        entity.aperture = preset.aperture
        entity.shutterSpeed = preset.shutterSpeed
        entity.iso = preset.iso
        entity.exposureCompensation = preset.exposureCompensation
        
        // Int? → Int16 (nil일 경우 0으로 저장)
        entity.colorTemperature = preset.colorTemperature.map { Int16($0) } ?? 0
        entity.tintBlueAmber = preset.tintBlueAmber.map { Int16($0) } ?? 0
        entity.tintMagentaGreen = preset.tintMagentaGreen.map { Int16($0) } ?? 0
        
        entity.createdAt = preset.createdAt
        entity.updatedAt = preset.updatedAt
    }
    
    /// Preset 상세 정보 로깅
    private func logPresetDetails(_ preset: Preset) {
        Logger.debug("""
        📋 Preset Details:
          - Name: \(preset.name)
          - ID: \(preset.id)
          - PictureStyle: \(preset.pictureStyle.rawValue)
          - ShootingMode: \(preset.shootingMode.rawValue)
          - Aperture: \(preset.aperture ?? "nil")
          - ShutterSpeed: \(preset.shutterSpeed ?? "nil")
          - ISO: \(preset.iso ?? "nil")
          - ExposureCompensation: \(preset.exposureCompensation ?? "nil")
          - ColorTemperature: \(preset.colorTemperature?.description ?? "nil")
          - TintBlueAmber: \(preset.tintBlueAmber?.description ?? "nil")
          - TintMagentaGreen: \(preset.tintMagentaGreen?.description ?? "nil")
          - CreatedAt: \(preset.createdAt)
          - UpdatedAt: \(preset.updatedAt)
        """, category: .coreData)
    }
    
    /// Context 저장
    private func saveContext() throws {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                Logger.debug("💾 CoreData context saved successfully", category: .coreData)
            } catch {
                Logger.error("❌ Failed to save CoreData context: \(error.localizedDescription)", category: .coreData)
                throw PresetManagerError.saveFailed(error)
            }
        } else {
            Logger.debug("No changes in CoreData context", category: .coreData)
        }
    }
}

// MARK: - Stub Implementation
final class StubPresetManager: PresetManagerType {
    private var presets: [Preset] = [.stub1, .stub2, .stub3]
    private var activatedPresets: Set<UUID> = [Preset.stub1.id, Preset.stub2.id, Preset.stub3.id]
    
    func fetchAllPresets() throws -> [Preset] {
        return presets
    }
    
    func fetchPreset(by id: UUID) throws -> Preset? {
        return presets.first { $0.id == id }
    }

    func fetchActivatedPresets() throws -> [Preset] {
        return presets.filter { activatedPresets.contains($0.id) }
    }

    func fetchSelectedPresets() throws -> [Preset] {
        return Array(presets.prefix(3))
    }

    func toggleSelectedPresetActivation(presetId: UUID) throws {
        if activatedPresets.contains(presetId) {
            activatedPresets.remove(presetId)
        } else {
            activatedPresets.insert(presetId)
        }
    }

    func updateSelectedPresetAtOrder(order: Int, presetId: UUID) throws {
        guard presets.contains(where: { $0.id == presetId }) else {
            throw PresetManagerError.presetNotFound(presetId)
        }
        activatedPresets.insert(presetId)
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
