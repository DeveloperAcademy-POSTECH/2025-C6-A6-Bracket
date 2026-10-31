//
//  BluetoothConnectionViewModel.swift
//  HonestHouse
//
//  BLE 검색 → 페어링 → 카메라 Wi-Fi 켜기 → 자동 접속까지 진행하고, 이후 CCAPI 또는 PTP/IP로 연결
//

import Foundation

@MainActor
final class BluetoothConnectionViewModel: ObservableObject {
    enum Step: Equatable {
        case idle
        case searching
        case pairing
        case enablingWiFi
        case joiningWiFi(String)
        case ready(CameraWiFiInfo)
        case failed(String)

        var message: String {
            switch self {
            case .idle: return ""
            case .searching: return "카메라를 찾는 중..."
            case .pairing: return "카메라 화면에서 연결을 승인해주세요."
            case .enablingWiFi: return "카메라 Wi-Fi를 켜는 중..."
            case .joiningWiFi(let ssid): return "\(ssid)에 접속하는 중..."
            case .ready(let info): return "\(info.ssid ?? "카메라") 접속 완료 (\(info.ipAddress ?? "-"))"
            case .failed(let message): return message
            }
        }

        var isRunning: Bool {
            switch self {
            case .searching, .pairing, .enablingWiFi, .joiningWiFi: return true
            default: return false
            }
        }
    }

    @Published private(set) var step: Step = .idle
    @Published private(set) var cameraName: String?

    let bluetoothManager: BluetoothManager

    init(bluetoothManager: BluetoothManager? = nil) {
        self.bluetoothManager = bluetoothManager ?? BluetoothManager()
    }

    var wifiInfo: CameraWiFiInfo? {
        if case .ready(let info) = step { return info }
        return nil
    }

    func start() async {
        guard !step.isRunning else { return }
        do {
            step = .searching
            let camera = try await bluetoothManager.connectToCamera()
            cameraName = camera.name

            step = .pairing
            try await bluetoothManager.pairOrInitialize(camera: camera)

            step = .enablingWiFi
            let info = try await bluetoothManager.enableWiFi()

            step = .joiningWiFi(info.ssid ?? "카메라 Wi-Fi")
            try await WiFiJoiner.join(info)

            step = .ready(info)
        } catch {
            Logger.error("Bluetooth connection failed: \(error.localizedDescription)", category: .bluetooth)
            step = .failed(error.localizedDescription)
        }
    }

    /// 경로 1: 기존 CCAPI 연결. BLE로 켠 Wi-Fi는 Camera Connect(PTP/IP) 모드라 CCAPI가 응답하지 않을 수 있음
    func connectWithCCAPI(using manager: CameraConnectionManager) async {
        guard let ip = wifiInfo?.ipAddress else { return }
        if !(await WiFiJoiner.isReachable(host: ip, port: 8080, timeout: 3)) {
            Logger.warning("CCAPI port 8080 unreachable on BLE Wi-Fi", category: .bluetooth)
            manager.connectionState = .failed(.ccapiUnavailableOnBluetoothWiFi)
            return
        }
        BaseURLConstants.scheme = "http"
        BaseURLConstants.cameraIP = ip
        BaseURLConstants.port = "8080"
        manager.connectCamera(ipAddress: ip)
    }

    func shutterOverBluetooth() async -> String {
        do {
            try await bluetoothManager.shutter()
            return "BLE 셔터 완료"
        } catch {
            return "BLE 셔터 실패: \(error.localizedDescription)"
        }
    }
}
