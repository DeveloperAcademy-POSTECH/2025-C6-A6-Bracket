//
//  CameraInformationAPI.swift
//  HonestHouse
//
//  Created by Rama on 11/4/25.
//

import Foundation

enum CameraInformationAPI {
    case cameraFixedInformation
    
    var endpoint: String {
        switch self {
        case .cameraFixedInformation:
            "deviceinformation"
        }
    }
    
    func path(with version: VersionType) -> String {
        return "\(version.description)/\(endpoint)"
    }
}
