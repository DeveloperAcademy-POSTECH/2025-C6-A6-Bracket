//
//  1. StorageListResponse.swift
//  HonestHouse
//
//  Created by 이현주 on 10/23/25.
//

extension ImageOperations {
    /// 저장소 리스트
    struct StorageListResponse: BaseResponse {
        let url: [String]?
    }
}

extension ImageOperations.StorageListResponse {
    typealias EntityType = StorageList
    
    func toEntity() -> StorageList {
        StorageList(url: url)
    }
    
    static var stub1: ImageOperations.StorageListResponse {
        .init(url: [""])
    }
}
