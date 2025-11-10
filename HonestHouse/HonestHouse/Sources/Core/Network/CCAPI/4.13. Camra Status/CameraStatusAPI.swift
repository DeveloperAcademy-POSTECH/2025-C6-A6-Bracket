//
//  CameraStatusAPI.swift
//  HonestHouse
//
//  Created by Rama on 11/10/25.
//

import Foundation

enum TimeoutType {
    case immediately
    case short
    case long
}

enum CameraStatusAPI {
    case getPolliing(TimeoutType)
    
    var endpoint: String {
        switch self {
        case .getPolliing(let timeout):
            return "event/polling?timeout=\(timeout)"
        }
    }
    
    func path(with version: VersionType) -> String {
        return "\(version.description)/\(endpoint)"
    }
}
