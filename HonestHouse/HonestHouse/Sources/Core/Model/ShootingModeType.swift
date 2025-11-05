//
//  ShootingModeType.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/28/25.
//

import Foundation

enum ShootingModeType: String {
    case av = "Av"
    case tv = "Tv"
    case p = "P"

    var apiValue: String {
        return rawValue.lowercased()
    }

    var displayValue: String {
        return rawValue
    }
}
