# 기능: 카메라 연결

앱 전역에서 카메라 연결 상태를 관리하는 기능. 핵심은 `CameraConnectionManager`.

## 핵심 파일

| 파일 | 역할 |
|---|---|
| `Core/Managers/CameraConnectionManager.swift` | 연결 상태/시트 표시의 단일 진실 공급원 (`@MainActor`, `ObservableObject`, `BaseService` 상속) |
| `Presentation/CameraConnection/CameraConnectionView.swift` | 연결 모달 루트 |
| `Presentation/CameraConnection/IPConnectionGuideView.swift` | IP 입력 및 연결 시도 |
| `Presentation/CameraConnection/BluetoothConnectionGuideView.swift` / `GuideStepView.swift` | 카메라 측 Wi-Fi 설정 가이드 (단계별 이미지) |
| `Presentation/CameraConnection/Shared/ConnectionState.swift` | disconnected / connecting / connected / failed(ConnectionError) |
| `Presentation/CameraConnection/Error/ConnectionError.swift` | CCAPIError → 사용자 친화 에러 번역 |

## 상태 모델

`CameraConnectionManager`의 `@Published` 프로퍼티:
- `connectionState: ConnectionState` — 연결 상태
- `showConnectionSheet: Bool` — 연결 모달 표시 여부 (매니저가 직접 관리)
- `showDisconnectionAlert: Bool` — 연결 끊김 Alert (중복 표시 가드 포함)
- `productName: String` — 연결된 카메라 이름

## 연결 절차 (`connectCamera(ipAddress:)`)

1. IP 유효성 검사 (빈 값이면 `.failed(.invalidIPAddress)`)
2. `NetworkManager.configure(cameraIP:)` — 세션/Digest 인증/SSL 설정
3. `initializeAuthentication()` — 401 유도로 nonce 획득
4. `getCameraInfo()` (CCAPI 4.3 Camera Fixed Information) → `productName` 획득
5. `CameraType(rawValue: productName)`을 **UserDefaults에 저장** (`CameraType.current`) — 이후 모든 API 버전 분기의 기준
6. 성공 시 `.connected`, 실패 시 `ConnectionError.from(error)`로 변환 후 `.failed`

## 연결 해제/재연결

- `disconnectCamera()`: 상태 초기화 + `CameraType.clearCurrent()`
- 스트리밍(이벤트 모니터 등) 중 연결 끊김 감지 → `showConnectionLostAlert()` → 사용자가 재연결 선택 시 `reconnectCamera()`가 연결 시트 재표시
- `checkConnection()`: `WiFiMonitorManager`로 TCP 도달 여부 확인 (2초 타임아웃)

## 주입 방식

`HonestHouseApp`에서 `@StateObject`로 생성해 `.environmentObject`로 주입. DIContainer와 별개로 전역에서 접근한다.
