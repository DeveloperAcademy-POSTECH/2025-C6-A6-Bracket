# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Bracket** (project codename: HonestHouse) is an iOS SwiftUI app that remotely controls Canon cameras over Wi-Fi via Canon's CCAPI (Camera Control API). Core feature is "Tri-shot": users define 2–3 camera-setting presets (aperture, shutter speed, ISO, white balance, etc.) and the camera cycles through them on consecutive shots. Shot photos are then auto-grouped by visual similarity (Vision framework) for review/archiving.

- iOS 18+, Swift 5, SwiftUI, dark mode only (`.preferredColorScheme(.dark)`)
- Dependencies (SPM): Moya/Alamofire (networking), Kingfisher (image caching), Lottie (splash animation)
- Product spec and architecture rationale: `docs/PRD.md` (Korean)
- Per-feature context summaries live in `docs/context/` (named after branch, e.g. `feat-27-download.md`); link them in PRs

## Build Commands

There are no tests or linters configured. The Xcode project lives one level down from the repo root:

```bash
# Build (from repo root)
xcodebuild -project HonestHouse/HonestHouse.xcodeproj -scheme HonestHouse \
  -destination 'generic/platform=iOS Simulator' build
```

Running meaningfully requires a physical Canon camera on the same network (the app talks to the camera's IP via CCAPI with HTTP Digest auth), so simulator runs only exercise UI.

## Architecture

Source root: `HonestHouse/HonestHouse/Sources/`

### Layering: View → ViewModel → Service/Manager → Network

- **`Presentation/`** — MVVM, one folder per feature: `Main` (segmented container), `Trishot` (preset-cycling shooting), `Preset` (preset CRUD + circular/linear wheel pickers), `Archive` (photo grouping/selection), `Live` (camera live-view MJPEG stream), `CameraConnection`, `Setting`, `Splash`.
- **`Service/CCAPI/`** — business logic over CCAPI endpoints. All services extend `BaseService` (generic Moya request + JSON decode → throws `CCAPIError`). Streaming endpoints (live view, event monitor, downloads) use `BaseStreamService` / `URLSession` delegates instead.
- **`Core/Managers/`** — device-side logic: `VisionManager` (feature-print similarity), `PhotoManager` (save to Photos album), `PresetManager` (CoreData persistence), `ImagePrefetchManager`, `CameraConnectionManager` (app-wide connection state, `@MainActor`, injected as its own `@EnvironmentObject`).
- **`Core/Network/`** — Moya `TargetType`s per CCAPI chapter, DTOs, and Digest auth.
- **`General/`** — `DIContainer`, `NavigationRouter`, error-handling primitives (`ViewState`, `AlertPresentable`/`AlertInfo`), `Logger`.

### Dependency injection

`DIContainer` (an `ObservableObject` injected via `.environmentObject` in `HonestHouseApp`) holds `services: ServiceType`, `managers: ManagersType`, `navigationRouter`, and `presetStateObserver`. Every service/manager has a protocol (`XxxServiceType` / `XxxManagerType`) plus a `StubXxx` implementation; `DIContainer.stub` wires all stubs for previews. When adding a service or manager: define the protocol, real impl, and stub, then register in `Services`/`Managers` and their stub counterparts.

### CCAPI networking specifics

- Files under `Core/Network/CCAPI/`, `Core/Network/DTO/`, and `Core/Model/` are organized by **CCAPI spec chapter numbers** (e.g. `4.9. Shooting Settings/10. ColorTemperature.swift`) — keep this convention when adding endpoints.
- DTOs are namespaced under empty enums (`ShootingSettings`, `ImageOperations`, …) in `DTO/API+Namespace.swift`; responses convert to domain models via `ResponseConvertible.toEntity()`.
- `NetworkManager` (singleton) wraps a Moya provider with **HTTP Digest authentication** (`DigestAuthManager`/`DigestAuthPlugin`) and disabled TLS trust evaluation for the camera host. It retries 401s up to 3 times (mirrors Canon's Android reference implementation) and maps HTTP errors — including CCAPI's stringly-typed 503 messages like "Device busy" — to `CCAPIError`. It must be `configure(cameraIP:)`-d before any request.
- `BaseURLConstants` holds mutable statics (scheme/IP/port) that form the base URL; camera model differences (endpoint versions like `ver100`/`ver110`, mode-dial vs. no-dial) are resolved per-request through `CameraType.current` (stored in UserDefaults) inside each Target's `path`.

### Error handling pattern

Low-level `CCAPIError` is translated into feature-level error enums (`ConnectionError`, `PresetError`, `TrishotError`, `ArchiveError`, …) that conform to `AlertPresentable`, which supplies `AlertInfo` for user-facing alerts. ViewModels expose loading/success/failure via the generic `ViewState<Success, Failure>`.

### Navigation

Custom router: `NavigationRouter` (conforming to `NavigationRoutable & ObservableObjectSettable`, owned by `DIContainer`) pushes `NavigationDestination` cases, rendered by `NavigationRoutingView`. Add new screens as `NavigationDestination` cases rather than ad-hoc `NavigationLink`s.

## Conventions

- Team is Korean; commit messages, PR descriptions, and code documentation comments are written in Korean. Commit format: `<type>: <설명>` (`feat`, `fix`, `chore`, `refactor`, …), optionally `[#issue]` prefix. Branches: `<type>/#<issue>/<topic>` (e.g. `feat/#27/download`). PRs target `dev` and follow `.github/PULL_REQUEST_TEMPLATE.md`.
- `docs/PRD.md` §8 asks for SOLID adherence, no comments in final code (brief English log messages excepted), and Swift/SwiftUI only — don't introduce alternative tech without explicit approval.
