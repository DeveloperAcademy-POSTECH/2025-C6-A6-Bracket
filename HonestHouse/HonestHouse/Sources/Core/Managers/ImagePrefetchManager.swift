//
//  ImagePrefetchManager.swift
//  HonestHouse
//
//  Created by 이현주 on 11/1/25.
//

import Foundation
import Kingfisher

/// 이미지 프리페치를 우선순위별로 관리하는 매니저
/// - High Priority: 그룹 첫 사진 (즉시)
/// - Medium Priority: 좌우 인접 사진 (500ms 간격)
/// - Low Priority: 초기 30-50장 (1초 간격)
final class ImagePrefetchManager: ImagePrefetchManagerType {
    private let cache = ImageCache.default
    private let downloadQueue = DispatchQueue(label: "camera.prefetch", qos: .background)

    private var highPriorityQueue: [String] = []
    private var mediumPriorityQueue: [String] = []
    private var lowPriorityQueue: [String] = []

    private var isProcessing = false
    private var lastDownloadTime: Date = .distantPast
    private var isInitialPrefetchCancelled = false

    init() {
        configureCache()
    }

    func startInitialPrefetch(photos: [Photo], count: Int = 50) {
        let recentPhotos = Array(photos.prefix(count))
        Logger.info("Starting prefetch for recent \(recentPhotos.count) photos", category: .prefetch)

        isInitialPrefetchCancelled = false

        downloadQueue.async { [weak self] in
            guard let self = self else { return }

            for photo in recentPhotos {
                guard !self.isInitialPrefetchCancelled else {
                    Logger.info("[Initial Prefetch] Cancelled", category: .prefetch)
                    return
                }

                if !self.isCached(photo.displayURL) {
                    self.lowPriorityQueue.append(photo.displayURL)
                }
            }

            if !self.isProcessing {
                self.processQueue()
            }
        }
    }

    func cancelSelectionPartPrefetch() {
        downloadQueue.async { [weak self] in
            guard let self = self else { return }

            self.isInitialPrefetchCancelled = true
            self.lowPriorityQueue.removeAll()
            self.mediumPriorityQueue.removeAll()

            Logger.info("[Selection Prefetch] Stopped - Low and Medium priority queues cleared", category: .prefetch)
        }
    }

    func prefetchAdjacent(
        current: Photo,
        previous: Photo?,
        next: Photo?
    ) {
        downloadQueue.async { [weak self] in
            guard let self = self else { return }

            // Previous 먼저 추가 (맨 앞)
            if let previous = previous, !self.isCached(previous.displayURL) {
                self.mediumPriorityQueue.insert(previous.displayURL, at: 0)
            }

            // Next를 Previous보다 앞에 추가 (최우선)
            if let next = next, !self.isCached(next.displayURL) {
                self.mediumPriorityQueue.insert(next.displayURL, at: 0)
            }

            if !self.isProcessing {
                self.processQueue()
            }
        }
    }

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

        // 모든 그룹 첫 사진 다운로드 완료 대기
        await waitForHighPriorityQueueCompletion()
    }

    func clearAllCache() {
        downloadQueue.async { [weak self] in
            guard let self = self else { return }

            self.highPriorityQueue.removeAll()
            self.mediumPriorityQueue.removeAll()
            self.lowPriorityQueue.removeAll()

            Logger.info("All priority queues cleared", category: .prefetch)
        }

        cache.clearMemoryCache()
        cache.clearDiskCache {
            Logger.info("All cache cleared (Memory + Disk)", category: .prefetch)
        }
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

    private func waitForHighPriorityQueueCompletion() async {
        while true {
            // continuation으로 안전하게 highPriorityQueue에 접근
            let isEmpty = await withCheckedContinuation { continuation in
                downloadQueue.async { [weak self] in
                    continuation.resume(returning: self?.highPriorityQueue.isEmpty ?? true)
                }
            }

            if isEmpty {
                Logger.info("[Group First Prefetch] All completed", category: .prefetch)
                break
            }

            try? await Task.sleep(nanoseconds: 100_000_000)
        }
    }

    private func processQueue() {
        downloadQueue.async { [weak self] in
            guard let self = self else { return }

            // 취소된 초기 prefetch는 스킵
            if self.isInitialPrefetchCancelled && !self.lowPriorityQueue.isEmpty {
                self.lowPriorityQueue.removeAll()
            }

            // 우선순위별로 다음 URL 선택
            guard let (urlString, priority) = self.getNextURL() else {
                self.isProcessing = false
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
                case .high: return 0.0
                case .medium: return 0.5
                case .low: return 1.0
                }
            }()

            let timeSinceLastDownload = Date().timeIntervalSince(self.lastDownloadTime)
            if timeSinceLastDownload < interval {
                Thread.sleep(forTimeInterval: interval - timeSinceLastDownload)
            }

            self.lastDownloadTime = Date()

            Logger.debug("[\(priority)] \(url.lastPathComponent) (H:\(self.highPriorityQueue.count) M:\(self.mediumPriorityQueue.count) L:\(self.lowPriorityQueue.count))", category: .prefetch)

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
                    .cacheOriginalImage,
                    .retryStrategy(DelayRetryStrategy(maxRetryCount: 1, retryInterval: .seconds(2)))
                ]
            ) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success(let imageResult):
                    let source = imageResult.cacheType == .none ? "Network" :
                                 imageResult.cacheType == .memory ? "Memory" : "Disk"
                    
                    Logger.info("[\(priority)] Success from \(source): \(url.lastPathComponent)", category: .prefetch)
                case .failure(let error):
                    Logger.error("[\(priority)] Failed: \(url.lastPathComponent) - \(error.localizedDescription)", category: .prefetch)

                    // Display 실패 시 Original로 fallback
                    if urlString.contains("?kind=display") {
                        let originalURL = urlString.replacingOccurrences(of: "?kind=display", with: "")
                        
                        Logger.warning("[\(priority)] Fallback to original: \(url.lastPathComponent)", category: .prefetch)

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

                self.processQueue()
            }
        }
    }

    private func getNextURL() -> (String, Priority)? {
        if !highPriorityQueue.isEmpty {
            return (highPriorityQueue.removeFirst(), .high)
        }
        if !mediumPriorityQueue.isEmpty {
            return (mediumPriorityQueue.removeFirst(), .medium)
        }
        if !lowPriorityQueue.isEmpty && !isInitialPrefetchCancelled {
            return (lowPriorityQueue.removeFirst(), .low)
        }
        return nil
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

    private func isCached(_ urlString: String) -> Bool {
        return cache.isCached(forKey: urlString)
    }
}

/// 테스트용 Stub 구현체
final class StubImagePrefetchManager: ImagePrefetchManagerType {
    func startInitialPrefetch(photos: [Photo], count: Int) {}
    func cancelSelectionPartPrefetch() {}
    func prefetchAdjacent(current: Photo, previous: Photo?, next: Photo?) {}
    func prefetchGroupFirstPhotos(groups: [SimilarPhotoGroup]) async {}
    func clearAllCache() {}
}
