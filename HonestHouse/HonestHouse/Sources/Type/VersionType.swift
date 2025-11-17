//
//  VersionType.swift
//  HonestHouse
//
//  Created by Subeen on 10/23/25.
//

import Foundation

enum VersionType {
    case ver100
    case ver110
    case ver120
    case ver130
    case ver140
    
    var description: String {
        switch self {
        case .ver100:
            return "ver100"
        case .ver110:
            return "ver110"
        case .ver120:
            return "ver120"
        case .ver130:
            return "ver130"
        case .ver140:
            return "ver140"
        }
    }
}
