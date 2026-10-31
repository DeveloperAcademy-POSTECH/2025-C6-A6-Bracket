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

0. (`IPConnectionGuideView`) 입력 파싱
   - 빈 값이거나 공백만 있으면 `http://192.168.1.2:8080`
   - 스킴이 없으면 `http://`를 붙임. http/https만 허용
   - 포트가 없으면 http는 8080, https는 443
   - 호스트는 IPv4 또는 점이 포함된 호스트명만 허용, 포트는 1~65535
   - 실패하면 `.failed(.invalidIPAddress)`. 성공하면 `BaseURLConstants`의 scheme/IP/port를 한 번에 설정
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

## 블루투스 연결 (실험)

Canon Camera Connect와 같은 BLE 프로토콜로 카메라를 찾고, 카메라 Wi-Fi를 켜서 자동 접속한다.
프로토콜 근거: Camera Connect 분석 문서 (`rea-cannon-camera-connect/docs/protocol.md`), 개선 제안은 [ccapi-improvements.md](../ccapi-improvements.md) 6-1.

| 파일 | 역할 |
|---|---|
| `Core/Bluetooth/CanonBLEProtocol.swift` | UUID·명령 바이트, 광고/Wi-Fi 응답 파서, 앱 UUID(`CameraIdentity`) |
| `Core/Bluetooth/BluetoothManager.swift` | CoreBluetooth 검색·연결·페어링·Wi-Fi 켜기·BLE 셔터 (async API) |
| `Core/Bluetooth/WiFiJoiner.swift` | `NEHotspotConfiguration`으로 카메라 Wi-Fi 접속, 포트 도달 확인 |
| `Presentation/CameraConnection/ViewModel/BluetoothConnectionViewModel.swift` | 검색 → 페어링 → Wi-Fi 켜기 → 접속 단계 관리 |
| `Core/PTPIP/*` | PTP/IP 전송·캐논 세션 (Camera Connect 방식) |
| `Presentation/PTPIPTest/*` | PTP/IP 실기 테스트 화면 (연결·촬영·라이브뷰·로그) |

흐름:
1. 서비스 UUID `00010000-…-d8492fffa821`로 검색. 광고의 기억된 기기 UUID가 0이면 첫 페어링
2. 첫 페어링: `00010006`에 `01`+이름 → 카메라 승인(`02`) → `0001000a`에 앱 UUID·이름·기기 종류 등록
3. `00020002`에 `01` → 카메라 IP 수신, SSID/비밀번호 읽기 → 자동 접속
4. 접속 후 선택
   - **CCAPI로 연결**: 8080 포트가 열려 있으면 기존 `connectCamera` 사용. 닫혀 있으면 `ccapiUnavailableOnBluetoothWiFi` 안내
   - **PTP/IP로 연결 (실험)**: 15740 포트로 Camera Connect와 같은 세션을 열어 테스트 화면에서 확인

앱 UUID는 처음 한 번 생성해 `UserDefaults`에 저장하고, BLE 등록(바이트 역순)과 PTP/IP GUID에 같은 값을 쓴다.
필요 설정: `NSBluetoothAlwaysUsageDescription`, `NSLocalNetworkUsageDescription`, Hotspot Configuration entitlement.
