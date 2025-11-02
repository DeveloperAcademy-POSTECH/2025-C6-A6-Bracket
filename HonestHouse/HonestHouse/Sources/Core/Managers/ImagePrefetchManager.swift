//
//  ImagePrefetchManager.swift
//  HonestHouse
//
//  Created by 이현주 on 11/1/25.
//

import Foundation
import Kingfisher
import UIKit

final class ImagePrefetchManager: ImagePrefetchManagerType {

    static let shared = ImagePrefetchManager()

    private let cache = ImageCache.default
    private let downloadQueue = DispatchQueue(label: "camera.prefetch", qos: .background)

    // 우선순위별 큐
    private var highPriorityQueue: [String] = []      // 즉시 (그룹 첫 사진)
    private var mediumPriorityQueue: [String] = []    // 500ms (좌우)
    private var lowPriorityQueue: [String] = []       // 1s (초기 30-50장)

    private var isProcessing = false
    private var lastDownloadTime: Date = .distantPast
    private var isInitialPrefetchCancelled = false

    private init() {
        configureCache()
    }

    private func configureCache() {
        // Memory: 150MB
        cache.memoryStorage.config.totalCostLimit = 150 * 1024 * 1024
        cache.memoryStorage.config.countLimit = 50

        // Disk: 2GB
        cache.diskStorage.config.sizeLimit = 2000 * 1024 * 1024

        // 만료: 세션 동안만
        cache.memoryStorage.config.expiration = .never
        cache.diskStorage.config.expiration = .never
    }

    // MARK: - 1. 초기 Prefetch (Low Priority, 취소 가능)

    /// 최근 30-50장 Display prefetch (백그라운드, 1초 간격)
    func startInitialPrefetch(photos: [Photo], count: Int = 50) {
        let recentPhotos = Array(photos.prefix(count))

        print("[Initial Prefetch] Starting prefetch for recent \(recentPhotos.count) photos")

        isInitialPrefetchCancelled = false

        downloadQueue.async { [weak self] in
            guard let self = self else { return }

            for photo in recentPhotos {
                // 취소 확인
                guard !self.isInitialPrefetchCancelled else {
                    print("[Initial Prefetch] Cancelled")
                    return
                }

                // 캐시 확인 (Memory + Disk)
                if !self.isCached(photo.displayURL) {
                    self.lowPriorityQueue.append(photo.displayURL)
                }
            }

            if !self.isProcessing {
                self.processQueue()
            }
        }
    }

    /// 초기 Prefetch 중단 (완료 버튼 시)
    func cancelInitialPrefetch() {
        downloadQueue.async { [weak self] in
            guard let self = self else { return }

            self.isInitialPrefetchCancelled = true
            self.lowPriorityQueue.removeAll()

            print("[Initial Prefetch] Stopped - Low priority queue cleared")
        }
    }

    // MARK: - 2. 좌우 Prefetch (Medium Priority)

    /// PhotoSelectionDetailView / GroupedPhotosDetailView 좌우 1-2장 prefetch
    func prefetchAdjacent(current: Photo, previous: Photo?, next: Photo?) {
        downloadQueue.async { [weak self] in
            guard let self = self else { return }

            // 다음 사진 우선
            if let next = next, !self.isCached(next.displayURL) {
                self.mediumPriorityQueue.insert(next.displayURL, at: 0)
            }

            // 이전 사진
            if let previous = previous, !self.isCached(previous.displayURL) {
                self.mediumPriorityQueue.append(previous.displayURL)
            }

            if !self.isProcessing {
                self.processQueue()
            }
        }
    }

    // MARK: - 3. 그룹 첫 사진 Prefetch (High Priority)

    /// 각 그룹의 첫 번째 사진 prefetch (Vision과 병렬)
    func prefetchGroupFirstPhotos(groups: [SimilarPhotoGroup]) async {
        let firstPhotos = groups.compactMap { $0.photos.first }

        await withCheckedContinuation { continuation in
            downloadQueue.async { [weak self] in
                guard let self = self else {
                    continuation.resume()
                    return
                }

                for photo in firstPhotos {
                    if !self.isCached(photo.displayURL) {
                        self.highPriorityQueue.append(photo.displayURL)
                    }
                }

                if !self.isProcessing {
                    self.processQueue()
                }

                continuation.resume()
            }
        }

        // 모든 그룹 첫 사진 다운로드 완료 대기 - vision 처리까지 완료시 GroupedPhotosView로 넘어감
        await waitForHighPriorityQueueCompletion()
    }

    private func waitForHighPriorityQueueCompletion() async {
        while true {
            // continuation으로 안전하게 highPriorityQueue에 접근하여 isEmpty값 가져옴
            let isEmpty = await withCheckedContinuation { continuation in
                downloadQueue.async { [weak self] in // 메인스레드가 아닌 downloadQueue에서 접근
                    continuation.resume(returning: self?.highPriorityQueue.isEmpty ?? true)
                }
            }

            // 완료되면 탈출
            if isEmpty {
                print("[Group First Prefetch] All completed")
                break
            }

            // 100ms마다 반복 체크
            try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
        }
    }

    // MARK: - Sequential Download with Priority

    private func processQueue() {
        downloadQueue.async { [weak self] in
            guard let self = self else { return }

            // 취소된 초기 prefetch는 스킵
            if self.isInitialPrefetchCancelled && !self.lowPriorityQueue.isEmpty {
                self.lowPriorityQueue.removeAll()
            }

            // 우선순위별로 다음 URL 선택
            guard let (urlString, priority) = self.getNextURL() else {
                self.isProcessing = false // 큐 비었으면 종료
                return
            }

            guard let url = URL(string: urlString) else {
                self.processQueue()
                return
            }

            self.isProcessing = true

            // 우선순위별 간격 적용
            let interval: TimeInterval = {
                switch priority {
                case .high: return 0.0      // 즉시
                case .medium: return 0.5    // 500ms
                case .low: return 1.0       // 1s
                }
            }()

            let timeSinceLastDownload = Date().timeIntervalSince(self.lastDownloadTime)
            if timeSinceLastDownload < interval {
                Thread.sleep(forTimeInterval: interval - timeSinceLastDownload)
            }

            self.lastDownloadTime = Date()

            // 현재 큐에 있는 내용물 count 확인용
            print("📥 [\(priority)] \(url.lastPathComponent) (H:\(self.highPriorityQueue.count) M:\(self.mediumPriorityQueue.count) L:\(self.lowPriorityQueue.count))")

            // Kingfisher로 다운로드 (Memory + Disk 캐싱)
            let modifier = AnyModifier { request in
                var r = request
                r.timeoutInterval = 30.0
                return r
            }

            KingfisherManager.shared.retrieveImage(
                with: url,
                options: [
                    .requestModifier(modifier),
                    .backgroundDecode,
                    .processor(DownsamplingImageProcessor(size: CGSize(width: 1200, height: 1200))),
                    .cacheOriginalImage,        // Disk에도 캐싱
                    .retryStrategy(DelayRetryStrategy(maxRetryCount: 1, retryInterval: .seconds(2)))
                ]
            ) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success(let imageResult):
                    let source = imageResult.cacheType == .none ? "Network" :
                                 imageResult.cacheType == .memory ? "Memory" : "Disk"
                    print("✅ [\(priority)] Success from \(source): \(url.lastPathComponent)")
                case .failure(let error):
                    print("❌ [\(priority)] Failed: \(url.lastPathComponent) - \(error.localizedDescription)")

                    // Display 실패 시 Original로 fallback prefetch
                    if urlString.contains("?kind=display") {
                        let originalURL = urlString.replacingOccurrences(of: "?kind=display", with: "")
                        print("🔄 [\(priority)] Fallback to original: \(url.lastPathComponent)")

                        // Original을 같은 우선순위 큐의 맨 앞에 추가
                        self.downloadQueue.async {
                            switch priority {
                            case .high:
                                self.highPriorityQueue.insert(originalURL, at: 0)
                            case .medium:
                                self.mediumPriorityQueue.insert(originalURL, at: 0)
                            case .low:
                                self.lowPriorityQueue.insert(originalURL, at: 0)
                            }
                        }
                    }
                }

                // 다음 다운로드
                self.processQueue()
            }
        }
    }

    private func getNextURL() -> (String, Priority)? {
        // High → Medium → Low 순서
        if !highPriorityQueue.isEmpty {
            return (highPriorityQueue.removeFirst(), .high)
        }
        if !mediumPriorityQueue.isEmpty {
            return (mediumPriorityQueue.removeFirst(), .medium)
        }
        if !lowPriorityQueue.isEmpty && !isInitialPrefetchCancelled {
            return (lowPriorityQueue.removeFirst(), .low)
        }
        return nil // 모든 queue가 비어있음
    }

    private enum Priority: CustomStringConvertible {
        case high, medium, low

        var description: String {
            switch self {
            case .high: return "HIGH"
            case .medium: return "MED"
            case .low: return "LOW"
            }
        }
    }

    // MARK: - Cache Check (Memory + Disk)

    private func isCached(_ urlString: String) -> Bool {
        return cache.isCached(forKey: urlString)
    }

    // MARK: - Clear Cache

    func clearAllCache() {
        cache.clearMemoryCache()
        cache.clearDiskCache {
            print("🗑️ [Cache] All cache cleared (Memory + Disk)")
        }
    }
}

// MARK: - Stub

final class StubImagePrefetchManager: ImagePrefetchManagerType {
    func startInitialPrefetch(photos: [Photo], count: Int) {}
    func cancelInitialPrefetch() {}
    func prefetchAdjacent(current: Photo, previous: Photo?, next: Photo?) {}
    func prefetchGroupFirstPhotos(groups: [SimilarPhotoGroup]) async {}
    func clearAllCache() {}
}
