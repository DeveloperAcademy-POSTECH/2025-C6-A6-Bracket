//
//  SimilarPhotoGroup.swift
//  HonestHouse
//
//  Created by Rama on 10/24/25.
//

import Foundation

struct SimilarPhotoGroup: Identifiable, Equatable, Hashable {
    let id: UUID = UUID()
    let photos: [Photo]
    let averageDistance: Float
    let confidence: Float
}
