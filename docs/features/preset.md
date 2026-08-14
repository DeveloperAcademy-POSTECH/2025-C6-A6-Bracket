# 기능: 프리셋 관리

카메라 촬영 설정 묶음(프리셋)의 생성/수정/삭제/적용. CoreData로 영속화.

## 도메인 모델 (`Core/Model/Preset.swift`)

```swift
struct Preset: Hashable, Identifiable {
    var id: UUID, name: String
    var pictureStyle: PictureStyleType   // auto/faithful/landscape 등
    var shootingMode: ShootingModeType   // av / tv / p
    var aperture, shutterSpeed, iso, exposureCompensation: String?  // nil = Auto
    var colorTemperature, tintBlueAmber, tintMagentaGreen: Int?
    var createdAt, updatedAt: Date
}
```
- 표시용 값은 `displayXxx` computed property (nil → "Auto"/"0").
- 동일성은 `id` 기준.

## CoreData 스키마 (`Core/CoreData/PresetModel.xcdatamodeld`)

- `PresetEntity` — 프리셋 본체. `toPreset()`으로 도메인 변환 (`PresetEntity+Extension.swift`). Int16 필드는 0 ↔ nil 매핑.
- `SelectedPresetEntity` — Tri-shot 슬롯. `order`(0~2), `isActivated`, `preset` 관계.
- `PersistenceController`: 싱글턴, `preview`(인메모리 + 샘플 5개) 제공. `automaticallyMergesChangesFromParent = true`.

## PresetManager (`Core/Managers/PresetManager.swift`)

| 메서드 | 설명 |
|---|---|
| `fetchAllPresets()` | 생성일 오름차순 전체 조회 |
| `fetchSelectedPresets()` | 슬롯 배정 프리셋 (order 순) |
| `fetchActivatedPresets()` | isActivated == YES 만 (Tri-shot 실행 대상) |
| `toggleSelectedPresetActivation(presetId:)` | 슬롯 활성화 토글 |
| `updateSelectedPresetAtOrder(order:presetId:)` | 슬롯(0~2)에 프리셋 배정, 없으면 생성 |
| `createPreset(_:)` | 생성. **슬롯이 3개 미만이면 자동으로 슬롯에 배정 + 활성화** |
| `updatePreset(_:)` / `deletePreset(by:)` | 수정/삭제. 삭제 시 관련 SelectedPresetEntity 먼저 삭제 |

에러는 `PresetManagerError` → `PresetError`로 번역되어 Alert 표시.

## 화면

| 화면 | 파일 | 설명 |
|---|---|---|
| 프리셋 목록 | `Presentation/Preset/View/PresetView.swift` + `MainViewModel` | Main의 Preset 세그먼트. 리스트/그리드 전환(`PresetViewMode`), 편집 모드(다중 선택 삭제), 탭 시 카메라에 즉시 적용(`setCurrentPreset`) |
| 프리셋 편집 | `Presentation/Preset/View/PresetDetailView.swift` + `PresetDetailViewModel` | 생성/수정 겸용 (`PresetDetailViewMode`: create/edit). 이름 미입력 시 저장 불가 |

## 설정값 입력 UI

`Presentation/Preset/Component/Picker/`
- **CircularWheel**: 원형 휠 피커 (`CircularWheelPickerView`, `CircularWheelManager/Calculator` — 각도 계산 유틸, `ExpandableButton/Wheel`). 조리개·셔터·ISO 등 선택.
- **LinearWheel**: 선형 휠 (`LinearWheelPicker(View)`). 색온도/틴트 등.
- 선택 가능한 값 목록 상수: `Presentation/Preset/Component/CameraConstants.swift`
- 설정 종류: `WheelSettingType`, 프리셋 항목 타입: `PresetSettingType`

## 변경 전파

프리셋 CRUD 후 `container.presetStateObserver.notifyPresetChanged()` 호출 → `MainViewModel`/`TrishotSettingViewModel`이 Combine 구독으로 자동 리로드. **CRUD 코드를 추가하면 반드시 notify를 호출할 것.**

## 카메라 즉시 적용 (`MainViewModel.setCurrentPreset`)

Tri-shot의 `applyPreset`과 동일한 시퀀스 (ignoreShootingMode on → 설정 PUT 나열 → off). 적용 성공 시 `currentlyAppliedPreset` 표시 상태 갱신.
