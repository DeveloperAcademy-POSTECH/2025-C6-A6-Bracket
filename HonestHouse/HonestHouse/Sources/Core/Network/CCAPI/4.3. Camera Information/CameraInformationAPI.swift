//
//  CameraInformationAPI.swift
//  HonestHouse
//
//  Created by Rama on 11/4/25.
//

import Foundation

enum CameraInformationAPI {
    case cameraFixedInformation
    
    var apiDesc: String {
        switch self {
        case .cameraFixedInformation:
            "ver100/deviceinformation"
        }
    }
}
