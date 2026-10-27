# 기능: 메인 화면 / 설정 / 스플래시

## 메인 (`Presentation/Main/`)

- `MainView` + `MainViewModel`: 앱의 홈. `CustomSegmentedControl`로 **Trishot / Preset** 두 세그먼트 전환 (`MainViewSegmentType`).
  - Trishot 세그먼트 → `TrishotSettingView` 내장
  - Preset 세그먼트 → 프리셋 목록 (편집 모드, 리스트/그리드 전환, 즉시 적용)
  - 우상단 옵션 메뉴(`OptionsMenuView` + `getMenuItems()`): 프리셋 선택 모드 / 보기 방식 토글
  - 내비게이션: `.goToPresetEditor`, `.goToPhotoSelection`(아카이브 진입), `.goToSettings`
- 진입 시 카메라 미연결이면 `CameraConnectionManager.showConnectionSheet`로 연결 모달 표시.

## 설정 (`Presentation/Setting/`)

- `SettingView`: 설정 목록 (`SettingOption` enum 기반)
- `BracketTeamView`: 팀 소개
- `InfoTextView` / `SettingScrollTextView`: 개인정보 처리방침 등 텍스트 표시 (`SettingConstants`에 문구)
- `Core/Model/SupportEmail.swift`: 문의 메일 작성 (mailto)

## 스플래시 (`Presentation/Splash/`)

- `RootView`: `showSplash` 2.3초 후 `MainView`로 교체
- `SplashView`: Lottie 애니메이션 (`Resources/BracketLottie.json`)

## 공통 UI (`Presentation/Common/`)

| 컴포넌트 | 용도 |
|---|---|
| `CustomAlertView` + `CustomAlertConfig` + `AlertButtonBuilder` | 공통 Alert (AlertInfo 기반) |
| `ToastView` | 토스트 |
| `ProgressWithTextView` | 진행률 표시 (사진 저장 등) |
| `CustomNavigationBarModifier` | 커스텀 내비바 |
| `MaxLengthModifier` | 텍스트필드 길이 제한 |
| `ShadowView`, `VisualEffectBlurView`, `ZoomableGestureView` | 시각 효과/제스처 |
| `DefaultButtonStyle`, `NoHighlightButtonStyle`, `PresetDetailSettingButtonStyle` | 버튼 스타일 |

## 디자인 리소스

- 색상: `Resources/Color/Color.swift`, 간격: `Resources/Spacing/Spacing.swift`
- 폰트: Pretendard(본문), SFMono(수치) — `Font.swift`/`FontStyle.swift`
- 앱은 다크모드 고정 (`.preferredColorScheme(.dark)`)

## 로깅

`General/Logger.swift` + `Logger+Extension.swift` — 카테고리별 os.Logger 래퍼 (`.network`, `.connection`, `.trishot`, `.coreData`, `.prefetch`, `.viewModel`, `.eventMonitor` 등). print 대신 사용.
