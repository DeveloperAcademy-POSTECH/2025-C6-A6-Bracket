# 네트워킹 (CCAPI)

Canon CCAPI(Camera Control API)와의 통신 전반. 폴더/파일명은 **CCAPI 공식 스펙 챕터 번호**를 그대로 따른다 (예: `4.9. Shooting Settings/10. ColorTemperature.swift`). 새 엔드포인트 추가 시 이 규칙 유지.

## Base URL 구성

`Core/Network/Foundation/BaseURLConstants.swift`

```
baseURL        = {scheme}://{cameraIP}:{port}/ccapi/
baseArchiveURL = {scheme}://{cameraIP}:{port}     (이미지 다운로드용)
```

- `cameraIP`/`scheme`/`port`는 mutable static — 카메라 연결 시 설정됨. (TODO: 동시성 안전성)
- 이미지 URL 뒤에 `?kind=thumbnail` / `?kind=display`를 붙여 해상도 선택 (`Photo.thumbnailURL/displayURL`).

## 요청 파이프라인 (REST)

```
Service (BaseService 상속)
  → Moya Target (BaseTargetType 준수, CCAPI 챕터별)
    → NetworkManager.request()  ← 401 재시도(최대 3회), 에러 매핑
      → MoyaProvider<MultiTarget> + DigestAuthPlugin
```

### NetworkManager (`Core/Network/DigestAuth/NetworkManager.swift`)
- 싱글턴. `configure(cameraIP:)`가 **모든 요청의 선행 조건** — SSL 신뢰 설정(DisabledTrustEvaluator), DigestAuthManager/Plugin, Alamofire Session 생성.
- `initializeAuthentication()`: 최초 401을 유도해 nonce 획득 (연결 절차의 일부).
- `request(_:)`: Canon Android 레퍼런스 구현과 동일한 while-loop 401 재시도 (최대 3회). 성공 시 2xx 검증 후 Response 반환.
- HTTP 상태 → `CCAPIError` 매핑. 503은 메시지 문자열 기준 세분화:
  - "Device busy" → `.deviceBusy`, "During shooting or recording" → `.deviceShooting`, "Live view not started" → `.liveViewNotStarted` 등
- `getAuthorizationHeader(method:url:body:)`: 스트리밍/URLSession 직접 요청에 Digest 헤더를 발급해주는 통로.

### Digest 인증 (`Core/Network/DigestAuth/`)
- `HTTPDigestAuth` / `DigestAuthManager`: nonce 관리, Authorization 헤더 계산.
- `DigestAuthPlugin` (Moya Plugin): 요청 전 헤더 주입, 401 응답 시 nonce 갱신.
- `SSLPinningDelegate`: 카메라 호스트에 대한 TLS 신뢰 예외.

### BaseService (`Service/CCAPI/BaseService.swift`)
공통 요청 헬퍼: `request(_:decoding:)` (JSON 디코딩), `request(_:)` (응답 무시), `requestData`, `requestString`. 디코딩 실패는 `CCAPIError.decodingFailed`.

## DTO 규칙 (`Core/Network/DTO/`)

- 네임스페이스: 빈 enum `ImageOperations` / `ShootingControl` / `ShootingSettings` / `CameraStatus` / `CameraInformation` (`API+Namespace.swift`)
- Request/Response는 챕터 폴더에 배치, Response는 `ResponseConvertible.toEntity()`로 도메인 모델(`Core/Model/`) 변환.

## 스트리밍 계층

REST와 별도로 URLSession delegate 기반 스트리밍 스택이 있다.

```
BaseStreamService  ← 인증 헤더/SSL/세션 설정 공통 (timeout ∞)
 ├─ StreamService          ← 무한 스트림 (시작/중지, DELETE로 종료 통지)
 │    ├─ LiveViewService       (GET ver100/shooting/liveview/scroll)
 │    └─ EventMonitorService   (GET {ver}/event/monitoring)
 └─ StreamDownloadService  ← 유한 chunked 응답 점진 파싱 (contents 목록)
```

### 프레임 바이너리 포맷 (LiveView / EventMonitor 공통)
```
[0xFF 0x00] [DataType 1byte] [DataSize 4bytes BE] [payload] [0xFF 0xFF]
```
- LiveView: `ChunkedStreamParser`(actor)가 JPEG SOI(0xFFD8)~EOI(0xFFD9) 추출
- EventMonitor: `EventMonitorParser`(actor)가 DataType 0x02(Event JSON)를 디코딩 → `CameraStatus.EventMonitorResponse`
- EventMonitorService는 2초간 데이터 미수신 시 연결 끊김으로 판단하는 워치독 타이머 보유.

### StreamDownloadService
- `getContentList`의 `kind=chunked` 응답을 스트리밍하며 `onProgress`로 부분 결과를 계속 전달 → 수천 장 사진 목록의 점진적 로딩 구현.

## 503 회피 튜닝 (실측 기반)

카메라가 동시 요청에 취약해 여러 곳에 스로틀이 들어가 있다:
- ContentInfo 배치: 동시 5개 + 배치 간 0.1초 (`PhotoSelectionViewModel`)
- 프리페치 간격: high 0s / medium 0.3s / low 0.2s (`ImagePrefetchManager`)
- 초기 프리페치는 사진 20장 도착 후 시작, 30장 한정

## Wi-Fi 연결 확인

`WiFiMonitorManager`: NWConnection TCP 연결 시도(2초 타임아웃)로 카메라 도달 가능성만 확인.
