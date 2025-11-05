//
//  LiveViewInfo.swift
//  HonestHouse
//
//  Created by Rama on 10/28/25.
//

import Foundation

struct LiveViewInfo: Codable {
    let afFrame: [AFFrame]?
    let histogram: Histogram?
    let zoom: Zoom?
    let angle: [String: Double]?
    
    struct AFFrame: Codable {
        let x: Int
        let y: Int
        let width: Int
        let height: Int
        let status: String?
        let selected: Bool?
    }
    
    struct Histogram: Codable {
        let y: [Int]?
        let r: [Int]?
        let g: [Int]?
        let b: [Int]?
    }
    
    struct Zoom: Codable {
        let magnification: Double?
        let positionX: Int?
        let positionY: Int?
        let positionWidth: Int?
        let positionHeight: Int?
    }
}
