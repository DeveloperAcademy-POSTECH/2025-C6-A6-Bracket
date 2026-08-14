# 기능: 아카이브 (사진 선택 → 유사 그룹핑 → 저장)

카메라 저장 매체의 사진을 불러와 선택하고, Vision으로 유사 사진을 그룹핑해 베스트 컷을 고른 뒤 기기 앨범("Bracket")에 저장하는 기능.

## 화면 흐름

```
PhotoSelectionView (날짜 섹션별 그리드, 다중 선택)
 ├─ PhotoSelectionDetailView (확대 보기, 좌우 스와이프)
 └─ GroupedPhotosView (유사 그룹 목록)
     └─ GroupedPhotosDetailView (그룹 내 비교/선택)
         → PhotoManager.savePhotos → "Bracket" 앨범 저장
```

## 1단계: 사진 목록 로딩 (`PhotoSelectionViewModel`)

1. `getStorageList` → 첫 storage 선택
2. `getDirectoryList` → 첫 directory 선택
   - **ver140(R50V)은 디렉토리 경로가 2단계**라 별도 처리 (`setPresentDirectoryV140`)
3. `getContentList(type: "jpeg", kind: "chunked", order: "desc")` — `StreamDownloadService`로 **점진적 로딩**: 청크 도착마다 `onProgress` 콜백
4. 새 URL마다 `getContentInfo`로 촬영 일시 조회 → `Photo(url:dateInfo:)` 생성
   - **배치 5개 동시 + 배치 간 0.1초 지연** (카메라 503 방지)
5. 날짜별 `PhotoSection` 구성 (최신순), 첫 청크 도착 시점에 `.success` 전환 → 스켈레톤 해제
6. 20장 도착 시 `ImagePrefetchManager.startInitialPrefetch` (30장 한정)

`Photo` 모델: `url` 기준 동일성. `thumbnailURL`(?kind=thumbnail) / `displayURL`(?kind=display). 확장자로 `MediaType`(jpeg/cr2/cr3) 판별.

## 2단계: 유사 그룹핑 (`GroupedPhotosViewModel` + `VisionManager`)

`startGrouping()` → `visionManager.analyzeImages(photos, threshold: 0.55)`

### VisionManager 알고리즘 (`Core/Managers/VisionManager.swift`)
1. **특징 추출**: 썸네일 로드 → `VNGenerateImageFeaturePrintRequest`(전체 특징) + `VNDetectFaceLandmarksRequest`(얼굴) → `AnalyzedPhoto`
2. **결합 거리** = `alpha × visual + (1-alpha) × temporal + facePenalty`
   - visual: FeaturePrint 거리
   - temporal: 촬영 시간차 가우시안 패널티 (`GroupingParams`: alpha 0.7, timeSigma 10분, maxTimePenalty 0.9)
   - facePenalty: 둘 다 인물 사진이면 얼굴 크기/위치 유사도 기반 최대 0.1 가산
3. **그리디 클러스터링**: 평균 결합 거리 < threshold **AND 완전 링크 제약**(그룹 내 모든 사진과 거리 < threshold) 만족 시 그룹에 편입
4. 2장 이상만 그룹 성립. 미편입 사진은 `isExtra: true`인 Extra 그룹으로 묶임
5. 결과: `SimilarPhotoGroup { photos, averageDistance, confidence, isExtra }`

그룹핑 완료 후 각 그룹 첫 사진을 high-priority prefetch (완료까지 await) 후에야 `.success`.

## 3단계: 저장 (`PhotoManager`)

- `savePhotos(photos:onProgress:)`: 권한(.addOnly) 요청 → "Bracket" 앨범 조회/생성 → 사진별로 `displayURL` 다운로드(실패 시 원본 URL fallback) → PHAsset 생성
- 진행률 콜백으로 `savingProgress` 갱신 → `ProgressWithTextView` 표시
- 저장 완료 후 `imagePrefetchManager.clearAllCache()` (메모리+디스크 전부)

## 이미지 캐싱/프리페치 (`ImagePrefetchManager`)

Kingfisher 기반, 직렬 큐에서 우선순위 처리:

| 우선순위 | 대상 | 간격 |
|---|---|---|
| High | 그룹 첫 사진 | 0s |
| Medium | 상세 보기 좌우 인접 사진 | 0.3s |
| Low | 초기 목록 30장 | 0.2s |

- 캐시 한도: 메모리 150MB/50장, 디스크 2GB, 세션 내 무기한
- 다운샘플링 1200×1200, display 실패 시 원본 URL로 큐 재삽입
- 그룹핑 화면 진입 시 `cancelSelectionPartPrefetch()`로 Low/Medium 큐 폐기

## 표시 컴포넌트

- `CachedGridCellImageView` / `ProgressiveDisplayImageView` (Kingfisher 래퍼, 썸네일→디스플레이 점진 표시)
- `GroupedPhotosSkeletonView` / `PhotoSelectionSkeletonView` (로딩 스켈레톤)
- `ZoomableGestureView` (핀치 줌)

## 에러

`ArchiveError` ← `VisionError` / `PhotoError` / `CCAPIError` 변환. `ViewState`의 failure로 표시.
