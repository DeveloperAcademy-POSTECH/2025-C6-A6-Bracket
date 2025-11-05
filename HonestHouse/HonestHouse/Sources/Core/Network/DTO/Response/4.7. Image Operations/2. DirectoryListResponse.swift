//
//  2. DirectoryListResponse.swift
//  HonestHouse
//
//  Created by 이현주 on 10/23/25.
//

extension ImageOperations {
    /// 디렉토리 리스트
    struct DirectoryListResponse: BaseResponse {
        let url: [String]?
    }
}

extension ImageOperations.DirectoryListResponse {
    typealias EntityType = DirectoryList
    
    func toEntity() -> DirectoryList {
        DirectoryList(url: url)
    }
    
    static var stub1: ImageOperations.DirectoryListResponse {
        .init(url: [""])
    }
}
