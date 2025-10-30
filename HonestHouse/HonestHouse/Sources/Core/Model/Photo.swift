//
//  Photo.swift
//  HonestHouse
//
//  Created by Rama on 10/23/25.
//

import SwiftUI

struct Photo: Identifiable, SelectableItem {
    let id = UUID()
    var url: String
    var mediaType: MediaType
    
    var thumbnailURL: String {
        "\(url)?kind=thumbnail"
    }
    
    var displayURL: String {
        "\(url)?kind=display"
    }
    
    init(url: String) {
        self.url = url
        let fileExtension = (url as NSString).pathExtension.lowercased()
        switch fileExtension {
        case "jpeg":
            self.mediaType = .jpeg
        case "cr2":
            self.mediaType = .cr2
        case "cr3":
            self.mediaType = .cr3
        default:
            self.mediaType = .unknown
        }
    }
}

// MARK: - Equatable & Hashable Conformance
extension Photo: Equatable, Hashable {
    /// URL을 기준으로 동일성 비교 (UUID는 무시)
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        lhs.url == rhs.url && lhs.mediaType == rhs.mediaType
    }
    
    /// URL을 기반으로 hash 생성 (UUID는 무시)
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
        hasher.combine(mediaType)
    }
}

extension Photo {
    static func mockPhotos(count: Int) -> [Photo] {
        let baseURL = "https://raw.githubusercontent.com/Rama-Moon/MockImage/main"
        
        return (1...count).map { index in
            Photo(url: "\(baseURL)/photo\(index).JPG")
        }
    }
}

