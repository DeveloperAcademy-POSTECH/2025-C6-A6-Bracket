//
//  5. ContentInfoResponse.swift
//  HonestHouse
//
//  Created by 이현주 on 11/11/25.
//

import Foundation

extension ImageOperations {
    /// 콘텐츠 리스트
    struct ContentInfoResponse: BaseResponse {
        let filesize: Int
        let protect: String
        let archive: String
        let rotate: String
        let rating: String
        let lastmodifieddate: String
        let playtime: Int?
    }
}

extension ImageOperations.ContentInfoResponse {
    typealias EntityType = ContentInfo
    
    func toEntity() -> ContentInfo {
        ContentInfo(dateInfo: lastmodifieddate)
    }
    
    static var stub1: ImageOperations.ContentInfoResponse {
        .init(
            filesize: 0,
            protect: "",
            archive: "",
            rotate: "",
            rating: "",
            lastmodifieddate: "",
            playtime: 0
        )
    }
}
