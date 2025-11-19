//
//  ShootingModeType.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/28/25.
//

enum ShootingModeType: String, Codable, CaseIterable {
    case av = "Av"
    case tv = "Tv"
    case p = "P"

    var apiValue: String {
        return rawValue.lowercased()
    }

    var displayValue: String {
        return rawValue
    }

    static func from(apiValue: String) -> ShootingModeType? {
        switch apiValue.lowercased() {
        case "av":
            return .av
        case "tv":
            return .tv
        case "p":
            return .p
        default:
            return nil
        }
    }
}
