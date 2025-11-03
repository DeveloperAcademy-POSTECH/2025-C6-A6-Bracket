//
//  GroupedPhotosViewModel.swift
//  HonestHouse
//
//  Created by Rama on 10/22/25.
//

import SwiftUI

@MainActor
@Observable
class GroupedPhotosViewModel: ArchiveErrorHandleable {
    typealias Success = [SimilarPhotoGroup]
    typealias Failure = GroupingError
    
    private var visionManager: VisionManagerType
    private var photoManager: PhotoManagerType
    private var imagePrefetchManager: ImagePrefetchManagerType
    private var container: DIContainer
    
    var photosFromSelection: [Photo]
    var selectedPhotosInGroup: [Photo] = []
    
    var state: ArchiveState<Success, Failure> = .idle // GroupingState
    var savingState: SavingState = .idle
    
    init(
        container: DIContainer,
        selectedPhotos: [Photo]
    ) {
        self.container = container
        visionManager = container.managers.visionManager
        photoManager = container.managers.photoManager
        imagePrefetchManager = container.managers.imagePrefetchManager

        self.photosFromSelection = selectedPhotos
    }
    
    func handleError(_ error: Error) {
        if let groupingError = error as? GroupingError {
            state = .failure(groupingError)
        } else if let visionError = error as? VisionError {
            state = .failure(GroupingError.from(visionError: visionError))
        } else {
            // 예상치 못한 에러
            state = .failure(.unknown)
        }
    }
    
    func startGrouping() {
        if case .loading = state { return }
        if case .success = state { return }

        state = .loading

        Task {
            do {
                // Vision 처리 + 그룹 prefetch 병렬 실행
                async let visionResult = visionManager.analyzeImages(photosFromSelection, threshold: 0.8)

                // Vision 완료 후 그룹 첫 사진 prefetch
                let groups = try await visionResult
                print("[Vision] Completed with \(groups.count) groups")

                // 그룹 첫 사진 prefetch (await으로 완료 대기)
                await imagePrefetchManager.prefetchGroupFirstPhotos(groups: groups)
                print("[Group Prefetch] Completed")

                // 둘 다 완료 후 상태 업데이트
                state = .success(groups)

            } catch {
                handleError(error)
            }
        }
    }
    
    func saveSelectedPhotos() {
        let total = selectedPhotosInGroup.count
        savingState = .saving(current: 0, total: total)

        Task {
            do {
                // Original 다운로드 + 갤러리 저장 (progress 콜백)
                try await photoManager.savePhotos(photos: selectedPhotosInGroup) { [weak self] current, total in
                    guard let self = self else { return }
                    Task { @MainActor in
                        self.savingState = .saving(current: current, total: total)
                    }
                }

                // 완료 표시 (progressbar 끝까지)
                savingState = .saving(current: total, total: total)
                try await Task.sleep(nanoseconds: 300_000_000) // 0.3초

                // 저장 완료 후 모든 캐시 삭제
                imagePrefetchManager.clearAllCache()

                savingState = .success
            } catch {
                savingState = .failure(error.localizedDescription)
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
}

extension GroupedPhotosViewModel {
    func goToMain() {
        container.navigationRouter.popToRoot()
    }

    // MARK: - DetailView 유틸리티

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
        imagePrefetchManager.prefetchAdjacent(current: current, previous: previous, next: next)
    }

    // MARK: - 그룹별 선택 개수 관리
    /// 특정 그룹에서 선택된 사진 개수
    func selectedCount(in group: SimilarPhotoGroup) -> Int {
        selectedPhotosInGroup.filter { selectedPhoto in
            group.photos.contains(where: { $0.url == selectedPhoto.url })
        }.count
    }

    /// 특정 그룹의 전체 사진 개수
    func totalCount(in group: SimilarPhotoGroup) -> Int {
        group.photos.count
    }
}
