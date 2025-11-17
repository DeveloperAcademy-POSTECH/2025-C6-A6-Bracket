//
//  GroupedPhotosViewModel.swift
//  HonestHouse
//
//  Created by Rama on 10/22/25.
//

import SwiftUI

@MainActor
@Observable
final class GroupedPhotosViewModel {
    private let container: DIContainer
    
    var photosFromSelection: [Photo]
    var selectedPhotosInGroup: [Photo] = []
    
    var groupingState: ViewState<[SimilarPhotoGroup], ArchiveError> = .idle
    var savingState: ViewState<Bool, ArchiveError> = .idle
    var savingProgress: (current: Int, total: Int) = (0, 0)
    var currentError: ArchiveError?
    
    init(
        container: DIContainer,
        selectedPhotos: [Photo]
    ) {
        self.container = container
        self.photosFromSelection = selectedPhotos
    }

    func startGrouping() {
        if case .loading = groupingState { return }
        if case .success = groupingState { return }

        groupingState = .loading

        Task {
            do {
                // Vision 처리 + 그룹 prefetch 병렬 실행
                async let visionResult = container.managers.visionManager.analyzeImages(photosFromSelection, threshold: 0.55)

                // Vision 완료 후 그룹 첫 사진 prefetch
                let groups = try await visionResult
                Logger.info("[Vision] Completed with \(groups.count) groups", category: .viewModel)

                // 그룹 첫 사진 prefetch (await으로 완료 대기)
                await container.managers.imagePrefetchManager.prefetchGroupFirstPhotos(groups: groups)
                Logger.info("[Group Prefetch] Completed", category: .viewModel)

                // 둘 다 완료 후 상태 업데이트
                groupingState = .success(groups)

            } catch let visionError as VisionError {
                groupingState = .failure(ArchiveError.fromVision(visionError))
            } catch {
                groupingState = .failure(.visionAnalysisFailed)
            }
        }
    }
    
    func saveSelectedPhotos() {
        let total = selectedPhotosInGroup.count
        savingProgress = (0, total)
        savingState = .loading

        Task {
            do {
                // Original 다운로드 + 갤러리 저장 (progress 콜백)
                try await container.managers.photoManager.savePhotos(photos: selectedPhotosInGroup) { [weak self] current, total in
                    guard let self = self else { return }
                    Task { @MainActor in
                        self.savingProgress = (current, total)
                        self.savingState = .loading
                    }
                }

                savingProgress = (total, total)
                try await Task.sleep(nanoseconds: 500_000_000)

                // 저장 완료 후 모든 캐시 삭제
                container.managers.imagePrefetchManager.clearAllCache()

                savingState = .success(true)
            } catch let error as PhotoError {
                savingState = .failure(ArchiveError.fromPhoto(error))
            } catch {
                savingState = .failure(.photoProcessingError)
            }
        }
    }
    
    func toggleGroupedPhotoView(for photo: Photo) {
        if let index = selectedPhotosInGroup.firstIndex(where: { $0.url == photo.url}) {
            selectedPhotosInGroup.remove(at: index)
        } else {
            selectedPhotosInGroup.append(photo)
        }
    }
    
    func goToMain() {
        container.navigationRouter.popToRoot()
    }
    
    func goToBack() {
        container.navigationRouter.pop()
    }

    /// 그룹 내 현재 Photo의 좌우 Photo 가져오기
    func getAdjacentPhotosInGroup(group: SimilarPhotoGroup, current: Photo) -> (previous: Photo?, next: Photo?) {
        guard let currentIndex = group.photos.firstIndex(where: { $0.url == current.url }) else {
            return (nil, nil)
        }

        let previous = currentIndex > 0 ? group.photos[currentIndex - 1] : nil
        let next = currentIndex < group.photos.count - 1 ? group.photos[currentIndex + 1] : nil

        return (previous, next)
    }

    /// GroupedDetailView에서 좌우 1-2장 prefetch
    func prefetchAdjacentPhotosInGroup(group: SimilarPhotoGroup, current: Photo) {
        let (previous, next) = getAdjacentPhotosInGroup(group: group, current: current)
        container.managers.imagePrefetchManager.prefetchAdjacent(current: current, previous: previous, next: next)
    }

    /// 특정 그룹에서 선택된 사진 개수
    func selectedCountInGroup(in group: SimilarPhotoGroup) -> Int {
        selectedPhotosInGroup.filter { selectedPhoto in
            group.photos.contains(where: { $0.url == selectedPhoto.url })
        }.count
    }
    
    /// 특정 그룹에서 선택된 사진이 있을 때
    func hasSelectedPhotoInGroup(in group: SimilarPhotoGroup) -> Bool {
        selectedCountInGroup(in: group) == 0 ? false : true
    }

    /// 특정 그룹의 전체 사진 개수
    func totalCountInGroup(in group: SimilarPhotoGroup) -> Int {
        group.photos.count
    }
}
