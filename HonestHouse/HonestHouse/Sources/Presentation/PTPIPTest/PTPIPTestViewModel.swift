//
//  PTPIPTestViewModel.swift
//  HonestHouse
//
//  PTP/IP(Camera Connect 방식) 실기 검증용 화면 상태
//

import SwiftUI

@MainActor
final class PTPIPTestViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case connecting
        case connected
        case failed(String)
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var cameraDescription = ""
    @Published private(set) var liveViewImage: UIImage?
    @Published private(set) var isLiveViewOn = false
    @Published private(set) var isBusy = false
    @Published private(set) var logs: [String] = []
    @Published var evfOutputDevice: UInt32 = 2

    let host: String
    private let bluetoothViewModel: BluetoothConnectionViewModel?
    private var session: CanonPTPSession?
    private var liveViewTask: Task<Void, Never>?

    init(host: String, bluetoothViewModel: BluetoothConnectionViewModel? = nil) {
        self.host = host
        self.bluetoothViewModel = bluetoothViewModel
    }

    var logText: String {
        logs.joined(separator: "\n")
    }

    func connect() async {
        guard state != .connecting else { return }
        state = .connecting
        log("connect \(host):\(PTPIPConnection.defaultPort)")
        do {
            try await WiFiJoiner.waitUntilReachable(host: host, port: PTPIPConnection.defaultPort)
            let session = CanonPTPSession(host: host, guid: CameraIdentity.appUUID.bytes, name: CameraIdentity.nickname)
            try await session.open()
            self.session = session
            if let info = await session.deviceInfo {
                cameraDescription = "\(info.manufacturer) \(info.model) · fw \(info.version)"
                log("DeviceInfo: \(cameraDescription), ops=\(info.operations.count)")
            }
            log("remote mode 0x\(String(await session.remoteMode, radix: 16))")
            state = .connected
        } catch {
            log("connect failed: \(error.localizedDescription)")
            state = .failed(error.localizedDescription)
        }
    }

    func disconnect() async {
        await stopLiveView()
        await session?.close()
        session = nil
        state = .idle
        log("disconnected")
    }

    func shoot() async {
        guard let session else { return }
        isBusy = true
        defer { isBusy = false }
        do {
            let started = Date()
            try await session.shoot()
            let objects = try await session.waitForNewObjects()
            let elapsed = String(format: "%.1fs", Date().timeIntervalSince(started))
            if objects.isEmpty {
                log("shoot ok, no ObjectAdded event (\(elapsed))")
            } else {
                objects.forEach { log("shoot ok → \($0.filename) \($0.size)B (\(elapsed))") }
            }
        } catch {
            log("shoot failed: \(error.localizedDescription)")
        }
    }

    func toggleLiveView() async {
        if isLiveViewOn {
            await stopLiveView()
        } else {
            await startLiveView()
        }
    }

    private func startLiveView() async {
        guard let session else { return }
        do {
            await session.setEVFOutputDevice(evfOutputDevice)
            try await session.startLiveView()
            isLiveViewOn = true
            log("liveview start (EVF output \(evfOutputDevice))")
        } catch {
            log("liveview start failed: \(error.localizedDescription)")
            return
        }
        liveViewTask = Task { [weak self] in
            var frames = 0
            var emptyPolls = 0
            let started = Date()
            while !Task.isCancelled {
                do {
                    if let jpeg = try await session.liveViewFrame(), let image = UIImage(data: jpeg) {
                        frames += 1
                        self?.liveViewImage = image
                        if frames == 1 { self?.log("first frame \(jpeg.count)B") }
                    } else {
                        emptyPolls += 1
                        if emptyPolls == 100 && frames == 0 {
                            self?.log("no frame after 100 polls — try other EVF output value")
                        }
                        try await Task.sleep(nanoseconds: 50_000_000)
                    }
                } catch {
                    self?.log("liveview error: \(error.localizedDescription)")
                    break
                }
            }
            let fps = Double(frames) / max(Date().timeIntervalSince(started), 0.001)
            self?.log(String(format: "liveview stop: %d frames, %.1f fps", frames, fps))
        }
    }

    private func stopLiveView() async {
        guard isLiveViewOn else { return }
        liveViewTask?.cancel()
        _ = await liveViewTask?.value
        liveViewTask = nil
        await session?.stopLiveView()
        isLiveViewOn = false
        liveViewImage = nil
    }

    func shutterOverBluetooth() async {
        guard let bluetoothViewModel else {
            log("BLE not connected")
            return
        }
        log(await bluetoothViewModel.shutterOverBluetooth())
    }

    private func log(_ message: String) {
        let time = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        logs.append("[\(time)] \(message)")
        Logger.info(message, category: .ptpip)
    }
}
