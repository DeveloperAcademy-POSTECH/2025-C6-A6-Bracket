//
//  Managers.swift
//  HonestHouse
//
//  Created by Subeen on 10/29/25.
//

import Foundation
import CoreData

protocol ManagersType {
    var visionManager: VisionManagerType { get }
    var photoManager: PhotoManagerType { get }
    var imagePrefetchManager: ImagePrefetchManagerType { get }
    var presetManager: PresetManagerType { get }
}

final class Managers: ManagersType {
    var visionManager: VisionManagerType
    var photoManager: PhotoManagerType
    var imagePrefetchManager: ImagePrefetchManagerType
    var presetManager: PresetManagerType
    
    init(viewContext: NSManagedObjectContext) {
        self.visionManager = VisionManager()
        self.photoManager = PhotoManager()
        self.imagePrefetchManager = ImagePrefetchManager()
        self.presetManager = PresetManager(viewContext: viewContext)
    }
}

// MARK: - StubManagers

final class StubManagers: ManagersType {
    var visionManager: VisionManagerType = StubVisionManager()
    var photoManager: PhotoManagerType = StubPhotoManager()
    var imagePrefetchManager: ImagePrefetchManagerType = StubImagePrefetchManager()
    var presetManager: PresetManagerType = StubPresetManager()
}
