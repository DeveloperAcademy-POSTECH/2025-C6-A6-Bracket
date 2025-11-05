//
//  VisionManagerType.swift
//  HonestHouse
//
//  Created by Rama on 10/26/25.
//

import Vision

protocol VisionManagerType {
    func analyzeImages(_ photos: [Photo], threshold: Float) async throws -> [SimilarPhotoGroup]
}
