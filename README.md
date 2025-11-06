# 2025-C6-A6-HonestHouse
<div align="center">
  <img src="assets/logo.png" alt="Bracket Logo" width="120"/>
  
  # Bracket
  
  ### 순간에 집중하세요
  
  *미러리스 카메라 사용자를 위한*
  *설정 자동화 & 사진 정리 iOS 앱*
  
  <br/>
  
  [![iOS](https://img.shields.io/badge/iOS-17.0+-000000?style=flat&logo=apple&logoColor=white)](https://www.apple.com/kr/ios)
  [![Swift](https://img.shields.io/badge/Swift-5.9-FA7343?style=flat&logo=swift&logoColor=white)](https://swift.org)
  [![SwiftUI](https://img.shields.io/badge/SwiftUI-blue?style=flat&logo=swift&logoColor=white)](https://developer.apple.com/xcode/swiftui/)
  [![Canon](https://img.shields.io/badge/Canon-Camera_API-red?style=flat)](https://developers.canon.com)
  
  [📱 데모 영상](#데모) • [✨ 주요 기능](#주요-기능) • [🛠 기술 스택](#기술-스택) • [👥 팀](#팀)
  
</div>

---

## 📖 프로젝트 소개

햇빛이 구름 사이로 새어나오는 순간, 사진가들은 셔터를 누릅니다.
화이트밸런스와 노출을 고민하고 카메라를 조작하면 그 순간은 다시 오지 않기 때문입니다.

**Bracket은 이 딜레마를 해결합니다.**

3가지 프리셋을 미리 저장해두면 셔터를 누를 때마다 설정이 자동으로 전환됩니다.
같은 순간을 여러 느낌으로 촬영하고, 나중에 선택할 수 있습니다.

<br/>

<div align="center">
  <img src="assets/demo.gif" alt="Bracket 데모" width="80%"/>
</div>

---

## ✨ 주요 기능

### 📸 Tri-Shot (자동 프리셋 순환)
미리 저장한 3가지 프리셋이 셔터를 누를 때마다 자동으로 전환됩니다.
다이얼 조작 없이 같은 장면을 다양한 느낌으로 촬영하세요.
```
셔터 1회 → 프리셋 A (밝게)
셔터 2회 → 프리셋 B (표준)  
셔터 3회 → 프리셋 C (어둡게)
셔터 4회 → 프리셋 A (반복)
```

### 🤖 AI 사진 그룹화
Apple Vision Framework를 활용하여 다음 정보를 분석합니다:
- 시각적 유사도 (구도, 피사체)
- 촬영 시간
- 위치 정보

비슷한 사진끼리 자동으로 묶어 각 그룹에서 베스트샷을 쉽게 선택할 수 있습니다.

### 📡 카메라 무선 제어
Canon 카메라를 블루투스로 연결하여:
- 원격 촬영
- 즉시 사진 전송
- 실시간 프리뷰

지원 카메라: EOS R 시리즈, EOS-1D X Mark III, PowerShot V10 등

---

## 🛠 기술 스택

### 프론트엔드
- **SwiftUI** - 선언형 UI 프레임워크
- **MVVM** - 관심사 분리를 위한 아키텍처 패턴

### 프레임워크
- **Vision** - AI 기반 이미지 분석
- **Core Location** - 위치 정보 수집
- **Core Bluetooth** - 카메라 무선 통신
- **CoreData** - 로컬 데이터 저장

### API
- **Canon Camera Control API** - 카메라 직접 제어
- **RESTful API** - 백엔드 통신
- **Digest Authentication** - 인증

---

## 🚀 시작하기

### 요구사항
- Xcode 15.0 이상
- iOS 17.0 이상
- 블루투스 지원 Canon 카메라

### 설치 방법

1. 저장소 클론
```bash
git clone https://github.com/your-team/bracket.git
cd bracket
```

2. Xcode에서 열기
```bash
open Bracket.xcodeproj
```

3. 빌드 및 실행
```
⌘ + R
```

### 지원 카메라
- EOS R1, R3, R5, R5 Mark II
- EOS R6, R6 Mark II
- EOS R7, R8, R50, R50V
- EOS-1D X Mark III
- PowerShot V10

---

## 🏗 프로젝트 구조
```
Bracket/
├── App/
│   ├── BracketApp.swift
│   └── ContentView.swift
├── Features/
│   ├── TriShot/              # Tri-Shot 기능
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Models/
│   ├── Gallery/              # 갤러리 & 그룹화
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Models/
│   └── Camera/               # 카메라 제어
│       ├── Views/
│       ├── ViewModels/
│       └── Models/
├── Services/
│   ├── CameraService/        # Canon API 통신
│   ├── VisionService/        # AI 이미지 분석
│   └── LocationService/      # 위치 정보
└── Resources/
    ├── Assets/
    └── Localizations/
```

### 아키텍처: MVVM
```
View ←→ ViewModel ←→ Model
         ↓
      Services
```

- **View**: SwiftUI로 구현된 UI 컴포넌트
- **ViewModel**: 비즈니스 로직 및 상태 관리
- **Model**: 데이터 모델
- **Services**: 외부 API 및 프레임워크 연동

---

## 📸 스크린샷

<div align="center">
  <img src="assets/screenshot1.png" width="30%" />
  <img src="assets/screenshot2.png" width="30%" />
  <img src="assets/screenshot3.png" width="30%" />
</div>

<div align="center">
  <sub>프리셋 설정 • Tri-Shot 촬영 • AI 그룹화</sub>
</div>

---

## 🎥 데모

[데모 영상 보기](https://youtu.be/your-video-link)

또는 직접 체험해보세요:
1. Canon 카메라를 블루투스로 연결
2. 3가지 프리셋 설정
3. 촬영 시작!

---

## 🎯 사용자 가치

순간을 놓치지 않는 것, 사진가에게 가장 중요한 일입니다.

화이트밸런스, ISO, 셔터스피드, 조리개, 틴트, 픽처스타일.
완벽한 순간을 담기 위한 설정들이지만,
이를 조정하는 사이 그 순간은 사라집니다.

**Bracket은 미러리스 카메라 사용자가 설정이 아닌 순간에 집중할 수 있도록 돕습니다.**

---

## 👥 팀

**오후 6팀 (Afternoon Team 6)** - Apple Developer Academy @ POSTECH

| 역할 | 이름 | GitHub |
|------|------|--------|
| 🎨 Design | Hari | [@hari](https://github.com/hari) |
| 📱 iOS | Ivy | [@ivy](https://github.com/ivy) |
| 📱 iOS | Minbol | [@minbol](https://github.com/minbol) |
| 📱 iOS | Rama | [@rama](https://github.com/rama) |
| 🎯 PM | Sandeul | [@sandeul](https://github.com/sandeul) |
| 📱 iOS | Soop | [@soop](https://github.com/soop) |

---

## 🤝 기여하기

현재 Apple Developer Academy 프로젝트로 외부 기여는 받지 않습니다.
다만 다음은 환영합니다:
- 🐛 버그 제보
- 💡 기능 제안
- ⭐ 프로젝트 스타

---

## 📝 개발 일지

### 2024.09 - 프로젝트 시작
- 아이디어 도출: 문화 소비 → 취미 → 사진 촬영
- 경주 출사를 통한 현장 리서치
- 전문가 인터뷰 (사진 동아리 회장)

### 2024.10 - 프로토타입 개발
- 초기 아이디어 (설정 추천) 개발 및 유저 테스트
- 피봇: Tri-Shot + AI 그룹화 방향 전환
- Canon Camera Control API 연동 성공

### 2024.11 - MVP 완성
- Tri-Shot 기능 구현
- Vision Framework 기반 AI 그룹화
- TestFlight 베타 테스트

---

## 📄 라이선스

이 프로젝트는 Apple Developer Academy @ POSTECH의 교육 프로젝트입니다.

---

## 📬 문의

- 이메일: honesthouse2025@gmail.com
- 블로그: [Notion 링크]
- 발표 자료: [원페이저 링크]

---

## 🙏 감사의 말

- Apple Developer Academy @ POSTECH 코치님들
- 유저 테스트에 참여해주신 모든 분들
- Canon Korea (API 지원)
- 함께해준 팀원들 

---
