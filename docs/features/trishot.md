# 기능: Tri-shot (프리셋 순환 연속 촬영)

앱의 핵심 기능. 사용자가 최대 3개의 프리셋 슬롯을 구성하고, 셔터를 누를 때마다 카메라 설정이 다음 프리셋으로 자동 전환된다.

## 화면 흐름

```
MainView (Trishot 세그먼트)
 └─ TrishotSettingView       프리셋 슬롯 3개 구성/활성화 토글
     ├─ TrishotSelectionView  슬롯(order)에 넣을 프리셋 선택
     └─ TrishotActivationView 실제 촬영 모드 (이벤트 모니터링 활성)
```

## 핵심 파일

| 파일 | 역할 |
|---|---|
| `Presentation/Trishot/ViewModel/TrishotSettingViewModel.swift` | 선택된 프리셋 3개 로드, PresetStateObserver 구독 |
| `Presentation/Trishot/ViewModel/TrishotSelectionViewModel.swift` | 특정 order 슬롯에 프리셋 배정 (중복 배정 감지: `isPresetOccupied`) |
| `Presentation/Trishot/ViewModel/TrishotActivationViewModel.swift` | 촬영 감지 → 프리셋 순환 적용의 핵심 로직 |
| `Presentation/Trishot/Component/SwipeToDeactivateButton.swift` | 스와이프로 비활성화 |
| `Service/CCAPI/EventMonitor/EventMonitorService.swift` | 촬영 이벤트 스트림 |
| `Presentation/Trishot/ViewModel/Error/TrishotError.swift` | CCAPI → Trishot 에러 번역 |

## 동작 원리 (TrishotActivationViewModel)

### 활성화
1. `activateTrishot()` → CoreData에서 `fetchActivatedPresets()` (isActivated == YES, order 순)
2. 첫 번째 프리셋 적용 (`applyPreset(at: 0)`)
3. `EventMonitorService.startMonitoring()` — CCAPI 이벤트 스트림 구독

### 촬영 감지 → 프리셋 순환
- 이벤트의 `addedcontents`(새 사진 생성)가 감지되면:
  `currentPresetIndex = (currentPresetIndex + 1) % activatedPresets.count` → 다음 프리셋 적용

### 프리셋 적용 순서 (`applyPreset`)
```
ignoreShootingMode(on)          ← 물리 다이얼 무시 모드
→ putShootingMode (av/tv/p)
→ putPictureStyle
→ (av면 aperture / tv면 shutterSpeed)
→ putISO → putExposureCompensation
→ putColorTemperature → putWbShift(blueAmber, magentaGreen)
→ ignoreShootingMode(off)       ← 에러 시에도 반드시 off (defer 성격)
```

### 에러/재시도 정책
- `cameraDisconnected`: 즉시 에러 표시, 중단
- `cameraBusy` (503): 2초 대기 후 재시도, 최대 3회
- 기타 에러: 실패 카운터 누적, **3회 연속 실패 시** `presetApplicationFailed` Alert
- EventMonitor 스트림 에러: `isMonitoring = false` + `TrishotError.fromCCAPI` 변환

### 연결 워치독
`EventMonitorService`는 2초간 데이터 미수신 시 `networkConnectionLost` 에러를 발생시켜 연결 끊김을 감지한다.

## 데이터 모델

- 슬롯 구성은 CoreData `SelectedPresetEntity` (order 0~2, isActivated, Preset 관계)로 영속화 — [preset.md](preset.md) 참고.
- 화면 간 상태 동기화는 `PresetStateObserver`를 통해 이뤄진다.
