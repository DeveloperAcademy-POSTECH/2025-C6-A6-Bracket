//
//  PhotoSelectionViewModel.swift
//  HonestHouse
//
//  Created by 이현주 on 10/23/25.
//

import SwiftUI

@Observable
final class PhotoSelectionViewModel {
    typealias Success = [String]
    typealias Failure = SelectionError
    
    enum Action {
        case goToGroupedPhoto
    }
    
    private var container: DIContainer
    private var imageOperationsService: ImageOperationsServiceType
    
    var state: ArchiveState<Success, Failure> = .idle
    
    var storageList: StorageList?
    var directoryList: DirectoryList?
    var contentList: ContentList?
    
    var presentStorage: String?
    var presentDirectory: String?
    
    var entireContentUrls: [String] = []
    
    var selectedPhotos: Set<Photo> = []
    
    init(container: DIContainer) {
        self.container = container
        self.imageOperationsService = container.services.imageOperationsService
    }
}

extension PhotoSelectionViewModel: ArchiveErrorHandleable {
    
    func send(action: Action) {
        switch action {
            
        case .goToGroupedPhoto:
            container.navigationRouter.push(to: .groupedPhotos(Array(selectedPhotos)))
        }
    }
    
    func handleError(_ error: Error) {
        if let selectionError = error as? SelectionError {
            state = .failure(selectionError)
        } else {
            state = .failure(SelectionError.from(error))
        }
    }
    
    /// storageListResponse를 받아와서 storageList로 변환
    func getStorageList() async throws {
        do {
            let storageListResponse = try await imageOperationsService.getStorageList()
            storageList = storageListResponse.toEntity()
        } catch {
            throw SelectionError.from(error)
        }
    }
    
    /// directoryListResponse를 받아와서 directoryList로 변환
    func getDirectoryList(storage: String) async throws {
        do {
            let directoryListResponse = try await imageOperationsService.getDirectoryList(storage: storage)
            directoryList = directoryListResponse.toEntity()
        } catch {
            throw SelectionError.from(error)
        }
    }
    
    /// contentListResponse를 받아와서 contentList로 변환
    func getContentList(storage: String, directory: String, type: String, order: String) async throws {
        do {
            let response = try await imageOperationsService.getContentList(
                storage: storage,
                directory: directory,
                type: type,
                order: order,
                onProgress: handleContentListProgress
            )
            
            contentList = response.toEntity()
            entireContentUrls = contentList?.url ?? []
        } catch {
            throw SelectionError.from(error)
        }
    }
    
    /// 점진적 로딩 진행 상황 처리
    private func handleContentListProgress(_ response: ImageOperations.ContentListResponse) {
        Task { @MainActor in
            self.contentList = response.toEntity()
            self.entireContentUrls = self.contentList?.url ?? []
            self.state = .success(self.entireContentUrls)
        }
    }
    
    /// storageList에서 첫번째 storage 가져오기
    func setPresentStorage() async throws {
        try await getStorageList()
        guard
            let storageUrl = storageList?.url?.first,
            let storageName = storageUrl.split(separator: "/").last.map(String.init)
        else {
            throw SelectionError.generic
        }
        presentStorage = storageName
    }
    
    /// directoryList에서 첫번째 directory가져오기
    func setPresentDirectory(storage: String) async throws {
        try await getDirectoryList(storage: storage)
        guard
            let dirUrl = directoryList?.url?.first,
            let dirName = dirUrl.split(separator: "/").last.map(String.init)
        else {
            throw SelectionError.generic
        }
        presentDirectory = dirName
    }
    
    /// 점진적 로딩으로 모든 이미지 가져오기
    func fetchAllImages() async {
        state = .loading
        entireContentUrls.removeAll()
        
        do {
            // 1. Storage 설정
            try await setPresentStorage()
            guard let storage = presentStorage else { throw SelectionError.generic }
            
            // 2. Directory 설정
            try await setPresentDirectory(storage: storage)
            guard let directory = presentDirectory else { throw SelectionError.generic }
            
            // 3. Content List 가져오기 (점진적 로딩)
            try await getContentList(
                storage: storage,
                directory: directory,
                type: "jpeg",
                order: "desc"
            )
            
            // 4. 최종 완료
            state = .success(entireContentUrls)
            
        } catch {
            handleError(error)
        }
    }
    
    func toggleGridCell(for photo: Photo) {
        if selectedPhotos.contains(photo) {
            selectedPhotos.remove(photo)
        } else {
            selectedPhotos.insert(photo)
        }
    }
}

extension PhotoSelectionViewModel {
    func goToGroupedPhotos() {
        container.navigationRouter.push(to: .groupedPhotos(Array(selectedPhotos)))
    }
}
