//
//  CameraInformationTarget.swift
//  HonestHouse
//
//  Created by Rama on 11/4/25.
//

import Foundation
import Moya

enum CameraInformationTarget {
    case getCameraFixedInformation
}

extension CameraInformationTarget: BaseTargetType {
    var path: String {
        switch self {
        case .getCameraFixedInformation:
            return CameraInformationAPI.cameraFixedInformation.path(with: .ver100)
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getCameraFixedInformation:
                .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getCameraFixedInformation:
            return .requestPlain
        }
    }
}
