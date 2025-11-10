//
//  CameraStatusAPI.swift
//  HonestHouse
//
//  Created by Rama on 11/10/25.
//

import Foundation

enum TimeoutType: String {
    case immediately = "immediately"
    case short = "short"
    case long = "long"
}

enum CameraStatusAPI {
    case getPolliing(TimeoutType)
    
    var endpoint: String {
        switch self {
        case .getPolliing(let timeout):
            return "event/polling?timeout=\(timeout.rawValue)"
        }
    }
    
    func path(with version: VersionType) -> String {
        return "\(version.description)/\(endpoint)"
    }
}
