//
//  CameraStatusTarget.swift
//  HonestHouse
//
//  Created by Rama on 11/10/25.
//

import Foundation
import Moya

enum CameraStatusTarget {
    case getPolling(TimeoutType)
}

extension CameraStatusTarget: BaseTargetType {
    var path: String {
        switch self {
        case .getPolling(let timeout):
            //R50V 기준 110으로 작성
            return CameraStatusAPI.getPolliing(timeout).path(with: .ver110)
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getPolling:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case .getPolling:
            return .requestPlain
        }
    }
}


