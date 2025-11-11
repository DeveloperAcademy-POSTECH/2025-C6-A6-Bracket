//
//  ShootingControlAPI.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/29/25.
//

enum ShootingControlAPI {
    case ignoreShootingMode
    
    var endpoint: String {
        switch self {
        case .ignoreShootingMode:
            return "shooting/control/ignoreshootingmodedialmode"
        }
    }
    
    func path(with version: VersionType) -> String {
        return "\(version.description)/\(endpoint)"
    }
}
