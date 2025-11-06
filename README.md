# HonestHouse
<div align="center">
<img width="40%" alt="image" src="https://github.com/user-attachments/assets/a94cc120-b4f5-4b8f-96c4-ee2b6e12732e" />

#### DSLR/미러리스 카메라 사용자가 온전히 순간에 집중하며 촬영할 수 있도록 미리 설정한 프리셋이 셔터를 누를 때마다 자동 변경되는 ‘Tri-Shot’을 이용하고 촬영한 사진을 Ai로 그룹화하여 베스트샷을 쉽게 고를 수 있는 앱

<br/>

[![iOS](https://img.shields.io/badge/iOS-17.0+-black?logo=apple)](https://www.apple.com/kr/ios)
[![Swift](https://img.shields.io/badge/Swift-5.9-FA7343?logo=swift)](https://swift.org)
[![Canon](https://img.shields.io/badge/Canon-Camera_API-red)](https://developers.canon.com)

</div>

---

## 프로젝트 소개

순간을 놓치지 않는 것, 사진가에게 가장 중요한 일입니다.

화이트밸런스, ISO, 셔터스피드, 조리개, 틴트, 픽처스타일...  
완벽한 순간을 담기 위한 설정이지만, 이를 조작하는 사이 그 순간은 사라집니다.

**Bracket은 미러리스 카메라 사용자가 촬영의 순간에만 집중하도록 돕기 위해 출발했습니다.**

3가지 프리셋을 미리 저장해두면 셔터를 누를 때마다 설정들이 자동으로 전환됩니다.  
같은 순간을 여러 느낌으로 촬영하고, 나중에 선택할 수 있습니다.

한 장면을 여러 설정으로 촬영하면 비슷한 사진이 수백 장 쌓이게 됩니다.  
Bracket은 유사한 사진끼리 자동으로 그룹화하여  
각 그룹에서 원하는 사진을 선택해 갤러리에 저장할 수 있도록 합니다.

---

<br/>

<!-- <div align="center">

<table>
<tr>
<td align="center" width="33%">
<img src="https://github.com/user-attachments/assets/700a89d7-90f5-4c97-b0c6-472685aee9bd" width="100%" />
<br/>
<b>프리셋 설정</b>
<br/>
<sub>원하는 설정 3개 저장</sub>
</td>
<td align="center" width="33%">
<img src="https://github.com/user-attachments/assets/fc50ce99-efb0-4c73-b0bf-e941b5583c29" width="100%" />
<br/>
<b>자동 촬영</b>
<br/>
<sub>셔터만 누르면 자동 전환</sub>
</td>
<td align="center" width="33%">
<img src="https://github.com/user-attachments/assets/ba00c874-c9cb-4acc-829f-5e6356cd9313" width="100%" />
<br/>
<b>AI 그룹화</b>
<br/>
<sub>비슷한 사진 자동 정리</sub>
</td>
</tr>
</table>

</div> -->


<div align="center">

| <img width="100%" src="https://github.com/user-attachments/assets/700a89d7-90f5-4c97-b0c6-472685aee9bd" /> | <img width="100%" src="https://github.com/user-attachments/assets/fc50ce99-efb0-4c73-b0bf-e941b5583c29" /> | <img width="100%" src="https://github.com/user-attachments/assets/ba00c874-c9cb-4acc-829f-5e6356cd9313" /> | <img width="100%" src="https://github.com/user-attachments/assets/4d84fab9-a794-4ebb-9599-5edc4628831b" /> |
|:---:|:---:|:---:|:---:|
| **Tri-Shot** | **프리셋 제작** | **카메라를 조작하는 듯한 Ui** | **사진 그룹화** |
| 원하는 설정으로 촬영 | 카메라 화면을 핸드폰으로 보며 값 조정 | 실제 카메라의 다이얼에서 영감을 얻은 디자인 | Vison과 시공간 정보로 사진 유사도를 계산하여 그룹화 |

</div>



---
## 주요 기능

### 📸 Tri-Shot
미리 저장한 3가지 프리셋이 셔터를 누를 때마다 자동으로 전환됩니다.
```
셔터 1회 → 프리셋 A
셔터 2회 → 프리셋 B  
셔터 3회 → 프리셋 C
셔터 4회 → 프리셋 A (반복)
```

### 🤖 AI 사진 그룹화
시각적 유사도, 시간, 위치 정보를 분석하여 비슷한 사진끼리 자동 그룹화합니다.

---

## 기술 스택

**Frontend**: SwiftUI, MVVM  
**Frameworks**: Vision, Core Location, Core Bluetooth, CoreData  
**APIs**: Canon Camera Control API, RESTful API, Digest Authentication

---
## 팀

| [![Sandeul](https://github.com/user-attachments/assets/7159c61b-af06-4281-84f6-d076b30682fc)](링크1) | [![Hari](https://github.com/user-attachments/assets/7159c61b-af06-4281-84f6-d076b30682fc)](링크2) | [![Ivy](https://github.com/user-attachments/assets/7159c61b-af06-4281-84f6-d076b30682fc)](링크3) | [![Minbol](https://github.com/user-attachments/assets/7159c61b-af06-4281-84f6-d076b30682fc)](링크4) | [![Rama](https://github.com/user-attachments/assets/7159c61b-af06-4281-84f6-d076b30682fc)](링크5) | [![Soop](https://github.com/user-attachments/assets/7159c61b-af06-4281-84f6-d076b30682fc)](링크6) |
|:---:|:---:|:---:|:---:|:---:|:---:|
| **양희준(Sandeul)** | **윤하정(Hari)** | **이현주(Ivy)** | **이보민(Minbol)** | **문형근(Rama)** | **한수빈(Soop)** |
| 🎯 PM | 🎨 Design | 📱 iOS | 📱 iOS | 📱 iOS | 📱 iOS |

---

## 문의

📧 honesthouse2025@gmail.com

---
