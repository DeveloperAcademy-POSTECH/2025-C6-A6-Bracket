//
//  PersistenceController.swift
//  HonestHouse
//
//  Created by Subeen on 11/3/25.
//

import CoreData

final class PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        // Preview용 샘플 데이터 생성
        for i in 0..<5 {
            let preset = PresetEntity(context: viewContext)
            preset.presetId = UUID()
            preset.name = "Sample Preset \(i + 1)"
            preset.pictureStyle = "auto"
            preset.shootingMode = "av"
            preset.createdAt = Date()
            preset.updatedAt = Date()
            preset.aperture = "5.6"
            preset.shutterSpeed = "1/125"
            preset.iso = "400"
            preset.exposureCompensation = "0"
        }
        
        try? viewContext.save()
        return controller
    }()
    
    let container: NSPersistentContainer
    
    private init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "PresetModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("CoreData Store failed to load: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch { //TODO: Error Handling
                print("Failed to save context: \(error.localizedDescription)")
            }
        }
    }
}
