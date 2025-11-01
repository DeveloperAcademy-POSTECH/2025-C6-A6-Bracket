//
//  ImageOperationsTarget.swift
//  HonestHouse
//
//  Created by 이현주 on 10/23/25.
//

import Foundation
import Moya

enum ImageOperationsTarget {
    case getStorageList
    case getDirectoryList(String)
//    case getContentList(String, String, String, String, String)
}

extension ImageOperationsTarget: BaseTargetType {
    var path: String {
        switch self {
        case .getStorageList:
            return ImageOperationsAPI.storageList.apiDesc
            
        case .getDirectoryList(let value):
            return ImageOperationsAPI.directoryList(value).apiDesc
            
//        case .getContentList(let storage, let directory, _, _, _):
//            return ImageOperationsAPI.contentList(storage, directory).apiDesc
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
            
//        case .getContentList(_, _, let type, let kind, let order):
//            let parameters: [String : Any] = [
//                "type" : type,
//                "kind" : kind,
//                "order" : order
//            ]
//            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }
}
