//
//  PhotoManager.swift
//  HonestHouse
//
//  Created by Rama on 10/27/25.
//

import Foundation
import Photos

final class PhotoManager: PhotoManagerType {
    private let imageLoader: ImageLoader
    private let albumName = "Bracket" // TODO: 추후 분리 예정
    
    init(imageLoader: ImageLoader = .shared) {
        self.imageLoader = imageLoader
    }
    
    func savePhotos(
        photos: [Photo],
        onProgress: ((Int, Int) -> Void)? = nil
    ) async throws {
        try await requestAuthorization()
        let album = try await getOrCreateAlbum(albumName: albumName)

        let total = photos.count
        for (index, photo) in photos.enumerated() {
            let current = index + 1

            let imageData = try await imageLoader.fetchImageData(from: photo.url)
            try await saveImageData(imageData, to: album)

            // Progress 콜백 호출 (저장 완료)
            onProgress?(current, total)
        }
    }
    
    private func requestAuthorization() async throws {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        switch status {
        case .authorized, .limited:
            return
        case .notDetermined:
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            if newStatus != .authorized && newStatus != .limited {
                throw PhotoError.authorizationDenied
            }
        case .denied:
            throw PhotoError.authorizationDenied
        case .restricted:
            throw PhotoError.authorizationRestricted
        default:
            throw PhotoError.unknown
        }
    }
    
    private func getOrCreateAlbum(albumName: String) async throws -> PHAssetCollection {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        if let album = collections.firstObject { return album }

        var albumPlaceholder: PHObjectPlaceholder?
        
        do {
            try await PHPhotoLibrary.shared().performChanges {
                let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
                albumPlaceholder = request.placeholderForCreatedAssetCollection
            }
            if let albumPlaceholder = albumPlaceholder,
               let createdAlbum = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers:
                                                                            [albumPlaceholder.localIdentifier], options: nil).firstObject {
                return createdAlbum
            } else {
                throw PhotoError.albumCreationFailed
            }
        } catch {
            throw PhotoError.albumCreationFailed
        }
    }
    
    private func saveImageData(_ data: Data, to album: PHAssetCollection) async throws {
        do {
            try await PHPhotoLibrary.shared().performChanges {
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(with: .photo, data: data, options: nil)
                if let assetPlaceholder = creationRequest.placeholderForCreatedAsset,
                   let albumChangeRequest = PHAssetCollectionChangeRequest(for: album) {
                    let assets: NSArray = [assetPlaceholder]
                    albumChangeRequest.addAssets(assets)
                }
            }
        } catch {
            throw PhotoError.photoSaveFailed(error)
        }
    }
}

final class StubPhotoManager: PhotoManagerType {
    func savePhotos(photos: [Photo], onProgress: ((Int, Int) -> Void)? = nil) async throws {
        return
    }
}
