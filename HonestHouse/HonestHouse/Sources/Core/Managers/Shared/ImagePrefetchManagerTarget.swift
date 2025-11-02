//
//  ImagePrefetchManagerTarget.swift
//  HonestHouse
//
//  Created by 이현주 on 11/2/25.
//

import Foundation
import Kingfisher
import UIKit

protocol ImagePrefetchManagerType {
    func startInitialPrefetch(photos: [Photo], count: Int)
    func cancelInitialPrefetch()
    func prefetchAdjacent(current: Photo, previous: Photo?, next: Photo?)
    func prefetchGroupFirstPhotos(groups: [SimilarPhotoGroup]) async
    func clearAllCache()
}
