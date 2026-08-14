# Bracket 프로젝트 문서

Canon 카메라 원격 제어 + Tri-shot 연속 촬영 + 유사 사진 그룹핑 iOS 앱.

## 문서 목록

### 제품/기획
- [PRD.md](PRD.md) — 제품 요구사항 정의서 (페르소나, 솔루션, AI 협업 가이드라인)

### 기술 문서
- [architecture.md](architecture.md) — 전체 아키텍처: 레이어링, DI, 내비게이션, 에러 처리, 상태 관리, 카메라 기종 대응
- [networking.md](networking.md) — CCAPI 통신: Digest 인증, NetworkManager, DTO 규칙, 스트리밍 계층, 503 회피 전략

### 기능별 문서 ([features/](features/))
- [camera-connection.md](features/camera-connection.md) — 카메라 연결/재연결, CameraType 판별
- [trishot.md](features/trishot.md) — Tri-shot 촬영: 이벤트 모니터링, 프리셋 순환 적용, 재시도 정책
- [preset.md](features/preset.md) — 프리셋 CRUD, CoreData 스키마, 휠 피커, 변경 전파
- [archive.md](features/archive.md) — 사진 로딩(점진적), Vision 유사도 그룹핑 알고리즘, 프리페치, 앨범 저장
- [live-view.md](features/live-view.md) — 라이브뷰 MJPEG 스트림, 프레임 파싱, 렌더 루프
- [main-settings.md](features/main-settings.md) — 메인/설정/스플래시, 공통 UI 컴포넌트, 로깅

### 작업 컨텍스트 ([context/](context/))
브랜치별 작업 요약. 파일명은 브랜치 이름의 특수문자를 `-`로 치환 (예: `feat/#27/download` → `feat-27-download.md`). PR 설명에 링크해 리뷰어가 맥락을 파악하도록 한다.

## 빠른 참조

```bash
# 빌드
xcodebuild -project HonestHouse/HonestHouse.xcodeproj -scheme HonestHouse \
  -destination 'generic/platform=iOS Simulator' build
```

- 지원 카메라: EOS R6 / R7 / R6 Mark II / R8 / R50 / R50 V
- 브랜치: `<type>/#<issue>/<topic>`, 커밋: `<type>: <설명>`, PR은 `dev` 대상
- 개발자 온보딩용 요약은 저장소 루트의 `CLAUDE.md` 참고
