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
    var cameraConnectionManager: CameraConnectionManagerType { get }
    var imagePrefetchManager: ImagePrefetchManagerType { get }
}

final class Managers: ManagersType {
    var visionManager: VisionManagerType
    var photoManager: PhotoManagerType
    var cameraConnectionManager: CameraConnectionManagerType
    var imagePrefetchManager: ImagePrefetchManagerType
    init() {
        self.visionManager = VisionManager()
        self.photoManager = PhotoManager()
        self.cameraConnectionManager = CameraConnectionManager()
        self.imagePrefetchManager = ImagePrefetchManager()
    }
}

// MARK: - StubManagers

final class StubManagers: ManagersType {
    var visionManager: VisionManagerType = StubVisionManager()
    var photoManager: PhotoManagerType = StubPhotoManager()
    var cameraConnectionManager: CameraConnectionManagerType = StubCameraConnectionManager()
    var imagePrefetchManager: ImagePrefetchManagerType = StubImagePrefetchManager()
}
