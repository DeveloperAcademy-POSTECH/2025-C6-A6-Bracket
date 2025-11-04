## Feature: Camera Connection Flow

This document summarizes the implementation of the camera connection flow, which presents a modal view on app launch if the camera is not connected.

### 1. Initial Goal

- To implement a modal view (`CameraConnectionView`) that prompts the user to connect to the camera upon application launch.
- This required a global state management solution for the camera's connection status.

### 2. Architectural Evolution

The architecture for managing the global connection state evolved through several iterations:

1.  **Initial Idea (Manager inside DI Container):** The first approach was to create a `CameraConnectionManager` and place it within the `Managers` group inside the `DIContainer`. 

2.  **Problem (Concurrency Conflicts):** This approach led to a series of Swift Concurrency errors. Because `CameraConnectionManager` needed to be marked with `@MainActor` to safely update the UI, it could not be initialized within the non-isolated `init()` chain of `HonestHouseApp` -> `DIContainer` -> `Managers`.

3.  **Final Solution (Separation of Concerns):** The adopted solution was to completely separate the UI state manager from the business logic DI container.
    - `CameraConnectionManager` was defined as a standalone, `@MainActor`-isolated `ObservableObject`.
    - It was removed from `DIContainer` and `Managers`.
    - In `HonestHouseApp`, both `DIContainer` and `CameraConnectionManager` are created and owned as separate `@StateObject`s.
    - Both objects are injected independently into the SwiftUI environment using `.environmentObject()`.

This architecture cleanly separates the business logic dependencies (in `DIContainer`) from the global UI state (in `CameraConnectionManager`) and resolves all concurrency issues while preserving the existing `init` structures.

### 3. Implementation & Bug Fixes

- **Modal Presentation:** Implemented the modal presentation logic in `HonestHouseApp.swift` using `.onAppear` and `.onChange(of: cameraConnectionManager.isConnected)` to control a `@State` variable for the sheet.

- **Key Bugs Fixed:**
    - **`EnvironmentObject` Crash:** Resolved a crash where the modally presented `CameraConnectionView` failed to receive `EnvironmentObject`s. The fix was to inject the objects explicitly into the sheet's content: `.sheet(...) { CameraConnectionView().environmentObject(...) }`.
    - **`@State` vs. `@StateObject`:** Corrected the declaration of `DIContainer` in `HonestHouseApp` from `@State` to `@StateObject` to ensure stable lifecycle management and prevent unpredictable crashes.
    - **`any` Keyword Warning:** Resolved compiler warnings by explicitly using the `any` keyword for existential protocol types (e.g., `var manager: any SomeManagerType`).
    - **`SIGABRT` Crash:** Fixed a crash in `Services.swift` caused by a failed forced typecast (`as!`), which was resolved by removing the unnecessary cast.
