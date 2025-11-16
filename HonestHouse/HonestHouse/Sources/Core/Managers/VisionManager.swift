//
//  VisionManager.swift
//  HonestHouse
//
//  Created by Rama on 10/24/25.
//

import Foundation
import Vision

final class VisionManager: VisionManagerType {
    private let imageLoader: ImageLoader
    
    init(imageLoader: ImageLoader = .shared) {
        self.imageLoader = imageLoader
    }
    
    func analyzeImages(
        _ photos: [Photo],
        threshold: Float
    ) async throws -> [SimilarPhotoGroup] {
        let features = try await extractFeatures(from: photos)
        
        return try await groupSimilarImages(
            analyzedPhotos: features,
            threshold: threshold,
            params: .default
        )
    }
    
    /// 각 이미지의 특징을 Vision으로 추출
    private func extractFeatures(from photos: [Photo]) async throws -> [AnalyzedPhoto] {
        var features: [AnalyzedPhoto] = []
        
        for photo in photos {
            do {
                let uiImage = try await imageLoader.fetchUIImage(from: photo.thumbnailURL)
                
                guard let cgImage = uiImage.cgImage else {
                    throw VisionError.cgImageConversion(url: photo.thumbnailURL)
                }
                
                // 1. 이미지 전체 특징 추출
                let featureRequest = VNGenerateImageFeaturePrintRequest()
                let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                try handler.perform([featureRequest])
                
                guard let featureObservation = featureRequest.results?.first else {
                    throw VisionError.observation(url: photo.thumbnailURL)
                }
                
                // 2. 얼굴 감지
                let faceRequest = VNDetectFaceLandmarksRequest()
                try? handler.perform([faceRequest])
                let faceObservation = faceRequest.results?.first
                
                features.append(
                    AnalyzedPhoto(
                        photo: photo,
                        observation: featureObservation,
                        faceObservation: faceObservation
                    )
                )
            }
            catch let imageLoadingError as ImageLoadingError {
                throw VisionError.imageFetching(url: photo.thumbnailURL, underlyingError: imageLoadingError)
            }
            catch let visionError as VisionError {
                throw visionError
            }
            catch {
                // 예상 못한 에러
                throw VisionError.imageFetching(url: photo.thumbnailURL, underlyingError: error)
            }
        }
        
        return features
    }
    
    /// 비슷한 이미지를 그룹핑
    private func groupSimilarImages(
        analyzedPhotos: [AnalyzedPhoto],
        threshold: Float,
        params: GroupingParams
    ) async throws -> [SimilarPhotoGroup] {
        var similarGroups: [SimilarPhotoGroup] = []
        var processedImageSet = Set<Int>()
        
        // 유사한 사진들끼리 그룹 생성
        for idx in 0..<analyzedPhotos.count {
            if processedImageSet.contains(idx) { continue }
            
            let group = try matchSimilarImages(
                startIndex: idx,
                photos: analyzedPhotos,
                threshold: threshold,
                params: params,
                processed: &processedImageSet
            )
            
            if let validGroup = group {
                similarGroups.append(validGroup)
            }
        }
        
        // 처리되지 않은 단독 사진들을 Extra 그룹으로 추가
        if let extraGroup = handleExtraPhotos(
            analyzedPhotos: analyzedPhotos,
            processedImageSet: processedImageSet
        ) {
            similarGroups.append(extraGroup)
        }
        
        return similarGroups
    }
    
    /// 그룹핑을 위한 이미지를 찾음
    private func matchSimilarImages(
        startIndex: Int,
        photos: [AnalyzedPhoto],
        threshold: Float,
        params: GroupingParams,
        processed: inout Set<Int>
    ) throws -> SimilarPhotoGroup? {
        var groupImages = [photos[startIndex].photo]
        var currentGroupIndexes = [startIndex]
        var distances: [Float] = []
        
        for idx in (startIndex + 1)..<photos.count {
            if processed.contains(idx) { continue }
            
            // 1. 평균 결합 거리 계산
            let avgDistance = try calculateAverageDistanceToGroup(
                targetIndex: idx,
                currentGroupIndexes: currentGroupIndexes,
                photos: photos,
                params: params
            )
            
            // 2. 완전 링크 제약 확인 (그룹 내 모든 사진과의 거리가 threshold 이하)
            let satisfiesCompleteLink = try fitsCompleteLinkConstraint(
                targetIndex: idx,
                currentGroupIndexes: currentGroupIndexes,
                photos: photos,
                params: params,
                threshold: threshold
            )
            
            // 3. 평균 < threshold AND 완전링크 만족 시에만 추가
            if avgDistance < threshold && satisfiesCompleteLink {
                groupImages.append(photos[idx].photo)
                currentGroupIndexes.append(idx)
                distances.append(avgDistance)
            }
        }
        
        guard groupImages.count > 1 else { return nil }
        
        for index in currentGroupIndexes {
            processed.insert(index)
        }
        
        return makeSimilarGroup(
            photos: groupImages,
            distances: distances,
            threshold: threshold
        )
    }
    
    /// 결합 거리: ImageFeature + Face + DateInfo
    private func combinedDistance(
        _ a: AnalyzedPhoto,
        _ b: AnalyzedPhoto,
        params: GroupingParams
    ) throws -> Float {
        // 1. Vision 시각 거리
        var visual: Float = 0
        try a.observation.computeDistance(&visual, to: b.observation)
        
        // 2. 시간 패널티
        guard let da = a.photo.dateInfo,
              let db = b.photo.dateInfo else {
            return 0
        }
        let dt = abs(da.timeIntervalSince(db))
        let sigma = max(params.timeSigma, 1)
        let gaussian = 1 - Float(exp(-(dt * dt) / (2 * sigma * sigma)))
        let temporal = min(gaussian, params.maxTimePenalty)
        
        // 3. Face (비교하는 두 이미지 모두 인물 사진이면, 얼굴 위치/크기도 고려)
        var facePenalty: Float = 0
        if a.hasFace && b.hasFace,
           let faceA = a.faceObservation,
           let faceB = b.faceObservation {
            let faceSimilarity = calculateFaceSimilarity(faceA, faceB)
            // 얼굴이 다르면 패널티 (최대 0.1)
            facePenalty = (1 - faceSimilarity) * 0.1
        }
        
        // 결합
        return params.alpha * visual + (1 - params.alpha) * temporal + facePenalty
    }
    
    /// 얼굴 유사도 계산
    private func calculateFaceSimilarity(
        _ faceA: VNFaceObservation,
        _ faceB: VNFaceObservation
    ) -> Float {
        
        // 이미지 내 얼굴 비율 비교
        let sizeA = faceA.boundingBox.width * faceA.boundingBox.height
        let sizeB = faceB.boundingBox.width * faceB.boundingBox.height
        let sizeDiff = abs(sizeA - sizeB) / max(sizeA, sizeB)
        
        // 얼굴 위치 비교 (중심점)
        let centerA = CGPoint(
            x: faceA.boundingBox.midX,
            y: faceA.boundingBox.midY
        )
        
        let centerB = CGPoint(
            x: faceB.boundingBox.midX,
            y: faceB.boundingBox.midY
        )
        
        let positionDiff = sqrt(
            pow(centerA.x - centerB.x, 2) +
            pow(centerA.y - centerB.y, 2)
        )
        
        // 0~1 정규화
        return Float(min(1.0, (sizeDiff + positionDiff) / 2))
    }
    
    /// 그룹 내 사진과 타겟 사진의 평균 결합 거리
    private func calculateAverageDistanceToGroup(
        targetIndex: Int,
        currentGroupIndexes: [Int],
        photos: [AnalyzedPhoto],
        params: GroupingParams
    ) throws -> Float {
        var sumDistance: Float = 0.0
        
        for idx in currentGroupIndexes {
            let distance = try combinedDistance(
                photos[idx],
                photos[targetIndex],
                params: params
            )
            sumDistance += distance
        }
        
        return sumDistance / Float(currentGroupIndexes.count)
    }
    
    /// 완전 링크 제약 확인 (그룹 내의 모든 사진과의 거리가 threshold 이하인지)
    private func fitsCompleteLinkConstraint(
        targetIndex: Int,
        currentGroupIndexes: [Int],
        photos: [AnalyzedPhoto],
        params: GroupingParams,
        threshold: Float
    ) throws -> Bool {
        for idx in currentGroupIndexes {
            let distance = try combinedDistance(
                photos[idx],
                photos[targetIndex],
                params: params
            )
            
            // 하나라도 threshold를 넘으면 실패
            if distance >= threshold {
                return false
            }
        }
        return true
    }
    
    /// 유사 그룹 생성
    private func makeSimilarGroup(
        photos: [Photo],
        distances: [Float],
        threshold: Float
    ) -> SimilarPhotoGroup {
        let avgDistance = distances.reduce(0, +) / Float(distances.count)
        let confidence = max(0, min(1, (threshold - avgDistance) / threshold))
        
        return SimilarPhotoGroup(
            photos: photos,
            averageDistance: avgDistance,
            confidence: confidence, isExtra: false
        )
    }
    
    /// 어떤 그룹에도 속하지 못한 단독 사진들을 Extra 그룹으로 생성
    private func handleExtraPhotos(
        analyzedPhotos: [AnalyzedPhoto],
        processedImageSet: Set<Int>
    ) -> SimilarPhotoGroup? {
        var extraPhotos: [Photo] = []
        
        for idx in 0..<analyzedPhotos.count {
            if !processedImageSet.contains(idx) {
                extraPhotos.append(analyzedPhotos[idx].photo)
            }
        }
        
        // Extra 사진이 없으면 nil 반환
        guard !extraPhotos.isEmpty else { return nil }
        
        // Extra 그룹 생성 (confidence와 averageDistance는 0)
        return SimilarPhotoGroup(
            photos: extraPhotos,
            averageDistance: 0.0,
            confidence: 0.0, isExtra: true
        )
    }
}

final class StubVisionManager: VisionManagerType {
    func analyzeImages(_ photos: [Photo], threshold: Float) async throws -> [SimilarPhotoGroup] {
        return [.init(photos: [], averageDistance: 0, confidence: 0, isExtra: true)]
    }
}
