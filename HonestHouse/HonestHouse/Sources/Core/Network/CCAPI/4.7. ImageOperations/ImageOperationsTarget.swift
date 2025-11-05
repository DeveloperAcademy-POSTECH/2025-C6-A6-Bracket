//
//  ImageOperationsTarget.swift
//  HonestHouse
//
//  Created by 이현주 on 10/23/25.
//

import Moya

enum ImageOperationsTarget {
    case getStorageList
    case getDirectoryList(String)
}

extension ImageOperationsTarget: BaseTargetType {
    var path: String {
        switch self {
        case .getStorageList:
            return ImageOperationsAPI.storageList.apiDesc
            
        case .getDirectoryList(let value):
            return ImageOperationsAPI.directoryList(value).apiDesc
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getStorageList, .getDirectoryList:
                .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getStorageList, .getDirectoryList:
            return .requestPlain
        }
    }
}
