//
//  ImageOperationsAPI.swift
//  HonestHouse
//
//  Created by 이현주 on 10/23/25.
//

enum ImageOperationsAPI {
    case storageList                      // 저장소 리스트
    case directoryList(String)            // 디렉토리 리스트
    case contentList(String, String)      // 컨텐츠(이미지) 리스트
    
    var apiDesc: String {
        switch self {
        case .storageList:
            "ver100/contents"
            
        case .directoryList(let storage):
            "ver100/contents/\(storage)"
            
        case .contentList(let storage, let directory):
            "ver100/contents/\(storage)/\(directory)"
        }
    }
}
