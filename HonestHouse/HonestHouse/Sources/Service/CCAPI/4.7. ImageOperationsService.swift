//
//  ImageOperationsService.swift
//  HonestHouse
//
//  Created by 이현주 on 10/23/25.
//

import Combine
import CombineMoya
import Moya
import Foundation

protocol ImageOperationsServiceType {
    /// storageList 조회
    func getStorageList() async throws -> ImageOperations.StorageListResponse
    
    /// directoryList 조회
    func getDirectoryList(storage: String) async throws -> ImageOperations.DirectoryListResponse
    
    /// contentList(이미지 리스트) 조회
    func getContentList(storage: String, directory: String, type: String, order: String, onProgress: @escaping (ImageOperations.ContentListResponse) -> Void) async throws -> ImageOperations.ContentListResponse
    
    /// contentInfo(이미지 정보) 조회
    func getContentInfo(storage: String, directory: String, fileName: String) async throws -> ImageOperations.ContentInfoResponse
}

final class ImageOperationsService: BaseService, ImageOperationsServiceType {
    private let streamDownloadService = StreamDownloadService.shared
    
    func getStorageList() async throws -> ImageOperations.StorageListResponse {
        let response = try await request(ImageOperationsTarget.getStorageList, decoding: ImageOperations.StorageListResponse.self)
        
        return response
    }

    func getDirectoryList(storage: String) async throws -> ImageOperations.DirectoryListResponse {
        let response = try await request(ImageOperationsTarget.getDirectoryList(storage), decoding: ImageOperations.DirectoryListResponse.self)
        
        return response
    }
    
    func getContentList(
        storage: String,
        directory: String,
        type: String,
        order: String,
        onProgress: @escaping (ImageOperations.ContentListResponse) -> Void
    ) async throws -> ImageOperations.ContentListResponse {
        
        let url = try buildContentListURL(
            storage: storage,
            directory: directory,
            type: type,
            kind: "chunked",
            order: order
        )
        
        var allResponses: [ImageOperations.ContentListResponse] = []
        
        // StreamDownloadService 사용
        try await streamDownloadService.stream(
            from: url,
            headers: APIConstants.baseHeader,
            decoding: ImageOperations.ContentListResponse.self,
            onProgress: { responses in
                let mergedResponse = Self.mergeResponses(responses)
                
                DispatchQueue.main.async {
                    onProgress(mergedResponse)
                }
            },
            onComplete: { responses in
                allResponses = responses
            }
        )
        
        return Self.mergeResponses(allResponses)
    }
    
    func getContentInfo(storage: String, directory: String, fileName: String) async throws -> ImageOperations.ContentInfoResponse {
        let response = try await request(ImageOperationsTarget.getContentInfo(storage, directory, fileName), decoding: ImageOperations.ContentInfoResponse.self)
        
        return response
    }
    
    private static func mergeResponses(_ responses: [ImageOperations.ContentListResponse]) -> ImageOperations.ContentListResponse {
        let allUrls = responses.flatMap { $0.path ?? [] }
        return ImageOperations.ContentListResponse(path: allUrls)
    }
    
    private func buildContentListURL(
        storage: String,
        directory: String,
        type: String,
        kind: String,
        order: String
    ) throws -> URL {
        let version = CameraType.current?.imageOperationsVersion ?? .ver100
        let urlString = "\(BaseURLConstants.baseArchiveURL)\(version.description)/contents/\(storage)/\(directory)?type=\(type)&kind=\(kind)&order=\(order)"

        guard let url = URL(string: urlString) else {
            throw CCAPIError.invalidURL
        }
        
        return url
    }
}

final class StubImageOperationsService: ImageOperationsServiceType {
    func getStorageList() async throws -> ImageOperations.StorageListResponse {
        return .stub1
    }
    
    func getDirectoryList(storage: String) async throws -> ImageOperations.DirectoryListResponse {
        return .stub1
    }
    
    func getContentList(storage: String, directory: String, type: String, order: String, onProgress: @escaping (ImageOperations.ContentListResponse) -> Void) async throws -> ImageOperations.ContentListResponse {
        return .stub1
    }
    
    func getContentInfo(storage: String, directory: String, fileName: String) async throws -> ImageOperations.ContentInfoResponse {
        return .stub1
    }
}
