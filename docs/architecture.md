# 아키텍처 개요

> Bracket (프로젝트명: HonestHouse) — Canon CCAPI 기반 원격 촬영 iOS 앱
> iOS 18+, Swift 5, SwiftUI, 다크모드 전용

## 전체 구조

```
View (SwiftUI)
  └─ ViewModel (@Observable, MVVM)
       └─ DIContainer
            ├─ Services (CCAPI 통신 비즈니스 로직)
            │    └─ NetworkManager (Moya + Digest Auth)
            ├─ Managers (기기 측 로직: Vision, Photos, CoreData, 캐시)
            ├─ NavigationRouter (커스텀 라우팅)
            └─ PresetStateObserver (프리셋 변경 브로드캐스트)
```

소스 루트: `HonestHouse/HonestHouse/Sources/`

| 디렉토리 | 역할 |
|---|---|
| `App/` | 앱 진입점 (`HonestHouseApp`) |
| `Core/Network/` | CCAPI Target/DTO, Digest 인증, NetworkManager |
| `Core/Managers/` | VisionManager, PhotoManager, PresetManager, ImagePrefetchManager, CameraConnectionManager, WiFiMonitorManager |
| `Core/Model/` | 도메인 모델 (CCAPI 챕터 번호 폴더 + Photo/Preset 등) |
| `Core/CoreData/` | PersistenceController, PresetEntity 변환 |
| `Service/` | CCAPI Service 레이어 (BaseService / 스트리밍 서비스) |
| `Presentation/` | 기능별 View + ViewModel |
| `General/` | DIContainer, Navigation, 에러 처리 공통, Logger |
| `Type/` | CameraType, VersionType |
| `Resources/` | 색상, 폰트(Pretendard/SFMono), 이미지 에셋, Lottie |

## 앱 진입 흐름

`HonestHouseApp` (`Sources/App/HonestHouseApp.swift`)
1. `PersistenceController.shared`로 CoreData 스택 생성
2. `DIContainer(services: Services(), managers: Managers(viewContext:))`를 `@StateObject`로 생성 → `.environmentObject` 주입
3. `CameraConnectionManager`도 별도 `@StateObject`/`@EnvironmentObject`로 주입 (앱 전역 연결 상태의 단일 진실 공급원)
4. `RootView` → `SplashView`(2.3초, Lottie) → `MainView`

## 의존성 주입 (DIContainer)

`General/DIContainer.swift`

```swift
class DIContainer: ObservableObject {
    var services: ServiceType          // CCAPI 서비스 묶음
    var managers: ManagersType         // 기기 측 매니저 묶음
    var navigationRouter: NavigationRoutable & ObservableObjectSettable
    var presetStateObserver: PresetStateObserver
}
```

- 모든 Service/Manager는 **프로토콜(`XxxServiceType`/`XxxManagerType`) + 실구현 + Stub** 3종 세트.
- `DIContainer.stub`은 전부 Stub으로 구성 → SwiftUI Preview용.
- 새 Service/Manager 추가 시: 프로토콜 정의 → 실구현 → Stub → `Services`/`Managers` 및 Stub 컨테이너에 등록.

### Services (`Service/Services.swift`)
- `shootingControlService` — 촬영 제어 (ignoreShootingMode)
- `shootingSettingsService` — 촬영 설정 GET/PUT (Av/Tv/ISO/WB/색온도/픽쳐스타일 등)
- `imageOperationsService` — 스토리지/디렉토리/컨텐츠 목록·정보 조회
- `liveViewService` — 라이브뷰 MJPEG 스트림
- `eventMonitorService` — 카메라 이벤트(촬영 감지) 스트림

### Managers (`Core/Managers/Managers.swift`)
- `visionManager` — Vision 유사도 분석/그룹핑
- `photoManager` — Photos 앨범("Bracket") 저장
- `imagePrefetchManager` — Kingfisher 기반 우선순위 프리페치
- `presetManager` — CoreData 프리셋 CRUD

## 내비게이션

`General/Navigation/`
- `NavigationRouter`: `destinations: [NavigationDestination]` 스택을 push/pop/popToRoot로 조작. `ObservableObjectSettable`을 통해 DIContainer의 `objectWillChange`에 연결.
- `NavigationDestination` (enum): `trishotSelection(order:)`, `trishotActivation`, `presetEditor(mode, preset?)`, `photoSelection`, `groupedPhotos([Photo])`, `settings`
- `NavigationRoutingView`: destination → 실제 View 매핑. **새 화면 추가 시 NavigationDestination 케이스 + NavigationRoutingView 분기 추가** (임의 NavigationLink 사용 금지).

## 상태 관리 규칙

- ViewModel은 `@Observable` (Observation 프레임워크) 사용. UI 접근이 필요한 것은 `@MainActor`.
- 전역 공유 상태만 `ObservableObject` + `@EnvironmentObject` (`DIContainer`, `CameraConnectionManager`).
- 프리셋 변경 전파: `PresetStateObserver.notifyPresetChanged()` → 구독 중인 ViewModel(`MainViewModel`, `TrishotSettingViewModel`)이 `loadPresets()` 재호출.
- 비동기 상태는 제네릭 `ViewState<Success, Failure>` (idle/loading/success/failure)로 표현.

## 에러 처리 계층

```
CCAPIError (네트워크 저수준, HTTP/503 메시지 매핑)
   ↓ fromCCAPI() 변환
기능별 에러 enum: ConnectionError / PresetError / TrishotError / ArchiveError
   ↓ AlertPresentable 프로토콜
AlertInfo → CustomAlertView로 사용자 노출
```

- Manager 계층 에러: `VisionError`, `PhotoError`, `PresetManagerError` → 역시 기능별 에러로 변환.
- CCAPI 503 응답은 메시지 문자열("Device busy", "During shooting or recording" 등)로 세분화되어 `CCAPIError` 케이스로 매핑됨 (`NetworkManager.parse503Error`).

## 카메라 기종 대응 (CameraType)

`Type/CameraType.swift` — 지원 기종: EOS R6, R7, R6 Mark II, R8, R50, R50 V

- 연결 시 productName으로 판별 → **UserDefaults**(`connectedCameraType`)에 저장, `CameraType.current`로 전역 접근.
- 기종별 차이를 프로퍼티로 캡슐화:
  - `hasShootingModeDial`: R50V만 false (다이얼 없는 기종은 shootingmode 엔드포인트 상이)
  - `imageOperationsVersion`: R6/R7=ver110, R6II/R8=ver120, R50=ver130, R50V=ver140
  - `shootingSettingsVersion(for:)`: R50V의 shootingMode만 ver110, 나머지 전부 ver100
- 각 Moya Target의 `path`에서 `CameraType.current`를 읽어 버전별 경로를 조립.

## 외부 의존성 (SPM)

| 패키지 | 용도 |
|---|---|
| Moya 15 / Alamofire 5 | CCAPI REST 통신, Digest 인증 플러그인 |
| Kingfisher 8 | 이미지 캐시/다운샘플링/프리페치 |
| Lottie 4 | 스플래시 애니메이션 |

## 빌드

```bash
xcodebuild -project HonestHouse/HonestHouse.xcodeproj -scheme HonestHouse \
  -destination 'generic/platform=iOS Simulator' build
```

테스트 타겟 없음. 실기기 검증은 동일 네트워크의 실제 Canon 카메라 필요.
