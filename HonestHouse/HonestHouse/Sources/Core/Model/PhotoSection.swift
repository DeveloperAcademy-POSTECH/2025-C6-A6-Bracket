//
//  PhotoSection.swift
//  HonestHouse
//
//  Created by 이현주 on 11/11/25.
//

import Foundation

struct PhotoSection: Identifiable {
    let id = UUID()
    let date: Date
    let dateString: String
    var photos: [Photo]
    
    init(date: Date, photos: [Photo]) {
        self.date = date
        self.photos = photos
        self.dateString = DateFormatter.displayDateFormatter.string(from: date)
    }
}
