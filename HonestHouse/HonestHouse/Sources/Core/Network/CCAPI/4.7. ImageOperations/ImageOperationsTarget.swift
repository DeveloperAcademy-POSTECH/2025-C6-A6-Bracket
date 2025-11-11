//
//  ImageOperationsTarget.swift
//  HonestHouse
//
//  Created by 이현주 on 10/23/25.
//

import Moya
import Foundation

enum ImageOperationsTarget {
    case getStorageList
    case getDirectoryList(String)
    case getContentInfo(String, String, String)
}

extension ImageOperationsTarget: BaseTargetType {
    var path: String {
        switch self {
        case .getStorageList:
            return ImageOperationsAPI.storageList.path(with: .ver100)
            
        case .getDirectoryList(let storage):
            return ImageOperationsAPI.directoryList(storage).path(with: .ver100)
            
        case .getContentInfo(let storage, let directory, let fileName):
            return ImageOperationsAPI.contentInfo(storage, directory, fileName).path(with: .ver100)
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getStorageList, .getDirectoryList, .getContentInfo:
                .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getStorageList, .getDirectoryList:
            return .requestPlain
        case .getContentInfo:
            return .requestParameters(
                parameters: ["kind" : "info"],
                encoding: URLEncoding.queryString
            )
        }
    }
}
