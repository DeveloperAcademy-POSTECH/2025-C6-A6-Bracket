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
    func getContentList(storage: String, directory: String, type: String, order: String, onProgress: @escaping ([String]) -> Void) async throws -> ImageOperations.ContentListResponse
}

final class ImageOperationsService: BaseService, ImageOperationsServiceType {
    
    private let streamDownloadService = StreamDownloadService.shared
    
    // MARK: - GET list of storage URLs
    func getStorageList() async throws -> ImageOperations.StorageListResponse {
        let response = try await request(ImageOperationsTarget.getStorageList, decoding: ImageOperations.StorageListResponse.self)
        
        return response
    }

    // MARK: - GET list of storage directorie URLs
    func getDirectoryList(storage: String) async throws -> ImageOperations.DirectoryListResponse {
        let response = try await request(ImageOperationsTarget.getDirectoryList(storage), decoding: ImageOperations.DirectoryListResponse.self)
        
        return response
    }
    
    // MARK: - GET list of Content URLs
    func getContentList(
        storage: String,
        directory: String,
        type: String,
        order: String,
        onProgress: @escaping ([String]) -> Void
    ) async throws -> ImageOperations.ContentListResponse {
        
        let url = try buildContentListURL(
            storage: storage,
            directory: directory,
            type: type,
            kind: "chunked",
            order: order
        )
        
        var finalUrls: [String] = []
        
        // StreamDownloadService 사용
        try await streamDownloadService.stream(
            from: url,
            headers: APIConstants.baseHeader,
            decoding: ImageOperations.ContentListResponse.self,
            onProgress: { responses in
                let allUrls = responses.flatMap { $0.url ?? [] }
                onProgress(allUrls)
            },
            onComplete: { responses in
                finalUrls = responses.flatMap { $0.url ?? [] }
            }
        )
        
        return ImageOperations.ContentListResponse(url: finalUrls)
    }
    
    // MARK: - Private Methods
    
    private func getContentListChunked(
        storage: String,
        directory: String,
        type: String,
        order: String
    ) async throws -> ImageOperations.ContentListResponse {
        
        let url = try buildContentListURL(
            storage: storage,
            directory: directory,
            type: type,
            kind: "chunked",
            order: order
        )
        
        var finalUrls: [String] = []
        
        try await streamDownloadService.stream(
            from: url,
            headers: APIConstants.baseHeader,
            decoding: ImageOperations.ContentListResponse.self,
            onProgress: { _ in },
            onComplete: { responses in
                finalUrls = responses.flatMap { $0.url ?? [] }
            }
        )
        
        return ImageOperations.ContentListResponse(url: finalUrls)
    }
    
    private func buildContentListURL(
        storage: String,
        directory: String,
        type: String,
        kind: String,
        order: String
    ) throws -> URL {
        let urlString = "\(BaseAPI.base.apiDesc)ver100/contents/\(storage)/\(directory)?type=\(type)&kind=\(kind)&order=\(order)"
        
        guard let url = URL(string: urlString) else {
            throw CCAPIError.invalidURL
        }
        
        return url
    }
}

// MARK: - StubImageOperationsService

class StubImageOperationsService: ImageOperationsServiceType {
    func getStorageList() async throws -> ImageOperations.StorageListResponse {
        return .stub1
    }
    
    func getDirectoryList(storage: String) async throws -> ImageOperations.DirectoryListResponse {
        return .stub1
    }
    
    func getContentList(storage: String, directory: String, type: String, order: String, onProgress: @escaping ([String]) -> Void) async throws -> ImageOperations.ContentListResponse {
        return .stub1
    }
}
