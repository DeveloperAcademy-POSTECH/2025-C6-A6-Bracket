### **1. 개요 (Overview)**

*   **프로젝트 명:** Bracket
*   **플랫폼 & 언어:** iOS (Swift, SwiftUI)
*   **앱 소개:** 캐논 카메라 사용자가 앱에 프리셋을 미리 설정하면 셔터를 누를 때 설정이 자동 변경되며 연속 촬영하여 수동 조작의 불편함을 덜어준다. 또한 연속 촬영으로 늘어난 사진들은 시공간적·시각적 유사도 기준으로 자동 그룹화하여 편하게 검토하고 아카이빙할 수 있다.

### **2. 페르소나 (Persona)**

*   **사용자:** 콘서트, 공연 등 조명이 수시로 변하는 환경에서 DSLR로 아티스트의 순간을 포착하는 사진가.
*   **사용 목표:** 급변하는 조명 아래에서도 놓치고 싶지 않은 순간을 원하는 색감과 설정으로 빠르게 담아내고, 결과물을 신속하게 모바일에서 확인 및 공유하는 것.
*   **주요 과업:**
    1.  무대 조명 변화에 맞춰 카메라의 조리개(Aperture), 셔터 속도(Shutter Speed), ISO, 화이트 밸런스(White Balance) 등 복잡한 설정을 실시간으로 변경.
    2.  결정적인 순간을 놓치지 않기 위해 다양한 설정으로 여러 장의 사진을 촬영.
    3.  촬영된 수많은 사진 중 '베스트 컷'을 선별하여 모바일로 전송 및 업로드.

### **3. 고충 (Pain Points)**

*   **번거로운 설정 변경:** 포착한 순간을 가장 잘 표현할 수 있는 색감으로 담아내고 싶지만, 매번 카메라 설정을 수동으로 바꾸며 원하는 색감을 찾는 과정이 번거롭고 시간이 오래 걸린다.
*   **사진 선별의 어려움:** 원하는 결과물을 얻기 위해 비슷한 장면을 다른 설정으로 반복 촬영하다 보니 사진 개수가 기하급수적으로 늘어나, 나중에 베스트 컷을 선별하고 관리하기가 매우 불편하다.

### **4. 솔루션 (Solution): "Tri-shot" 기능**

*   카메라의 '브라케팅(Bracketing)' 기능에서 아이디어를 얻었습니다. 브라케팅은 노출처럼 하나의 값을 다르게 조절하여 3장을 연속 촬영하는 방식입니다.
*   `Bracket` 앱은 이를 확장하여, 사용자가 조리개, 셔터 속도, ISO 등 여러 값을 조합한 **프리셋**을 미리 만들어두고, 셔터 한 번에 이 프리셋들이 적용된 사진 3장을 연속으로 촬영하는 **"Tri-shot"** 기능을 제공합니다. 이를 통해 사용자는 수동 조작 없이 한 번의 촬영으로 다양한 결과물을 얻을 수 있습니다.

### **5. 핵심 기능 (Main Features)**

*   **카메라 연결 및 상태 관리:** 앱 시작 시 카메라 연결을 유도하고, 앱 전반에 걸쳐 연결 상태를 일관되게 관리합니다.
*   **Tri-shot 촬영:** 사용자가 직접 설정한 커스텀 프리셋 또는 카메라 내장 필터를 이용하여 브라케팅 방식의 연속 촬영을 지원합니다.
*   **지능형 사진 그룹화 및 아카이빙:** 촬영된 사진들을 시공간적 정보와 이미지 시각적 유사도를 기준으로 자동 그룹화하여, 사용자가 유사한 사진들을 한눈에 비교하고 쉽게 베스트 컷을 선택하여 아카이빙할 수 있도록 돕습니다.

---

### **6. 프로젝트 폴더 구조**

```markdown
- .github/
- docs/
- HonestHouse/
  - HonestHouse/
    - Resources/
      ...
    - Sources/
      - App/
        - ContentView.swift
        - HonestHouseApp.swift
      - Core/
        - CoreData/
          - PersistenceController.swift
          - PresetEntity+Extension.swift
          - PresetModel.xcdatamodeld/
            - PresetModel.xcdatamodel/
              - contents
        - Managers/
          - Error/
            - PhotoError.swift
            - VisionError.swift
          - Shared/
            - ImagePrefetchManagerTarget.swift
            - PhotoManagerType.swift
            - VisionManagerType.swift
          - CameraConnectionManager.swift
          - ImagePrefetchManager.swift
          - Managers.swift
          - PhotoManager.swift
          - PresetManager.swift
          - VisionManager.swift
        - Model/
          - 4.13. Camera Status/
            - 2. EventMonitor.swift
          - 4.7. Image Operations/
            - 1. StorageList.swift
            - 2. DirectoryList.swift
            - 3. ContentList.swift
          - 4.9. Shooting Settings/
            - 10. ColorTemperature.swift
            - 25. WBShift.swift
            - 28. PictureStyle.swift
            - 4. ShootingMode.swift
            - 5. AV.swift
            - 6. TV.swift
            - 7. ISO.swift
            - 8. ExposureCompensation.swift
            - 9. WhiteBalance.swift
          - AnalyzedPhoto.swift
          - Photo.swift
          - PictureStyleType.swift
          - Preset.swift
          - ShootingModeType.swift
          - SimilarPhotoGroup.swift
          - TrishotItem.swift
        - Network/
          - CCAPI/
            - 4.7. ImageOperations/
              - ImageOperationsAPI.swift
              - ImageOperationsTarget.swift
            - 4.8. Shooting Control/
              - ShootingControlAPI.swift
              - ShootingControlTarget.swift
            - 4.9. Shooting Settings/
              - ShootingSettingsAPI.swift
              - ShootingSettingsTarget.swift
          - DigestAuth/
            - DigestAuthManager.swift
            - DigestAuthPlugin.swift
            - HTTPDigestAuth.swift
            - NetworkManager.swift
            - SSLPinningDelegate.swift
          - DTO/
            - API+Namespace.swift
            - Protocol/
              - BaseRequest.swift
              - BaseResponse.swift
              - ResponseConvertible.swift
            - Request/
              - 4.8. Shooting Control/
                - 3. IgnoreShootingModeRequest.swift
              - 4.9. Shooting Settings/
                - 10. ColorTemperatureRequest.swift
                - 25. WBShiftRequest.swift
                - 28. PictureStyleRequest.swift
                - 4. ShootingModeRequest.swift
                - 5. AVRequest.swift
                - 6. TVRequest.swift
                - 7. ISORequest.swift
                - 8. ExposureCompensationRequest.swift
                - 9. WhiteBalanceRequest.swift
                - IntValueRequest.swift
                - StringValueRequest.swift
            - Response/
              - 4.13. Camera Status/
                - 2. EventMonitorResponse.swift
              - 4.7. Image Operations/
                - 1. StorageListResponse.swift
                - 2. DirectoryListResponse.swift
                - 3. ContentListResponse.swift
              - 4.9. Shooting Settings/
                - 10. ColorTemperatureResponse.swift
                - 25. WBShiftResponse.swift
                - 28. PictureStyleResponse.swift
                - 4. ShootingModeResponse.swift
                - 5. AVResponse.swift
                - 6. TVResponse.swift
                - 7. ISOResponse.swift
                - 8. ExposureCompensationResponse.swift
                - 9. WhiteBalanceResponse.swift
          - Error/
            - CCAPIError.swift
            - ImageLoadingError.swift
          - Foundation/
            - APIConstants.swift
            - BaseTargetType.swift
            - BaseURLConstants.swift
          - ImageLoader.swift
      - Extension/
        - Font+Extension.swift
      - General/
        - DIContainer.swift
        - Navigation/
          - NavigationDestination.swift
          - NavigationRouter.swift
          - NavigationRoutingView.swift
          - ObservableObjectSettable.swift
      - Presentation/
        - Archive/
          - Component/
            - CachedThumbnailImageView.swift
            - GroupedPhotosGridCellView.swift
            - ProgressiveDisplayImageView.swift
            - SelectionGridCellView.swift
            - ToastView.swift
          - Shared/
            - ArchiveErrorHandleable.swift
            - ArchiveState.swift
            - MediaType.swift
            - SavingState.swift
            - SelectableItem.swift
          - View/
            - ArchiveView.swift
            - GroupedPhotosDetailView.swift
            - GroupedPhotosView.swift
            - PhotoSelectionDetailView.swift
            - PhotoSelectionView.swift
          - ViewModel/
            - Error/
              - GroupingError.swift
              - SelectionError.swift
            - GroupedPhotosViewModel.swift
            - PhotoSelectionViewModel.swift
        - CameraConnection/
          - Error/
            - ConnectionError.swift
          - Shared/
            - ConnectionState.swift
            - ConnectionType.swift
          - View/
            - CameraConnectionView.swift
            - ConnectionGuideView.swift
            - ConnectionCompletionView.swift
        - Common/
          - ButtonStyle/
            - DefaultButtonStyle.swift
          - Common.swift
        - Live/
          - Shared/
            - DataType.swift
            - LiveViewInfo.swift
            - ParsedFrame.swift
            - StreamError.swift
            - StreamType.swift
          - ChunkedStreamParser.swift
          - LiveStreamView.swift
          - LiveStreamViewModel.swift
        - Main/
          - Component/
            - PresetGridCellView.swift
            - PresetGridView.swift
          - Shared/
            - MainViewSegmentType.swift
            - PresetDetailMode.swift
            - PresetErrorHandleable.swift
          - View/
            - MainView.swift
          - ViewModel/
            - Error/
              - PresetError.swift
            - MainViewModel.swift
        - Preset/
          - View/
            - PresetDetailView.swift
            - PresetView.swift
          - ViewModel/
            - PresetDetailViewModel.swift
            - PresetViewModel.swift
        - Trishot/
          - Component/
            - RemoteControllerComponent.swift
          - View/
            - TrishotSelectionView.swift
            - TrishotSettingView.swift
          - ViewModel/
            - TrishotSettingViewModel.swift
      - Service/
        - CCAPI/
          - 4.7. ImageOperationsService.swift
          - 4.8. ShootingControlService.swift
          - 4.9. ShootingSettingsService.swift
          - BaseService.swift
          - BaseStreamService.swift
          - EventMonitorService.swift
          - Stream/
            - StreamService.swift
          - StreamDownload/
            - StreamDownloadDelegate.swift
            - StreamDownloadService.swift
        - LiveViewService.swift
        - Services.swift
      - Type/
        - VersionType.swift
  - HonestHouse.xcodeproj/
- .coderabbit.yaml
- .gitignore
- PRD.md
- README.md
```

---

### 7. 핵심 기능과 기술 스택 (Core Features & Tech Stack)

이 섹션은 프로젝트의 핵심 기능들이 어떤 기술을 통해 구현되는지 명확히 정의하여, Gemini와 개발자 간의 원활한 소통과 협업을 돕기 위해 작성되었습니다.

#### 7.1. 카메라 연결 및 상태 관리 (Global Connection Management)

-   **설명:** 앱의 핵심 기능 사용에 앞서 카메라와의 연결을 보장하기 위한 필수적인 기능입니다. 앱 시작 시 연결 상태를 확인하여, 연결되지 않았을 경우 사용자에게 연결을 유도하는 모달 뷰를 제시합니다. 연결 결과(성공/실패)는 모달 내에서 Alert로 피드백되며, 연결 상태는 앱의 생명주기 동안 일관되게 유지됩니다.
-   **주요 기술:**
    -   **상태 관리 (`SwiftUI`, `@StateObject`, `@EnvironmentObject`):** 앱의 최상위(`HonestHouseApp`)에서 `@StateObject`로 `CameraConnectionManager`를 생성하여 앱 전역의 '단일 진실 공급원(Single Source of Truth)'으로 사용합니다. 이 Manager는 연결 상태뿐만 아니라, 자신이 표시될 모달 시트의 상태(`@Published var showConnectionSheet`)까지 직접 관리하여 로직을 중앙 집중화합니다.
    -   **동시성 (`@MainActor`):** `CameraConnectionManager`를 `@MainActor`로 지정하여, 네트워크 통신 후 UI와 관련된 프로퍼티를 메인 스레드에서 안전하게 업데이트하도록 보장합니다.
    -   **에러 핸들링:** 저수준의 `CCAPIError`를 UI에 친화적인 `ConnectionError`로 변환하는 '번역기' 패턴을 사용합니다. `ConnectionError`는 사용자에게 보여줄 메시지를 포함하며, `ConnectionGuideView`는 이 에러를 받아 Alert를 표시합니다.
-   **핵심 파일:**
    -   `HonestHouse/Sources/App/HonestHouseApp.swift`: `CameraConnectionManager`의 인스턴스를 생성 및 주입하고, Manager의 `showConnectionSheet` 상태에 따라 모달 시트를 띄웁니다.
    -   `HonestHouse/Sources/Core/Managers/CameraConnectionManager.swift`: 연결 상태(`connectionState`)와 모달 표시 상태(`showConnectionSheet`)를 모두 `@Published` 프로퍼티로 관리하는 `ObservableObject`.
    -   `HonestHouse/Sources/Presentation/CameraConnection/View/CameraConnectionView.swift`: 모달 시트의 루트 뷰. `NavigationStack`을 제공하여 연결 가이드, 완료 화면으로의 이동을 가능하게 합니다.
    -   `HonestHouse/Sources/Presentation/CameraConnection/View/ConnectionGuideView.swift`: IP 입력 등 실제 연결을 시도하는 뷰. `CameraConnectionManager`의 상태 변화를 감지(`.onChange`)하여 성공/실패 Alert를 표시하고, 성공 시 `ConnectionCompletionView`로 이동합니다.
    -   `HonestHouse/Sources/Presentation/CameraConnection/View/ConnectionCompletionView.swift`: 연결 완료를 알려주는 화면. 모달을 닫는 버튼을 포함합니다.
    -   `HonestHouse/Sources/Presentation/CameraConnection/Error/ConnectionError.swift`: `CCAPIError`를 UI에 표시하기 적합한 에러 타입으로 변환하는 로직을 포함합니다.
-   **동작 흐름:**
    1.  **모달 표시:** `MainView`의 `.onAppear`에서 `cameraConnectionManager.showConnectionSheet`를 `true`로 설정하면, `MainView`에 바인딩된 `.sheet`이 `CameraConnectionView`를 모달로 띄웁니다.
    2.  **연결 시도:** 사용자가 `ConnectionGuideView`에서 IP 주소를 입력하고 '연결하기' 버튼을 누르면 `cameraConnectionManager.connectCamera()` 함수가 호출됩니다.
    3.  **상태 변경 감지:** `ConnectionGuideView`는 `.onChange`를 통해 `cameraConnectionManager.connectionState`의 변화를 감지합니다.
    4.  **Alert 표시:** 상태가 `.connected` 또는 `.failed`로 변경되면, `ConnectionGuideView`는 결과에 맞는 Alert를 띄웁니다.
    5.  **모달 내 화면 이동:** 성공 Alert의 '확인' 버튼을 누르면, `ConnectionGuideView`는 `NavigationLink`를 활성화하여 모달 내에서 `ConnectionCompletionView`로 이동합니다.
    6.  **모달 닫기:** 사용자가 `ConnectionCompletionView`의 'Start Tri-shot' 버튼을 누르면, `cameraConnectionManager.showConnectionSheet`가 `false`로 변경되어 모달 시트 전체가 닫힙니다.

#### 7.2. Tri-shot 연속 촬영 (Remote Shooting)

-   **설명:** `MainView`의 Segmented Control을 통해 접근하는 원격 촬영 기능입니다. 사용자가 정의한 여러 촬영 설정(프리셋)을 한 번의 셔터로 연속 촬영하게 합니다.
-   **주요 기술:**
    -   **네트워킹 (`URLSession`, `Digest Authentication`):** Canon 카메라와의 실시간 통신(CCAPI)을 담당합니다.
    -   **UI (`SwiftUI`):** `MainView` 내에서 촬영 프리셋 설정 및 원격 촬영을 위한 사용자 인터페이스를 제공합니다.
    -   **상태 관리 (`MVVM`):** 사용자의 인터랙션과 촬영 프로세스의 상태를 관리합니다.
-   **핵심 파일:**
    -   `Presentation/Main/View/MainView.swift`: Segmented Control을 통해 "Tri-shot" 뷰와 "프리셋 설정" 뷰를 전환하는 컨테이너 뷰.
    -   `Presentation/Trishoot/View/TrishootView.swift`: `MainView`에 포함되어 실제 Tri-shot 프리셋 선택 및 촬영을 담당하는 화면.
    -   `Presentation/Trishoot/View/PresetSetupView.swift`: `MainView`에 포함되어 Tri-shot 프리셋을 생성 및 관리하는 화면.
    -   `Presentation/Trishoot/ViewModel/TrishootViewModel.swift`: `TrishootView`의 상태를 관리하고, Service를 통해 카메라 제어 명령을 전달.
    -   `Service/CCAPI/ShootingSettingsService.swift`: 실제 카메라 촬영 및 설정을 제어하는 비즈니스 로직.
    -   `Core/Network/CCAPI/`: 카메라 제어를 위한 API 엔드포인트 및 요청/응답 정의.
-   **동작 흐름:**
    1.  **View:** 사용자가 `MainView`에서 "Tri-shot" 또는 "프리셋 설정" 세그먼트를 선택합니다.
    2.  **View:** 선택에 따라 `TrishootView` 또는 `PresetSetupView`가 화면에 표시됩니다.
    3.  **ViewModel:** 각 뷰에 연결된 ViewModel이 사용자의 입력을 처리합니다.
    4.  **Service:** `TrishootViewModel`을 통해 `ShootingSettingsService`에 촬영 명령을 전달합니다.

#### 7.3. 지능형 사진 그룹화 (Intelligent Grouping & Archiving)

-   **설명:** 연속 촬영으로 생성된 다수의 사진을 시공간적, 시각적 유사도를 기준으로 자동 그룹화하여 사용자의 사진 선별 작업을 돕고, 선택된 베스트 컷을 기기의 사진 앨범에 저장하는 기능입니다.
-   **주요 기술:**
    -   **이미지 분석 (`Vision Framework`):** 사진 간의 시각적 유사도를 계산하는 데 사용됩니다.
    -   **사진 라이브러리 (`Photos Framework`):** 사용자가 선택한 베스트 컷을 기기의 사진 앨범에 저장하는 기능을 담당합니다.
    -   **데이터 모델링 (`Swift Structs`):** 분석된 사진과 그룹의 정보를 구조화합니다.
    -   **UI (`SwiftUI`):** 그룹화된 사진을 효과적으로 보여주고 사용자가 선택할 수 있는 인터페이스를 제공합니다.
-   **핵심 파일:**
    -   `Core/Managers/VisionManager.swift`: Apple의 Vision 프레임워크를 사용하여 이미지의 특징(Feature Print)을 추출하고 비교하는 핵심 로직.
    -   `Core/Managers/PhotoManager.swift`: `Photos` 프레임워크와 상호작용하여 사진을 앨범에 저장하는 로직.
    -   `Core/Managers/Error/PhotoError.swift`: 사진 저장 과정에서 발생하는 오류를 정의.
    -   `Core/Model/SimilarPhotoGroup.swift`: 유사한 사진들의 그룹을 나타내는 데이터 모델.
    -   `Presentation/Archive/GroupedPhotosView.swift`: 유사도에 따라 그룹화된 사진 앨범을 보여주는 뷰.
    -   `Presentation/Archive/PhotoSelectionView.swift`: 특정 그룹 내에서 베스트 컷을 확대하고 비교/선택하는 뷰.
-   **동작 흐름:**
    1.  **Manager:** `VisionManager`가 촬영된 사진들을 가져와 분석을 시작합니다.
    2.  **Analysis:** 각 사진의 생성 시간, GPS 정보(시공간적)와 Vision Feature Print(시각적)를 추출하여 유사도를 계산합니다.
    3.  **Model:** 유사도가 높은 사진들을 `SimilarPhotoGroup` 객체로 묶습니다.
    4.  **ViewModel & View:** `GroupedPhotosViewModel`이 이 그룹 데이터를 받아 `GroupedPhotosView`에 시각적으로 표시합니다.
    5.  **Save:** 사용자가 `PhotoSelectionView`에서 베스트 컷을 선택한 후 저장하면, `GroupedPhotosViewModel`이 `PhotoManager`를 통해 선택된 사진들을 기기의 "HonestHouse" 앨범에 저장합니다.

---

### 8. AI 협업 가이드라인

#### 핵심 원칙

- **프로젝트 우선 원칙**: 모든 기술적 결정, 코드 생성, 답변은 이 PRD에 정의된 프로젝트의 목표와 명세를 근본적으로 기반해야 합니다.

#### CLI 컨텍스트 가이드라인

##### 코드 품질 및 원칙

- **SOLID 원칙 준수**: SOLID 원칙을 준수합니다.
- **코드 주석 정책**: 최종 코드 및 예시 코드에는 주석을 사용하지 않습니다. (단, 로깅을 위한 간단한 영문 에러 메시지는 예외)
- **데이터 사용**: Mock 데이터는 테스트 환경에서만 사용합니다.

##### 기술 스택 관리

- **핵심 기술 스택**: Swift, SwiftUI를 고정 기술 스택으로 사용하며, 사용자의 명시적인 요청 없이는 대안 기술을 제안하거나 사용하지 않습니다.
- **기술 스택 일관성**: 사용자 승인 없이 기술 스택을 변경하지 않으며, 호환되지 않는 의존성을 도입하지 않습니다.

##### 워크플로우 및 프로세스

- **테스트 전략**: 주요 기능에 대한 전체 테스트 커버리지를 목표로 하며, 예외 케이스를 포함한 테스트를 작성합니다.
- **코드 수정 워크플로우**:
    - **AI (제안자)**: AI는 코드 변경을 분석하고 제안합니다. AI는 'TO-BE' 코드를 제시하지만 파일에 직접 쓰지 않습니다.
    - **사용자 (구현자)**: 사용자는 AI의 제안에 따라 코드를 수정하는 유일한 주체입니다.
    - **검증 루프**: 사용자가 수정 완료를 확인하면, AI는 다음 단계로 진행하기 전에 파일 내용을 다시 읽어 변경사항이 올바르게 적용되었는지 확인해야 합니다.
- **컨텍스트 요약 워크플로우**:
    - 작업 브랜치에서 특정 기능 개발이나 수정이 완료되면, AI 또는 사용자의 요청에 따라 해당 작업에 대한 컨텍스트 요약을 진행합니다.
    - 요약 파일은 `docs/context/` 디렉토리 내에 저장됩니다.
    - 파일 이름은 현재 Git 브랜치 이름을 기반으로 생성하며, 파일명으로 사용할 수 없는 특수문자(`/`, `#` 등)는 하이픈(`-`)으로 치환합니다. (예: `feat/#27/download` -> `feat-27-download.md`)
    - 생성된 요약 파일은 Pull Request(PR) 설명에 링크하여 코드 리뷰어가 작업 맥락을 쉽게 파악할 수 있도록 돕습니다.
    - 이후 AI는 특정 작업과 관련된 컨텍스트 파일을 기반으로 작업을 진행합니다.

#### 커뮤니케이션 원칙

- **AI-사용자 상호작용**: 모든 AI 응답은 컨텍스트를 이해했음을 확인하는 의미로 `🍎` 이모지로 시작해야 합니다.
- **계획 및 승인**: 아키텍처 변경 등 큰 변경 작업 전에는 구현 계획을 먼저 제시하고 승인을 받습니다.
- **진행 상황 추적**: 완료된 작업, 진행 중인 작업, 다음 작업을 명확히 구분하여 상태를 투명하게 공유합니다.

#### 실행 가이드라인

- **응답 형식**:
```
🍎

## 현재 상태
- 완료: [완료된 작업 목록]
- 진행 중: [현재 작업]
- 대기: [다음 작업]

## 구현
[실제 구현 또는 계획]

## 다음 단계
[예정된 작업]
```
- **품질 체크리스트**:
  - [ ] SOLID 원칙 준수
  - [ ] 테스트 케이스 포함
  - [ ] 기술 스택 일관성 유지
  - [ ] 사용자 승인 요구사항 확인
