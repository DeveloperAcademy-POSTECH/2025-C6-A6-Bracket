//
//  3. ContentListResponse.swift
//  HonestHouse
//
//  Created by 이현주 on 10/23/25.
//

extension ImageOperations {
    /// 콘텐츠 리스트
    struct ContentListResponse: BaseResponse {
        let path: [String]?
    }
}

extension ImageOperations.ContentListResponse {
    typealias EntityType = ContentList
    
    func toEntity() -> ContentList {
        ContentList(url: path)
    }
    
    static var stub1: ImageOperations.ContentListResponse {
        .init(path: [""])
    }
}

