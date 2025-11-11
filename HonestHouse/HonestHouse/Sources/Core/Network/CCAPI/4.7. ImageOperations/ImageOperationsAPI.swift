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
    case contentInfo(String, String, String) // 컨텐츠 정보
    
    var endpoint: String {
        switch self {
        case .storageList:
            "contents"
            
        case .directoryList(let storage):
            "contents/\(storage)"
            
        case .contentList(let storage, let directory):
            "contents/\(storage)/\(directory)"
            
        case .contentInfo(let storage, let directory, let fileName):
            "contents/\(storage)/\(directory)/\(fileName)"
        }
    }
    
    func path(with version: VersionType) -> String {
        return "\(version.description)/\(endpoint)"
    }
}
