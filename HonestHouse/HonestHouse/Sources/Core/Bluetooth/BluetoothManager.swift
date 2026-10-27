//
//  BluetoothManager.swift
//  HonestHouse
//
//  CoreBluetooth로 캐논 카메라 검색·페어링·Wi-Fi 켜기·원격 셔터를 수행
//

import CoreBluetooth
import Foundation

enum BluetoothError: LocalizedError, Equatable {
    case unavailable(String)
    case cameraNotFound
    case notConnected
    case characteristicNotFound(String)
    case pairingRejected
    case wifiRejected
    case timeout(String)
    case failed(String)

    var errorDescription: String? {
        switch self {
        case .unavailable(let reason): return "Bluetooth를 사용할 수 없습니다. (\(reason))"
        case .cameraNotFound: return "카메라를 찾지 못했습니다. 카메라에서 스마트폰 연결 대기 화면인지 확인해주세요."
        case .notConnected: return "카메라와 Bluetooth 연결이 끊어졌습니다."
        case .characteristicNotFound(let uuid): return "카메라가 지원하지 않는 기능입니다. (\(uuid))"
        case .pairingRejected: return "카메라에서 페어링이 거부되었습니다."
        case .wifiRejected: return "카메라가 Wi-Fi 켜기 요청을 거부했습니다."
        case .timeout(let step): return "\(step) 응답 시간이 초과되었습니다."
        case .failed(let message): return message
        }
    }
}

struct DiscoveredCamera: Identifiable, Equatable {
    let id: UUID
    let name: String
    let advertisement: CanonAdvertisement?
    let rssi: Int
}

@MainActor
final class BluetoothManager: NSObject, ObservableObject {
    @Published private(set) var discovered: [DiscoveredCamera] = []
    @Published private(set) var connectedName: String?

    private var central: CBCentralManager!
    private var peripherals: [UUID: CBPeripheral] = [:]
    private var peripheral: CBPeripheral?
    private var characteristics: [CBUUID: CBCharacteristic] = [:]

    private var stateWaiters: [Waiter<Void>] = []
    private var connectWaiter: Waiter<Void>?
    private var discoveryWaiter: Waiter<Void>?
    private var pendingServiceCount = 0
    private var writeWaiters: [CBUUID: Waiter<Void>] = [:]
    private var readWaiters: [CBUUID: Waiter<Data>] = [:]
    private var notifyStateWaiters: [CBUUID: Waiter<Void>] = [:]
    private var valueWaiters: [CBUUID: Waiter<Data>] = [:]
    private var bufferedValues: [CBUUID: [Data]] = [:]

    override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: .main)
    }

    // MARK: - Public API

    /// 블루투스 켜짐 대기 → 검색 → 연결 → 서비스/특성 탐색
    func connectToCamera(scanTimeout: TimeInterval = 10) async throws -> DiscoveredCamera {
        try await waitUntilPoweredOn()
        let camera = try await findCamera(timeout: scanTimeout)
        guard let target = peripherals[camera.id] else { throw BluetoothError.cameraNotFound }
        try await connect(target)
        CameraIdentity.lastPeripheralID = camera.id
        connectedName = camera.name
        return camera
    }

    /// 처음 연결이면 페어링 시퀀스, 이미 페어링된 카메라면 initialize만 수행
    func pairOrInitialize(camera: DiscoveredCamera, nickname: String = CameraIdentity.nickname) async throws {
        if camera.advertisement?.isPairingMode ?? true {
            try await pair(nickname: nickname)
        } else {
            _ = try await read(CanonBLE.capability)
        }
    }

    func pair(nickname: String) async throws {
        Logger.info("BLE pairing start", category: .bluetooth)
        try await setNotify(CanonBLE.pairing)
        try await write(CanonBLE.pairing, CanonBLEParser.pairingRequest(nickname: nickname))
        let reply = try await nextValue(CanonBLE.pairing, timeout: 90, step: "카메라 페어링 승인")
        guard reply.first == CanonBLE.PairingReply.accepted else {
            Logger.warning("BLE pairing rejected: \(reply.map { String(format: "%02x", $0) }.joined())", category: .bluetooth)
            throw BluetoothError.pairingRejected
        }
        _ = try await read(CanonBLE.capability)
        for command in CanonBLEParser.registrationCommands(appUUID: CameraIdentity.appUUID, nickname: nickname) {
            try await write(CanonBLE.command, command)
        }
        try await write(CanonBLE.command, Data([CanonBLE.Command.success]))
        Logger.info("BLE pairing done", category: .bluetooth)
    }

    /// 카메라 Wi-Fi(AP)를 켜고 SSID/비밀번호/IP를 받아옴
    func enableWiFi(timeout: TimeInterval = 30) async throws -> CameraWiFiInfo {
        try await setNotify(CanonBLE.wifiCommand)
        try? await setNotify(CanonBLE.wifiStatus)
        bufferedValues[CanonBLE.wifiCommand] = nil
        try await write(CanonBLE.wifiCommand, CanonBLE.WiFiCommand.start)

        var info = CameraWiFiInfo()
        let deadline = Date().addingTimeInterval(timeout)
        while info.ipAddress == nil {
            let remaining = deadline.timeIntervalSinceNow
            guard remaining > 0 else { throw BluetoothError.timeout("카메라 Wi-Fi 켜기") }
            if let status = bufferedValues[CanonBLE.wifiStatus]?.last, status.count >= 2,
               status[status.startIndex] == 1, (4...9).contains(status[status.startIndex + 1]) {
                throw BluetoothError.wifiRejected
            }
            let value = try await nextValue(CanonBLE.wifiCommand, timeout: remaining, step: "카메라 Wi-Fi 켜기")
            CanonBLEParser.apply(CanonBLEParser.wifiResponse(value), to: &info)
        }
        info.ssid = CanonBLEParser.string(try await read(CanonBLE.wifiSSID))
        info.password = CanonBLEParser.string(try await read(CanonBLE.wifiPassword))
        Logger.info("Camera Wi-Fi ready ssid=\(info.ssid ?? "-") ip=\(info.ipAddress ?? "-")", category: .bluetooth)
        return info
    }

    func shutter() async throws {
        try await write(CanonBLE.remoteMode, CanonBLE.Remote.modeRec)
        try await write(CanonBLE.shoot, CanonBLE.Remote.afReleaseOn)
        try await Task.sleep(nanoseconds: 300_000_000)
        try await write(CanonBLE.shoot, CanonBLE.Remote.afReleaseOff)
    }

    func disconnect() {
        if let peripheral { central.cancelPeripheralConnection(peripheral) }
        peripheral = nil
        characteristics = [:]
        connectedName = nil
    }

    // MARK: - Steps

    private func waitUntilPoweredOn() async throws {
        switch central.state {
        case .poweredOn: return
        case .unauthorized: throw BluetoothError.unavailable("권한 없음")
        case .unsupported: throw BluetoothError.unavailable("지원하지 않는 기기")
        case .poweredOff: throw BluetoothError.unavailable("Bluetooth 꺼짐")
        default:
            try await withTimeout(5, step: "Bluetooth 준비") { waiter in
                self.stateWaiters.append(waiter)
            }
        }
    }

    private func findCamera(timeout: TimeInterval) async throws -> DiscoveredCamera {
        discovered = []
        central.scanForPeripherals(withServices: [CanonBLE.sessionService],
                                   options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        defer { central.stopScan() }

        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if let pairing = discovered.first(where: { $0.advertisement?.isPairingMode == true }) { return pairing }
            if let last = discovered.first(where: { $0.id == CameraIdentity.lastPeripheralID }) { return last }
            try await Task.sleep(nanoseconds: 300_000_000)
        }
        if let best = discovered.max(by: { $0.rssi < $1.rssi }) { return best }

        let known = central.retrieveConnectedPeripherals(withServices: [CanonBLE.sessionService])
        if let peripheral = known.first {
            peripherals[peripheral.identifier] = peripheral
            return DiscoveredCamera(id: peripheral.identifier, name: peripheral.name ?? "Canon", advertisement: nil, rssi: 0)
        }
        throw BluetoothError.cameraNotFound
    }

    private func connect(_ target: CBPeripheral) async throws {
        peripheral = target
        target.delegate = self
        characteristics = [:]
        try await withTimeout(15, step: "Bluetooth 연결") { waiter in
            self.connectWaiter = waiter
            self.central.connect(target)
        }
        try await withTimeout(15, step: "카메라 기능 탐색") { waiter in
            self.discoveryWaiter = waiter
            target.discoverServices([CanonBLE.sessionService, CanonBLE.wifiService, CanonBLE.remoteService])
        }
        Logger.info("BLE connected, \(characteristics.count) characteristics", category: .bluetooth)
    }

    // MARK: - GATT helpers

    private func characteristic(_ uuid: CBUUID) throws -> (CBPeripheral, CBCharacteristic) {
        guard let peripheral, peripheral.state == .connected else { throw BluetoothError.notConnected }
        guard let characteristic = characteristics[uuid] else { throw BluetoothError.characteristicNotFound(uuid.uuidString) }
        return (peripheral, characteristic)
    }

    private func write(_ uuid: CBUUID, _ data: Data) async throws {
        let (peripheral, characteristic) = try characteristic(uuid)
        try await withTimeout(10, step: "Bluetooth 쓰기") { waiter in
            self.writeWaiters[uuid] = waiter
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
        }
    }

    private func read(_ uuid: CBUUID) async throws -> Data {
        let (peripheral, characteristic) = try characteristic(uuid)
        return try await withTimeout(10, step: "Bluetooth 읽기") { waiter in
            self.readWaiters[uuid] = waiter
            peripheral.readValue(for: characteristic)
        }
    }

    private func setNotify(_ uuid: CBUUID) async throws {
        let (peripheral, characteristic) = try characteristic(uuid)
        if characteristic.isNotifying { return }
        try await withTimeout(10, step: "Bluetooth 알림 설정") { waiter in
            self.notifyStateWaiters[uuid] = waiter
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }

    private func nextValue(_ uuid: CBUUID, timeout: TimeInterval, step: String) async throws -> Data {
        if var buffered = bufferedValues[uuid], !buffered.isEmpty {
            let value = buffered.removeFirst()
            bufferedValues[uuid] = buffered
            return value
        }
        return try await withTimeout(timeout, step: step) { waiter in
            self.valueWaiters[uuid] = waiter
        }
    }

    /// delegate 콜백 기반 작업을 continuation으로 감싸고 시간 제한을 둠
    private func withTimeout<T>(_ seconds: TimeInterval, step: String,
                                _ register: @escaping (Waiter<T>) -> Void) async throws -> T {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<T, Error>) in
            let waiter = Waiter(continuation)
            register(waiter)
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                waiter.fail(BluetoothError.timeout(step))
            }
        }
    }

    private func failAll(_ error: Error) {
        writeWaiters.values.forEach { $0.fail(error) }
        readWaiters.values.forEach { $0.fail(error) }
        notifyStateWaiters.values.forEach { $0.fail(error) }
        valueWaiters.values.forEach { $0.fail(error) }
        writeWaiters = [:]; readWaiters = [:]; notifyStateWaiters = [:]; valueWaiters = [:]
        connectWaiter?.fail(error); connectWaiter = nil
        discoveryWaiter?.fail(error); discoveryWaiter = nil
    }
}

/// 콜백과 타임아웃 중 먼저 온 쪽만 continuation을 resume
@MainActor
final class Waiter<T> {
    private var continuation: CheckedContinuation<T, Error>?

    init(_ continuation: CheckedContinuation<T, Error>) {
        self.continuation = continuation
    }

    func succeed(_ value: T) {
        continuation?.resume(returning: value)
        continuation = nil
    }

    func fail(_ error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}

// MARK: - CBCentralManagerDelegate

extension BluetoothManager: CBCentralManagerDelegate {
    nonisolated func centralManagerDidUpdateState(_ central: CBCentralManager) {
        MainActor.assumeIsolated {
            let waiters = stateWaiters
            stateWaiters = []
            switch central.state {
            case .poweredOn:
                waiters.forEach { $0.succeed(()) }
            case .unknown, .resetting:
                stateWaiters = waiters
            default:
                waiters.forEach { $0.fail(BluetoothError.unavailable("상태 \(central.state.rawValue)")) }
                failAll(BluetoothError.notConnected)
            }
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                                    advertisementData: [String: Any], rssi RSSI: NSNumber) {
        MainActor.assumeIsolated {
            let manufacturer = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data
            let advertisement = manufacturer.flatMap(CanonAdvertisement.init(manufacturerData:))
            let name = (advertisementData[CBAdvertisementDataLocalNameKey] as? String) ?? peripheral.name ?? "Canon"
            peripherals[peripheral.identifier] = peripheral
            let camera = DiscoveredCamera(id: peripheral.identifier, name: name, advertisement: advertisement, rssi: RSSI.intValue)
            if let index = discovered.firstIndex(where: { $0.id == camera.id }) {
                discovered[index] = camera
            } else {
                discovered.append(camera)
                Logger.info("BLE found \(name) pairing=\(advertisement?.isPairingMode.description ?? "?")", category: .bluetooth)
            }
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        MainActor.assumeIsolated {
            connectWaiter?.succeed(())
            connectWaiter = nil
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        MainActor.assumeIsolated {
            connectWaiter?.fail(BluetoothError.failed(error?.localizedDescription ?? "Bluetooth 연결 실패"))
            connectWaiter = nil
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        MainActor.assumeIsolated {
            Logger.warning("BLE disconnected \(error?.localizedDescription ?? "")", category: .bluetooth)
            connectedName = nil
            failAll(BluetoothError.notConnected)
        }
    }
}

// MARK: - CBPeripheralDelegate

extension BluetoothManager: CBPeripheralDelegate {
    nonisolated func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        MainActor.assumeIsolated {
            let services = peripheral.services ?? []
            if let error {
                discoveryWaiter?.fail(BluetoothError.failed(error.localizedDescription))
                discoveryWaiter = nil
                return
            }
            pendingServiceCount = services.count
            if services.isEmpty {
                discoveryWaiter?.fail(BluetoothError.characteristicNotFound(CanonBLE.sessionService.uuidString))
                discoveryWaiter = nil
            }
            services.forEach { peripheral.discoverCharacteristics(nil, for: $0) }
        }
    }

    nonisolated func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        MainActor.assumeIsolated {
            service.characteristics?.forEach { characteristics[$0.uuid] = $0 }
            pendingServiceCount -= 1
            if pendingServiceCount <= 0 {
                discoveryWaiter?.succeed(())
                discoveryWaiter = nil
            }
        }
    }

    nonisolated func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        MainActor.assumeIsolated {
            let waiter = writeWaiters.removeValue(forKey: characteristic.uuid)
            if let error {
                waiter?.fail(BluetoothError.failed(error.localizedDescription))
            } else {
                waiter?.succeed(())
            }
        }
    }

    nonisolated func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        MainActor.assumeIsolated {
            let waiter = notifyStateWaiters.removeValue(forKey: characteristic.uuid)
            if let error {
                waiter?.fail(BluetoothError.failed(error.localizedDescription))
            } else {
                waiter?.succeed(())
            }
        }
    }

    nonisolated func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        MainActor.assumeIsolated {
            let uuid = characteristic.uuid
            if let reader = readWaiters.removeValue(forKey: uuid) {
                if let error {
                    reader.fail(BluetoothError.failed(error.localizedDescription))
                } else {
                    reader.succeed(characteristic.value ?? Data())
                }
                return
            }
            guard error == nil, let value = characteristic.value else { return }
            if let waiter = valueWaiters.removeValue(forKey: uuid) {
                waiter.succeed(value)
            } else {
                bufferedValues[uuid, default: []].append(value)
            }
        }
    }
}
