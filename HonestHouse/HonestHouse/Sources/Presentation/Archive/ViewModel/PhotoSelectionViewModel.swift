//
//  PhotoSelectionViewModel.swift
//  HonestHouse
//
//  Created by 이현주 on 10/23/25.
//

import SwiftUI

enum PhotoSelectionAction {
    case goToGroupedPhoto
}

@MainActor
@Observable
final class PhotoSelectionViewModel {
    private var container: DIContainer

    var state: ViewState<[String], ArchiveError> = .idle
    
    var storageList: StorageList?
    var directoryList: DirectoryList?
    var contentList: ContentList?
    
    var presentStorage: String?
    var presentDirectory: String?
    
    var entireContentUrls: [String] = []
    var selectedPhotos: Set<Photo> = []

    private var hasStartedInitialPrefetch = false
    private var hasSetSuccessState = false

    var allPhotos: [Photo] {
        entireContentUrls.map { Photo(url: $0) }
    }

    init(container: DIContainer) {
        self.container = container
    }

    func send(action: PhotoSelectionAction) {
        switch action {
        case .goToGroupedPhoto:
            container.navigationRouter.push(to: .groupedPhotos(Array(selectedPhotos)))
        }
    }
    
    /// storageListResponse를 받아와서 storageList로 변환
    func getStorageList() async throws {
        let storageListResponse = try await imageOperationsService.getStorageList()
        storageList = storageListResponse.toEntity()
    }
    
    /// directoryListResponse를 받아와서 directoryList로 변환
    func getDirectoryList(storage: String) async throws {
        let directoryListResponse = try await imageOperationsService.getDirectoryList(storage: storage)
        directoryList = directoryListResponse.toEntity()
    }
    
    /// contentListResponse를 받아와서 contentList로 변환
    func getContentList(storage: String, directory: String, type: String, order: String) async throws {
        let response = try await imageOperationsService.getContentList(
            storage: storage,
            directory: directory,
            type: type,
            order: order,
            onProgress: { [weak self] response in

                guard let self = self else { return }

                self.contentList = response.toEntity()
                self.entireContentUrls = self.contentList?.url ?? []

                // 첫 chunk에서만 state를 .success로 설정
                if !self.hasSetSuccessState {
                    self.hasSetSuccessState = true
                    self.state = .success(self.entireContentUrls)
                }

                // 첫 100장 도착 시 prefetch 시작 (한 번만)
                if !self.hasStartedInitialPrefetch && self.entireContentUrls.count >= 100 {
                    self.hasStartedInitialPrefetch = true
                    let photos = self.entireContentUrls.map { Photo(url: $0) }
                    self.imagePrefetchManager.startInitialPrefetch(photos: photos, count: 50)
                }
            }
        )

        contentList = response.toEntity()
        entireContentUrls = contentList?.url ?? []
    }
    
    /// storageList에서 첫번째 storage 가져오기
    func setPresentStorage() async throws {
        try await getStorageList()
        guard
            let storageUrl = storageList?.url?.first,
            let storageName = storageUrl.split(separator: "/").last.map(String.init)
        else {
            throw ArchiveError.photoLoadFailed
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
            throw ArchiveError.photoLoadFailed
        }
        presentDirectory = dirName
    }
    
    /// 점진적 로딩으로 모든 이미지 가져오기
    func fetchAllImages() async {
        state = .loading()
        entireContentUrls.removeAll()
        hasSetSuccessState = false
        hasStartedInitialPrefetch = false

        do {
            // 1. Storage 설정
            try await setPresentStorage()
            guard let storage = presentStorage else { throw ArchiveError.photoLoadFailed }

            // 2. Directory 설정
            try await setPresentDirectory(storage: storage)
            guard let directory = presentDirectory else { throw ArchiveError.photoLoadFailed }

            // 3. Content List 가져오기 (점진적 로딩)
            try await getContentList(
                storage: storage,
                directory: directory,
                type: "jpeg",
                order: "desc"
            )

        } catch let archiveError as ArchiveError {
            state = .failure(archiveError)
        } catch let ccapiError as CCAPIError {
            state = .failure(ArchiveError.fromCCAPI(ccapiError))
        } catch {
            state = .failure(.photoLoadFailed)
        }
    }
    
    func toggleGridCell(for photo: Photo) {
        if selectedPhotos.contains(photo) {
            selectedPhotos.remove(photo)
        } else {
            selectedPhotos.insert(photo)
        }
    }
    
    func goToGroupedPhotos() {
        // 초기 prefetch 중단 (리소스 절약)
        container.managers.imagePrefetchManager.cancelSelectionPartPrefetch()

        container.navigationRouter.push(to: .groupedPhotos(Array(selectedPhotos)))
    }
    
    func goToBack() {
        container.navigationRouter.pop()
    }

    /// 현재 Photo의 좌우 Photo 가져오기
    func getAdjacentPhotos(current: Photo) -> (previous: Photo?, next: Photo?) {
        guard let currentIndex = allPhotos.firstIndex(where: { $0.url == current.url }) else {
            return (nil, nil)
        }

        let previous = currentIndex > 0 ? allPhotos[currentIndex - 1] : nil
        let next = currentIndex < allPhotos.count - 1 ? allPhotos[currentIndex + 1] : nil

        return (previous, next)
    }

    /// DetailView에서 좌우 1장씩 prefetch
    func prefetchAdjacentPhotos(current: Photo) {
        let (previous, next) = getAdjacentPhotos(current: current)
        container.managers.imagePrefetchManager.prefetchAdjacent(current: current, previous: previous, next: next)
    }
}
