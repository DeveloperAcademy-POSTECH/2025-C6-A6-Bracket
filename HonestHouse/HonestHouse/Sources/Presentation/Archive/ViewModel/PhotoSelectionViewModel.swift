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
    private let container: DIContainer
    
    var state: ViewState<[String], ArchiveError> = .idle
    var currentError: ArchiveError?
    
    var storageList: StorageList?
    var directoryList: DirectoryList?
    var contentList: ContentList?
    
    var presentStorage: String?
    var presentDirectory: String?
    
    var allPhotos: [Photo] = []
    var photoSections: [PhotoSection] = []  // 날짜별 섹션
    var selectedPhotos: Set<Photo> = []
    
    private var photosByDate: [String: [Photo]] = [:]  // 날짜별 임시 저장소
    private var processedUrls: Set<String> = []
    
    private var hasStartedInitialPrefetch = false
    private var hasSetSuccessState = false
    
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
        let storageListResponse = try await container.services.imageOperationsService.getStorageList()
        storageList = storageListResponse.toEntity()
    }
    
    /// directoryListResponse를 받아와서 directoryList로 변환
    func getDirectoryList(storage: String) async throws {
        let directoryListResponse = try await container.services.imageOperationsService.getDirectoryList(storage: storage)
        directoryList = directoryListResponse.toEntity()
    }
    
    /// contentListResponse를 받아와서 contentList로 변환
    func getContentList(storage: String, directory: String, type: String, order: String) async throws {
        let contentListResponse = try await container.services.imageOperationsService.getContentList(
            storage: storage,
            directory: directory,
            type: type,
            order: order,
            onProgress: { [weak self] response in
                guard let self = self else { return }
                
                self.contentList = response.toEntity()
                let newUrls = self.contentList?.url ?? []
                
                // 기존에 없는 URL만 추출
                let existingUrls = Set(self.processedUrls)
                let uniqueNewUrls = newUrls.filter { !existingUrls.contains($0) }
                
                // ContentInfo 가져온 후 섹션 구성
                Task {
                    await self.handleNewChunk(urls: uniqueNewUrls)
                }
            }
        )
        
        contentList = contentListResponse.toEntity()
    }
    
    /// contentInfoResponse를 받아와서 contentInfo로 변환
    func getContentInfo(storage: String, directory: String, fileName: String) async throws -> ContentInfo {
        let contentInfoResponse = try await container.services.imageOperationsService.getContentInfo(storage: storage, directory: directory, fileName: fileName)
        return contentInfoResponse.toEntity()
    }
    
    /// storageList에서 첫번째 storage 가져오기
    func setPresentStorage() async throws {
        try await getStorageList()
        guard
            let storageUrl = storageList?.url?.first,
            let storageName = storageUrl.split(separator: "/").last.map(String.init)
        else {
            throw ArchiveError.photoLoadingFailed
        }
        presentStorage = storageName
    }
    
    /// directoryList에서 첫번째 directory가져오기 (ver110, ver120)
    func setPresentDirectory(storage: String) async throws {
        try await getDirectoryList(storage: storage)
        guard
            let dirUrl = directoryList?.url?.first,
            let dirName = dirUrl.split(separator: "/").last.map(String.init)
        else {
            throw ArchiveError.photoLoadingFailed
        }
        presentDirectory = dirName
    }
    
    /// directoryList에서 첫번째 directory가져오기 (ver140)
    func setPresentDirectoryV140(storage: String) async throws {
        try await getDirectoryList(storage: storage)
        
        guard let dirUrl = directoryList?.url?.first else {
            throw ArchiveError.photoLoadingFailed
        }
        
        let components = dirUrl.split(separator: "/")
        
        guard components.count >= 2 else {
            throw ArchiveError.photoLoadingFailed
        }
        
        presentDirectory = components.suffix(2).joined(separator: "/")
    }
    
    /// 새 Chunk 처리: Info 먼저 가져온 후 섹션 구성
    private func handleNewChunk(urls: [String]) async {
        guard !urls.isEmpty else { return }
        
        // 중복 방지
        let uniqueUrls = urls.filter { !processedUrls.contains($0) }
        uniqueUrls.forEach { processedUrls.insert($0) }
        
        // ContentInfo 배치 처리
        await fetchContentInfoBatch(urls: uniqueUrls)
        
        // Prefetch 시작 (첫 20장 도착 시로 변경 - 503 에러 방지)
        if !hasStartedInitialPrefetch && allPhotos.count >= 20 {
            hasStartedInitialPrefetch = true
            container.managers.imagePrefetchManager.startInitialPrefetch(
                photos: allPhotos, count: 30
            )
        }
    }
    
    /// ContentInfo 배치 처리 (동시 요청 수 제한)
    private func fetchContentInfoBatch(urls: [String]) async {
        let batchSize = 5  // 10 → 5 (503 에러 방지)

        // 100개를 batchSize씩 나눠서 순차 처리
        for i in stride(from: 0, to: urls.count, by: batchSize) {
            let end = min(i + batchSize, urls.count)
            let batch = Array(urls[i..<end])

            await processBatch(batch)

            // 배치 간 지연 (ver140 카메라 503 에러 방지)
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1초
        }
    }
    
    /// 배치 병렬 처리
    private func processBatch(_ urls: [String]) async {
        await withTaskGroup(of: Photo?.self) { group in
            for url in urls {
                group.addTask {
                    do {
                        guard let storage = await self.presentStorage,
                              let directory = await self.presentDirectory,
                              let fileName = url.split(separator: "/").last.map(String.init) else {
                            return nil
                        }
                        
                        let contentInfo = try await self.getContentInfo(
                            storage: storage,
                            directory: directory,
                            fileName: fileName
                        )
                        
                        return Photo(
                            url: BaseURLConstants.baseArchiveURL + url,
                            dateInfo: contentInfo.dateInfo
                        )
                    } catch {
                        print("ContentInfo 가져오기 실패: \(url), \(error)")
                        // 실패한 경우 날짜 없이 Photo 생성
                        return Photo(url: BaseURLConstants.baseArchiveURL + url, dateInfo: nil)
                    }
                }
            }
            
            // 결과 수집
            var newPhotos: [Photo] = []
            for await photo in group {
                if let photo = photo {
                    newPhotos.append(photo)
                }
            }
            
            // allPhotos에 추가
            self.allPhotos.append(contentsOf: newPhotos)
            
            // 섹션 업데이트 (기존 섹션에 추가 or 새 섹션 생성)
            self.updatePhotoSections(with: newPhotos)
            
            // 첫 chunk에서만 state를 .success로 설정
            if !self.hasSetSuccessState && !self.photoSections.isEmpty {
                self.hasSetSuccessState = true
                self.state = .success([])
            }
        }
    }
    
    /// 섹션 업데이트: 같은 날짜면 추가, 다른 날짜면 새 섹션 생성
    private func updatePhotoSections(with newPhotos: [Photo]) {
        // 1. 날짜별로 Photo 분류
        for photo in newPhotos {
            // 날짜 정보가 없으면 스킵
            guard photo.dateInfo != nil else { continue }
            
            let dateKey = photo.dateKey
            
            // 중복 체크
            if let existingPhotos = photosByDate[dateKey],
               existingPhotos.contains(where: { $0.url == photo.url }) {
                continue
            }
            
            // 같은 날짜면 추가
            photosByDate[dateKey, default: []].append(photo)
        }
        
        // 2. 각 날짜의 Photo들을 시간순으로 정렬
        for dateKey in photosByDate.keys {
            photosByDate[dateKey]?.sort { photo1, photo2 in
                guard let date1 = photo1.dateInfo,
                      let date2 = photo2.dateInfo else {
                    return false
                }
                return date1 > date2  // 최신순 (내림차순)
            }
        }
        
        // 3. 섹션 재구성 (최신순 정렬)
        let sortedDateKeys = photosByDate.keys.sorted(by: >)
        
        photoSections = sortedDateKeys.compactMap { dateKey in
            guard let photos = photosByDate[dateKey],
                  !photos.isEmpty,
                  let firstDate = photos.first?.dateInfo else {
                return nil
            }
            
            return PhotoSection(date: firstDate, photos: photos)
        }
        
        self.allPhotos = photoSections.flatMap { $0.photos }
    }
    
    /// 점진적 로딩으로 모든 이미지 가져오기
    func fetchAllImages() async {
        state = .loading
        allPhotos.removeAll()
        photoSections.removeAll()
        photosByDate.removeAll()
        hasSetSuccessState = false
        hasStartedInitialPrefetch = false
        
        do {
            // 1. Storage 설정
            try await setPresentStorage()
            guard let storage = presentStorage else { throw ArchiveError.photoLoadingFailed }
            
            guard let cameraType = CameraType.current else {
                throw ArchiveError.photoLoadingFailed
            }
            
            // 2. Directory 설정
            switch cameraType.imageOperationsVersion {
            case .ver110, .ver120, .ver130:
                try await setPresentDirectory(storage: storage)
            case .ver140:
                try await setPresentDirectoryV140(storage: storage)
            default:
                throw ArchiveError.photoLoadingFailed
            }
            guard let directory = presentDirectory else { throw ArchiveError.photoLoadingFailed }
            
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
        } catch let urlError as URLError {
            // URLError 처리 (스트리밍 중 네트워크 에러)
            let ccapiError = CCAPIError.networkError(urlError)
            state = .failure(.fromCCAPI(ccapiError))
            
        } catch {
            state = .failure(.photoLoadingFailed)
        }
    }
    
    /// 특정 사진 선택/해제 토글
    func toggleGridCell(for photo: Photo) {
        if selectedPhotos.contains(photo) {
            selectedPhotos.remove(photo)
        } else {
            selectedPhotos.insert(photo)
        }
    }
    
    /// 특정 섹션의 모든 사진 선택/해제 토글
    func toggleSectionSelection(for section: PhotoSection) {
        if isAllSelected(in: section) {
            section.photos.forEach { selectedPhotos.remove($0) }
        } else {
            section.photos.forEach { selectedPhotos.insert($0) }
        }
    }
    
    /// 특정 섹션의 모든 사진이 선택되었는지 확인
    func isAllSelected(in section: PhotoSection) -> Bool {
        !section.photos.isEmpty && section.photos.allSatisfy { selectedPhotos.contains($0) }
    }
    
    func goToGroupedPhotos() {
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
