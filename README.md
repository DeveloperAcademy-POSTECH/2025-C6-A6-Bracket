<div align="center">

![Bracket Banner](https://github.com/user-attachments/assets/4bca99a7-5b37-4c6d-a059-212e9458a096)


</div>

---

## 📋 Overview

Bracket은 DSLR/미러리스 카메라 사용자를 위한 촬영 보조 앱입니다.

---

## ✨ 주요 기능

<div align="center">
  
  <!-- TODO: GIF로 이미지 변경 -->
  
### 📸 Tri-Shot

| ![Tri-Shot](https://github.com/user-attachments/assets/700a89d7-90f5-4c97-b0c6-472685aee9bd) | ![Preset](https://github.com/user-attachments/assets/fc50ce99-efb0-4c73-b0bf-e941b5583c29) | ![Camera UI](https://github.com/user-attachments/assets/ba00c874-c9cb-4acc-829f-5e6356cd9313) |
|:---:|:---:|:---:|
| **Tri-Shot 메인** | **프리셋 제작** | **카메라 UI** |

</div>

미리 저장한 3가지 프리셋(촬영 모드, 조리개, 셔터, ISO, 색온도, 틴트, 픽처스타일)을 셔터를 누를때마다 적용합니다.

**기술 구현**
- [ ] **개발자 작성**: 프리셋 순환 로직 및 상태 관리 방식
- [ ] **개발자 작성**: Canon Camera Control API 호출 구조
- [ ] **개발자 작성**: 비동기 처리 및 동기화 메커니즘

```swift
// 핵심 코드 스니펫 (개발자 작성)
// 예: PresetCycleManager, CameraService 등
```
---

<div align="center">

### 🤖 아카이빙

  <!-- TODO: GIF로 이미지 변경 -->
  
![Archiving](https://github.com/user-attachments/assets/4d84fab9-a794-4ebb-9599-5edc4628831b)

</div>

Vision Framework를 활용한 이미지 유사도 분석과 시간대에 따른 가중치 계산으로 비슷한 사진끼리 그룹화합니다.

**기술 구현**
- [ ] **개발자 작성**: Vision Framework 특징점 추출 방식
- [ ] **개발자 작성**: 유사도 계산 알고리즘 (거리 측정 방법 등)
- [ ] **개발자 작성**: 그룹화 기준 및 성능 최적화 전략

```swift
// 핵심 코드 스니펫 (개발자 작성)
// 예: ArchivingService, VisionAnalyzer 등
```

**성능 지표**
- [ ] **개발자 작성**: 이미지 분석 속도 (n장 기준 처리 시간)
- [ ] **개발자 작성**: 메모리 사용량 및 최적화 결과
- [ ] **개발자 작성**: 그룹화 정확도

---

## 🛠 기술 스택

<div align="center">

### Core Technologies

<img src="https://img.shields.io/badge/SwiftUI-0D96F6?style=for-the-badge&logo=swift&logoColor=white" alt="SwiftUI" />
<img src="https://img.shields.io/badge/Combine-FA7343?style=for-the-badge&logo=swift&logoColor=white" alt="Combine" />
<img src="https://img.shields.io/badge/MVVM-orange?style=for-the-badge" alt="MVVM" />

### Frameworks & APIs

<img src="https://img.shields.io/badge/Vision-blue?style=for-the-badge&logo=apple&logoColor=white" alt="Vision" />
<img src="https://img.shields.io/badge/Core_Bluetooth-007AFF?style=for-the-badge&logo=bluetooth&logoColor=white" alt="Core Bluetooth" />
<img src="https://img.shields.io/badge/Core_Data-FA7343?style=for-the-badge&logo=apple&logoColor=white" alt="Core Data" />

<img src="https://img.shields.io/badge/Canon_Camera_Control_API-CE0000?style=for-the-badge&logo=canon&logoColor=white" alt="Canon API" />
<img src="https://img.shields.io/badge/RESTful_API-009688?style=for-the-badge" alt="RESTful API" />
<img src="https://img.shields.io/badge/Digest_Auth-4CAF50?style=for-the-badge&logo=lock&logoColor=white" alt="Digest Auth" />

</div>

<br/>

| 기술 | 사용 목적 | 핵심 구현 |
|------|----------|----------|
| **SwiftUI** | 선언형 UI | [개발자 작성: MVVM 패턴, 상태 관리 방식 등] |
| **Combine** | 반응형 프로그래밍 | [개발자 작성: Publisher/Subscriber 활용 사례] |
| **Vision Framework** | 이미지 분석 | [개발자 작성: 특징점 추출, 유사도 계산 방법] |
| **Core Bluetooth** | 무선 통신 | [개발자 작성: WiFi 연결 및 데이터 전송 구현] |
| **Canon Camera Control API** | 카메라 제어 | [개발자 작성: HTTP 통신, Digest Auth 구현] |
| **Core Data** | 데이터 영속성 | [개발자 작성: 프리셋 저장, 사진 메타데이터 관리] |

---

## 🏗 아키텍처

### System Architecture

```
[개발자 작성: 아키텍처 다이어그램]
예시 구조:

┌─────────────────────────────────────────┐
│           View (SwiftUI)                │
│  - Tri-shot UI                          │
│  - Preset Management                    │
│  - Archiving UI                         │
└──────────────┬──────────────────────────┘
               │ @Published
               │ @StateObject
┌──────────────▼──────────────────────────┐
│         ViewModel (Combine)             │
│  - TrishotViewModel                     │
│  - PresetViewModel                      │
│  - ArchivingViewModel                   │
└──────────────┬──────────────────────────┘
               │ Protocol
               │ Dependency Injection
┌──────────────▼──────────────────────────┐
│     Repository (Protocol-oriented)      │
│  - CameraRepository                     │
│  - PresetRepository                     │
│  - PhotoRepository                      │
└─────┬────────────────────────┬──────────┘
      │                        │
┌─────▼────────┐      ┌────────▼──────────┐
│   Service    │      │   Core Data       │
│  - Camera    │      │  - Preset Entity  │
│  - Vision    │      │  - Photo Entity   │
│  - Bluetooth │      │                   │
└──────────────┘      └───────────────────┘
```

### 데이터 흐름

- [ ] **개발자 작성**: 주요 기능별 데이터 흐름 설명
- [ ] **개발자 작성**: 비동기 처리 및 에러 핸들링 전략

```
예시:
User Tap Shutter
       ↓
View.onTapGesture
       ↓
ViewModel.captureWithTrishotMode()
       ↓
CameraRepository.applyPreset()
       ↓
CameraService.sendCommand()
       ↓
Canon Camera (WiFi)
       ↓
ViewModel.@Published 업데이트
       ↓
View 자동 리렌더링
```

---

## 🚀 기술적 도전과 해결

### 1. [Challenge 제목 - 개발자 작성]

**문제 상황**
- [ ] **개발자 작성**: 구체적인 기술적 문제 설명
- [ ] **개발자 작성**: 왜 이 문제가 발생했는지
- [ ] **개발자 작성**: 기존 접근 방식의 한계

**해결 방법**
- [ ] **개발자 작성**: 채택한 솔루션 및 이유
- [ ] **개발자 작성**: 구현 세부사항

```swift
// 핵심 해결 코드 (개발자 작성)
```

**결과**
- [ ] **개발자 작성**: 측정 가능한 개선 결과 (성능, 안정성 등)

---

### 2. [Challenge 제목 - 개발자 작성]

**문제 상황**
- [ ] **개발자 작성**

**해결 방법**
- [ ] **개발자 작성**

```swift
// 핵심 해결 코드
```

**결과**
- [ ] **개발자 작성**

---

### 3. [Challenge 제목 - 개발자 작성]

**문제 상황**
- [ ] **개발자 작성**

**해결 방법**
- [ ] **개발자 작성**

```swift
// 핵심 해결 코드
```

**결과**
- [ ] **개발자 작성**

---

## 📊 성능 및 품질 지표

### 성능 측정

| 항목 | 측정값 | 측정 환경 |
|------|--------|----------|
| [개발자 작성] | [개발자 작성] | [개발자 작성] |
| 이미지 그룹화 속도 | [측정 필요] | 100장 기준 |
| 프리셋 전환 속도 | [측정 필요] | 연속 촬영 시 |
| 메모리 사용량 | [측정 필요] | 피크 시 |
| 배터리 소모 | [측정 필요] | 1시간 사용 기준 |

### 코드 품질

- [ ] **개발자 작성**: 테스트 커버리지
- [ ] **개발자 작성**: 주요 테스트 전략 (Unit Test, Integration Test 등)
- [ ] **개발자 작성**: 코드 리뷰 프로세스

---

## 👥 팀

<div align="center">
  
  <!-- TODO: 개인 이미지, 링크 변경 -->
  
| ![Sandeul](https://github.com/user-attachments/assets/7159c61b-af06-4281-84f6-d076b30682fc) | ![Hari](https://github.com/user-attachments/assets/7159c61b-af06-4281-84f6-d076b30682fc) | ![Ivy](https://github.com/user-attachments/assets/7159c61b-af06-4281-84f6-d076b30682fc) | ![Minbol](https://github.com/user-attachments/assets/7159c61b-af06-4281-84f6-d076b30682fc) | ![Rama](https://github.com/user-attachments/assets/7159c61b-af06-4281-84f6-d076b30682fc) | ![Soop](https://github.com/user-attachments/assets/7159c61b-af06-4281-84f6-d076b30682fc) |
|:---:|:---:|:---:|:---:|:---:|:---:|
| **양희준** | **윤하정** | **이현주** | **이보민** | **문형근** | **한수빈** |
| **Sandeul** | **Hari** | **Ivy** | **Minbol** | **Rama** | **Soop** |
| 🎯 PM | 🎨 Design | 📱 iOS | 📱 iOS | 📱 iOS | 📱 iOS |

**Apple Developer Academy @ POSTECH | Team A6 (HonestHouse)**

</div>
[![Notion](https://img.shields.io/badge/프로젝트_스토리-Notion-000000?style=flat-square&logo=notion&logoColor=white)](https://slime-shirt-140.notion.site/Bracket-2a202aff8b528063be0ff432c107e135)

---

## 📞 Contact

📧 **honesthouse2025@gmail.com**

[![Notion](https://img.shields.io/badge/프로젝트_기획_과정-Notion-000000?style=flat-square&logo=notion&logoColor=white)](https://slime-shirt-140.notion.site/Bracket-2a202aff8b528063be0ff432c107e135)

---

<div align="center">

*© 2025 Team A6 (HonestHouse). Apple Developer Academy @ POSTECH*

</div>
