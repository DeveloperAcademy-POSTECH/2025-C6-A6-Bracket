# 기능: 라이브뷰

카메라 라이브뷰 영상을 실시간 MJPEG 스트림으로 표시.

## 핵심 파일

| 파일 | 역할 |
|---|---|
| `Service/LiveViewService.swift` | 스트림 시작/중지, 라이브뷰 enable/disable |
| `Service/CCAPI/Stream/StreamService.swift` | 무한 스트림 공통 (URLSession delegate) |
| `Presentation/Live/ChunkedStreamParser.swift` | actor. JPEG 프레임 추출 |
| `Presentation/Live/LiveStreamViewModel.swift` | AsyncStream 렌더 루프, FPS 계산 |
| `Presentation/Live/LiveStreamView.swift` | 표시 뷰 |
| `Presentation/Live/Shared/` | `ParsedFrame`, `DataType`(image/info/event), `LiveViewInfo`(AF 프레임), `StreamType`, `StreamError` |

## 스트림 시작 절차 (`LiveViewService.startLiveView`)

1. `POST ver100/shooting/liveview` body `{liveviewsize: "medium", cameradisplay: "on"}` — 라이브뷰 활성화
   - Moya를 거치지 않고 URLSession 직접 사용, Digest 헤더는 `NetworkManager.getAuthorizationHeader`로 발급
2. 1초 대기 후 파서 리셋
3. `GET ver100/shooting/liveview/scroll` 무한 스트림 시작 (`StreamService.startStreaming`)
   - 이미 스트리밍 중이면 강제 정리 후 재시작 (0.5초 대기)

## 프레임 파싱

수신 청크를 `ChunkedStreamParser`(actor) 버퍼에 누적, JPEG SOI(`0xFF 0xD8`) ~ EOI(`0xFF 0xD9`) 구간을 잘라 `ParsedFrame(type: .image)` 생성.

(참고: `StreamService`의 CCAPI 프레임 포맷 `[FF 00][type][size 4B][payload][FF FF]` 파서도 LiveViewService에 있으나 현재 scroll 방식은 JPEG 마커 기반 파싱 사용)

## 렌더링 (`LiveStreamViewModel`)

- `AsyncStream<ParsedFrame>` + `bufferingNewest(1)` — 최신 프레임만 유지 (백프레셔)
- `onFrame` 콜백 → continuation.yield → 렌더 루프(`for await`)에서 `currentImage` 갱신
- `.info` 프레임에서 AF 프레임 좌표(`afFrames`) 갱신, FPS는 1초 간격 계산
- 뷰 생명주기: `observeViewLifecycle()`이 Task 취소 감지 시 `stopStreaming()` — 스트림 중지, 파서 리셋, `POST liveviewsize: "off"`로 카메라 라이브뷰 종료

## 종료 시 주의

`stopLiveView()`는 ①스트림 태스크 취소 ②DELETE 요청 ③파서 리셋 ④liveview off POST 순서. 화면 이탈 시 반드시 호출되어야 카메라가 라이브뷰 상태에서 빠져나온다 (아니면 이후 요청이 503 "Already started" 등으로 실패할 수 있음).
