//
//  Managers.swift
//  HonestHouse
//
//  Created by Subeen on 10/29/25.
//

import Foundation

protocol ManagersType {
    var visionManager: VisionManagerType { get }
    var photoManager: PhotoManagerType { get }
    var imagePrefetchManager: ImagePrefetchManagerType { get }
}

final class Managers: ManagersType {
    var visionManager: VisionManagerType
    var photoManager: PhotoManagerType
    var imagePrefetchManager: ImagePrefetchManagerType

    init() {
        self.visionManager = VisionManager()
        self.photoManager = PhotoManager()
        self.imagePrefetchManager = ImagePrefetchManager.shared
    }
}

// MARK: - StubManagers

final class StubManagers: ManagersType {
    var visionManager: VisionManagerType = StubVisionManager()
    var photoManager: PhotoManagerType = StubPhotoManager()
    var imagePrefetchManager: ImagePrefetchManagerType = StubImagePrefetchManager()
}
