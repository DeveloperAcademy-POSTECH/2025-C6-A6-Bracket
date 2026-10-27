# CCAPI 사용 방식 점검 및 개선 제안

Bracket의 카메라 연결, 사진 불러오기, CCAPI 사용 방식을 정리하고, 어디를 고치면 좋을지 우선순위별로 모았습니다.
비교 대상은 두 가지입니다.

- **Canon Camera Connect** (캐논 공식 앱, Android): 앱을 정적 분석한 결과를 썼습니다.
- **canonctl**: 그 분석을 바탕으로 만든 Python 클라이언트입니다. CCAPI, PTP/IP, BLE를 모두 지원합니다.

파일 경로는 `HonestHouse/HonestHouse/Sources/` 기준입니다. 줄 번호는 `dev` 브랜치(2026-10) 기준입니다.

---

## 1. 한눈에 비교

| 항목 | Bracket (CCAPI) | Camera Connect (PTP/IP) | canonctl CCAPI 백엔드 |
|---|---|---|---|
| 카메라 찾기/연결 | 카메라 화면의 URL을 사용자가 직접 입력 | BLE로 페어링 → BLE로 카메라 AP를 켜고 SSID/비밀번호/IP 수신 → Wi-Fi 접속 → PTP/IP | IP 입력 |
| 기기 식별/재연결 | 없음 (IP는 저장 안 함, `CameraType`만 UserDefaults에 저장) | 앱 GUID를 카메라가 기억해서 다음부터 확인 없이 연결 | — |
| 연결 유지 확인 | 화면 이동 전 TCP 접속 확인(2초), 이벤트 스트림 2초 무응답 감지 | 5초마다 keep-alive 명령(`0x902F`) | — |
| 기종/버전 분기 | `CameraType`에 기종별 버전 하드코딩 (`Type/CameraType.swift`) | `GetDeviceInfo`의 지원 명령 목록으로 분기 | `GET /ccapi`로 지원 API를 받아 가장 높은 버전 자동 선택 |
| 새 사진 감지 | `event/monitoring` chunked 스트림의 `addedcontents` (Tri-shot에서만 사용) | 이벤트 채널 푸시(`0xC101`) → `GetEvent`의 ObjectAdded | — |
| 사진 목록 | 첫 번째 저장소/폴더만, JPEG만, `kind=chunked` | 전체 저장소 핸들 순회 | 전체 저장소/폴더, 페이지 순회 |
| 저장 화질 | `?kind=display`(축소본) 우선, 실패 시 원본 | 원본을 분할 다운로드(`GetPartialObject`) | 원본/썸네일/display 선택 |
| 라이브뷰 | `ver100/.../liveview/scroll`, JPEG 마커 스캔 | `0x9153` 레코드 파싱 (JPEG + AF·히스토그램 등 메타) | `liveview/flip` 반복 |
| 셔터 | 없음 (사용자가 카메라 셔터를 직접 누름) | 원격 셔터 (`0x9128/0x9129`), BLE 셔터 | `shooting/control/shutterbutton` |
| 인증/보안 | Digest 인증. 모든 호스트의 TLS 검증 해제 | 카메라 화면 승인 + GUID | Digest 인증 |

**핵심 차이**
1. Camera Connect는 사용자가 IP를 입력할 필요가 없습니다. BLE로 카메라를 찾고 Wi-Fi 정보까지 받아 옵니다.
2. Bracket은 기종별 API 버전을 코드에 고정해 두어서, 새 기종이 나올 때마다 코드를 고쳐야 합니다.
3. Bracket은 셔터를 직접 제어하지 않습니다. 그래서 Tri-shot이 "사용자 촬영 → 이벤트 감지 → 다음 프리셋 적용"의 수동 사이클입니다.

---

## 2. 바로 고쳐야 할 버그 (P0)

| # | 문제 | 위치 | 영향 / 수정 방향 |
|---|---|---|---|
| 1 | `fetchAllImages()`가 `processedUrls`를 비우지 않음 | `Presentation/Archive/ViewModel/PhotoSelectionViewModel.swift:34, 141, 271-277` | 아카이브를 다시 불러오면 이미 본 URL이 전부 걸러져 사진이 안 보임. 시작 시 `processedUrls.removeAll()` |
| 2 | 확장자 `jpeg`만 JPEG로 인식 | `Core/Model/Photo.swift:47-57` | Canon 파일은 `.JPG` → 소문자 `jpg` → `.unknown`. `case "jpg", "jpeg"` |
| 3 | 날짜 정보 없는 사진은 그리드에서 빠짐 | `PhotoSelectionViewModel.swift:229` | `contentinfo` 디코딩이 실패하면 사진이 사라짐. 날짜 없음 섹션으로 보내거나 파일명/`lastmodifieddate`로 대체 |
| 4 | 활성 프리셋이 0개면 0으로 나누기 | `Presentation/Trishot/ViewModel/TrishotActivationViewModel.swift:114` | 크래시. `guard !activatedPresets.isEmpty` |
| 5 | 이벤트 파서가 멈출 수 있음 | `Service/CCAPI/EventMonitor/EventMonitorParser.swift:49-58` | 버퍼가 `0xFF`로 시작하고 다음 바이트가 `0x00`이 아니면 `removeFirst(0)` → 영원히 진행 못 하고 버퍼만 증가. 첫 바이트를 버리고 다음 `0xFF 0x00`을 찾도록 |
| 6 | 라이브뷰 시작이 끝나기 전에 화면을 닫으면 카메라 라이브뷰가 계속 켜져 있음 | `Presentation/Live/LiveStreamViewModel.swift:76, 88` | `isStreaming`이 아직 false라 stop이 바로 return. "시작 중" 상태를 따로 두고 취소 처리 |

---

## 3. 연결 안정성 (P1)

1. **API 버전 자동 발견.** 연결 직후 `GET /ccapi` 한 번으로 카메라가 지원하는 경로 목록을 받습니다.
   - 기능마다 가장 높은 버전을 고르면 `CameraType`의 버전 표(`Type/CameraType.swift:57-102`)가 필요 없어집니다.
   - 그러면 목록에 없는 기종(R5, R100, R1 등)도 동작합니다.
   - 지금은 `CameraType(rawValue:)`가 nil이면 사진 불러오기가 `photoLoadingFailed`로 끝납니다.
   - canonctl의 `CcapiClient.apis()`가 이 방식입니다.
2. **마지막 연결 정보 저장과 자동 재연결.** IP/스킴/포트를 저장해 두었다가, 앱을 다시 실행하면 조용히 `deviceinformation`을 호출해 연결 상태를 복원합니다.
   - 지금은 재실행하면 제품명은 보이는데 base URL은 비어 있습니다.
3. **실제 연결 상태 반영.** 연결 끊김을 감지하면 Alert만 띄우고 `connectionState`는 `.connected`로 남습니다 (`Core/Managers/CameraConnectionManager.swift`).
   - `NWPathMonitor`로 Wi-Fi 변화를 감지하고 상태를 `.disconnected`로 바꿔 주세요.
4. **에러 분류 정리.**
   - 타임아웃이 "연결 끊김"과 "busy" 양쪽에 걸려서 항상 연결 끊김으로 처리됩니다.
   - `handleMoyaError`는 `URLError`만 매칭하는데, Moya가 `AFError`로 감싸 보낼 가능성이 있습니다(실기 확인 필요).
5. **503 Device busy 재시도를 공통화.** 지금은 Tri-shot에만 재시도(2초 × 3회)가 있고, 프리셋 즉시 적용이나 상세 화면 적용에는 없습니다.
   - `NetworkManager.request`에서 busy 계열 503만 지수 백오프(0.2 → 0.4 → 0.8초)로 재시도하면 모든 화면이 같은 정책을 갖습니다.
6. **keep-alive.** Camera Connect는 Wi-Fi 연결 중 5초마다 가벼운 명령을 보내서 끊김을 빨리 감지하고, 카메라의 자동 절전도 막습니다.
   - CCAPI에서는 이벤트 모니터를 상시 연결해 두거나, `deviceinformation`을 주기적으로 호출하는 방식으로 같은 효과를 낼 수 있습니다.

## 4. 사진 불러오기 (P1)

1. **원본 저장 옵션.** 지금은 `?kind=display` 축소본을 먼저 저장합니다 (`Core/Managers/PhotoManager.swift:30-38`).
   - 설정에서 "원본 저장"을 고를 수 있게 하고, 큰 파일은 진행률을 표시하면 좋겠습니다.
2. **이미지 요청에도 인증·인증서 처리.**
   - `ImageLoader`는 `URLSession.shared`를 씁니다 (`Core/Network/ImageLoader.swift:19, 38`). Kingfisher 다운로드도 Digest 헤더가 없고 자체 서명 인증서를 처리하지 않습니다.
   - 그래서 HTTPS(443, 계정 인증)를 켜면 썸네일과 저장이 실패합니다.
   - Kingfisher `requestModifier`로 Authorization 헤더를 붙이고, 인증서 처리는 공통 delegate를 쓰세요.
3. **모든 저장소·폴더 순회.** 지금은 첫 번째 저장소의 첫 번째 폴더만 봅니다.
   - 카드가 두 장이거나 폴더가 `101CANON`으로 넘어가면 사진이 빠집니다.
4. **RAW(CR3) 지원.** 목록을 `type=jpeg`로만 요청합니다.
   - RAW+JPEG로 촬영하는 사용자를 위해 같은 이름끼리 묶어 보여 주는 옵션을 고려해 보세요.
5. **촬영 중 실시간 반영.** Tri-shot 중에 받는 `addedcontents`를 아카이브에 바로 넣으면, 촬영이 끝나자마자 목록을 다시 불러오지 않고도 그룹핑을 시작할 수 있습니다.
6. **chunked 목록 파싱 보강.**
   - `StreamDownloadDelegate`가 청크마다 UTF-8 디코딩을 해서, 멀티바이트 문자가 청크 경계에 걸리면 그 청크를 버립니다. `Data`로 모았다가 JSON 경계에서 디코딩하세요.
   - 에러가 나면 URLSession이 invalidate되지 않습니다.

## 5. 보안·코드 품질 (P2)

- **TLS 처리 통합.** 인증서를 무조건 신뢰하는 코드가 세 곳에 있습니다 (`SSLPinningDelegate`, `BaseStreamService.handleSSLChallenge`, `LiveViewService.SSLTrustDelegate`). 일부는 호스트 제한도 없습니다.
  - 카메라 IP로 한정하세요.
  - 처음 받은 인증서 지문을 저장해서 다음부터 비교하면(TOFU) 실질적인 피닝이 됩니다.
- **동시성.**
  - `BaseURLConstants` 정적 변수(TODO 있음), Digest `nonceCount`, `EventMonitorService.lastDataReceivedAt`을 actor나 lock으로 보호하세요.
  - 여러 장을 빠르게 촬영하면 `handleEvent`마다 프리셋 적용 Task가 겹쳐서 실행됩니다. 직렬 큐로 바꾸세요.
- **Digest 헤더 파서.** `,`로 split해서 `qop="auth,auth-int"`처럼 따옴표 안의 쉼표를 깨뜨립니다.
- **로그.** `WWW-Authenticate`(nonce 포함)와 전체 URL이 `%{public}`으로 남고, debug 로그가 release 빌드에도 나옵니다.
- **Info.plist.** `NSLocalNetworkUsageDescription`이 없습니다. 로컬 네트워크 권한 안내 문구를 직접 지정하세요.
- **사용하지 않는 코드.** `LiveViewService.handleReceivedData/parseFrame`, 주석 처리된 로그 블록, 촬영 모드/모드 다이얼 서비스 메서드 중복.

---

## 6. 추가 제안 (Camera Connect 분석 기반)

### 6-1. BLE로 "IP 입력 없는 연결"
Camera Connect가 쓰는 BLE 흐름은 이미 분석되어 있습니다 (canonctl `transports/ble.py`, `docs/protocol.md`). 요약하면 다음과 같습니다.

1. 스캔: 서비스 UUID `00010000-0000-1000-0000-d8492fffa821`, 제조사 ID `0x01A9`
2. 페어링: `00010006`에 `01`+이름을 쓰고 indication `02`를 기다림 → `0001000a`에 `03`+앱 UUID, `04`+이름, `05 02`
3. Wi-Fi 켜기: `00020002`에 `01` → notify로 카메라 IP 수신, `00020004`/`00020006`에서 SSID/비밀번호 읽기
4. iOS에서는 `NEHotspotConfiguration`으로 그 SSID에 자동 접속하고, 받은 IP로 CCAPI에 연결

이렇게 하면 IP 입력 화면이 없어지고, 주석 처리되어 있는 Bluetooth 연결 가이드(`BluetoothConnectionGuideView.swift`)를 살릴 수 있습니다.
iOS 앱에서는 CoreBluetooth로 구현합니다. 다만 BLE 쓰기는 정적 분석으로 확인한 값이라 실기 확인이 필요합니다.

### 6-2. 앱에서 셔터 → 완전 자동 Tri-shot
CCAPI `POST {ver}/shooting/control/shutterbutton` (`{"af": true}`)을 쓰면 "프리셋 1 적용 → 촬영 → 프리셋 2 적용 → 촬영 → …"을 버튼 하나로 끝낼 수 있습니다.

- 사용자가 프리셋 사이에 카메라를 만지지 않으므로 구도가 흔들리지 않습니다. 비교 사진의 품질이 올라가고, 유사 사진 그룹핑도 더 정확해집니다.
- 셔터 반누름 유지는 `shutterbutton/manual` (`half_press`/`full_press`/`release`)로 할 수 있습니다.
- BLE 셔터(`00030030`에 `00 01` → `00 02`)는 Wi-Fi가 불안정할 때 백업으로 쓸 수 있습니다.

### 6-3. 라이브뷰 개선
- `scrolldetail`을 쓰면 JPEG와 함께 AF 프레임, 히스토그램 정보가 옵니다. 프리셋별 노출 차이를 화면에서 바로 비교할 수 있습니다.
- `ScrollType.scrollDetail`은 이미 정의되어 있으니 파서만 구현하면 됩니다.
- 프리셋을 바꿀 때 라이브뷰를 켜 두면 적용 결과를 즉시 미리 볼 수 있습니다.

### 6-4. 프리셋 적용 속도
지금은 설정 하나마다 PUT을 순차로 보내고, 단일 설정 변경도 ignore-mode on → PUT → off로 3번 요청합니다.

- 현재 카메라 값을 이벤트 모니터(PropValueChanged 성격의 응답)나 GET으로 알고 있으면, **바뀌는 값만** PUT하면 됩니다.
- ignore-mode on/off는 Tri-shot 세션 시작과 끝에 한 번씩만 보내면 됩니다.
- 셔터 간격이 짧아지고 503 busy도 줄어듭니다.

### 6-5. CCAPI 미지원 상황 대비 (장기)
CCAPI는 카메라에서 기능을 활성화해야 하고(캐논 개발자 등록 필요), 지원 기종도 제한적입니다.
Camera Connect가 쓰는 PTP/IP는 카메라 설정 없이 동작하고, 셔터·라이브뷰·다운로드를 모두 지원합니다.

- 서비스 계층을 "카메라 전송 계층" 프로토콜 뒤로 숨겨 두면, 나중에 PTP/IP 백엔드를 추가할 수 있습니다. canonctl의 `Camera` 인터페이스(`shoot` / `liveview_frames` / `list_media` / `download`)가 참고 구조입니다.
- PTP/IP 쪽 연결 순서와 명령 값은 canonctl `docs/protocol.md`에 정리되어 있습니다.

---

## 7. 추천 진행 순서

1. P0 버그 6건: 작은 수정이라 한 PR로 묶을 수 있음
2. `/ccapi` 버전 자동 발견 + 마지막 연결 저장/자동 재연결
3. 앱 내 셔터로 Tri-shot 자동화 (6-2): 사용자 체감이 가장 큼
4. 원본 저장 + 이미지 요청 인증 처리 (HTTPS 지원의 전제)
5. BLE 연결 (6-1): 실기 검증이 필요한 탐색 작업
