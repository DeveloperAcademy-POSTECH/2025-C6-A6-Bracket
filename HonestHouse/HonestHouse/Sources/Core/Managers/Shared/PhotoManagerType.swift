//
//  PhotoManagerType.swift
//  HonestHouse
//
//  Created by Rama on 10/27/25.
//

protocol PhotoManagerType {
    func savePhotos(photos: [Photo], onProgress: ((Int, Int) -> Void)?) async throws
}
