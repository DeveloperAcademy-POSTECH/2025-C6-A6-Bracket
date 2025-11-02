////
////  PresetService.swift
////  HonestHouse
////
////  Created by BoMin Lee on 10/27/25.
////
//
//import SwiftData
//import Foundation
//
//protocol PresetServiceType {
//    func fetchAll() throws -> [Preset]
//    func fetch(by id: UUID) throws -> Preset?
//    func create(_ preset: Preset) throws
//    func update(_ preset: Preset) throws
//    func delete(_ preset: Preset) throws
//    func delete(at id: UUID) throws
//    func deleteAll() throws
//}
//
//final class PresetService: PresetServiceType {
//    private let modelContext: ModelContext
//
//    init(modelContext: ModelContext) {
//        self.modelContext = modelContext
//    }
//
//    func fetchAll() throws -> [Preset] {
//        let descriptor = FetchDescriptor<Preset>(
//            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
//        )
//        return try modelContext.fetch(descriptor)
//    }
//
//    func fetch(by id: UUID) throws -> Preset? {
//        let predicate = #Predicate<Preset> { preset in
//            preset.id == id
//        }
//        let descriptor = FetchDescriptor<Preset>(predicate: predicate)
//        return try modelContext.fetch(descriptor).first
//    }
//
//    func create(_ preset: Preset) throws {
//        modelContext.insert(preset)
//        try modelContext.save()
//    }
//
//    func update(_ preset: Preset) throws {
//        preset.updatedAt = Date()
//        try modelContext.save()
//    }
//
//    func delete(_ preset: Preset) throws {
//        modelContext.delete(preset)
//        try modelContext.save()
//    }
//
//    func delete(at id: UUID) throws {
//        guard let preset = try fetch(by: id) else {
//            throw PresetServiceError.presetNotFound(id)
//        }
//        try delete(preset)
//    }
//
//    func deleteAll() throws {
//        let presets = try fetchAll()
//        presets.forEach { modelContext.delete($0) }
//        try modelContext.save()
//    }
//}
//
//enum PresetServiceError: LocalizedError {
//    case presetNotFound(UUID)
//
//    var errorDescription: String? {
//        switch self {
//        case .presetNotFound(let id):
//            return "Preset with id \(id) not found"
//        }
//    }
//}
//
//// MARK: - StubPresetService
//
//final class StubPresetService: PresetServiceType {
//    func fetchAll() throws -> [Preset] {
//        return [.stub1]
//    }
//    
//    func fetch(by id: UUID) throws -> Preset? {
//        return .stub1
//    }
//    
//    func create(_ preset: Preset) throws {
//        return
//    }
//    
//    func update(_ preset: Preset) throws {
//        return
//    }
//    
//    func delete(_ preset: Preset) throws {
//        return
//    }
//    
//    func delete(at id: UUID) throws {
//        return
//    }
//    
//    func deleteAll() throws {
//        return
//    }
//}
