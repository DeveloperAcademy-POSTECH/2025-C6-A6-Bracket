//
//  CanonPTPSession.swift
//  HonestHouse
//
//  Camera Connect와 같은 순서로 캐논 PTP/IP 세션을 열고 촬영·라이브뷰·이벤트를 처리
//

import Foundation

actor CanonPTPSession {
    private let connection: PTPIPConnection
    private var keepAliveTask: Task<Void, Never>?
    private var eventTask: Task<Void, Never>?

    private(set) var deviceInfo: PTPDeviceInfo?
    private(set) var remoteMode: UInt32 = PTPCode.remoteModeWiFi
    var evfOutputDevice: UInt32 = 2

    init(host: String, guid: Data, name: String, port: UInt16 = PTPIPConnection.defaultPort) {
        connection = PTPIPConnection(host: host, port: port, guid: guid, name: name)
    }

    func setEVFOutputDevice(_ value: UInt32) {
        evfOutputDevice = value
    }

    func supports(_ opcode: UInt16) -> Bool {
        deviceInfo?.operations.contains(opcode) ?? true
    }

    // MARK: - Session

    func open() async throws {
        try await connection.connect()
        try await connection.transaction(PTPCode.openSession, [PTPCode.sessionID], transactionID: 0)
        deviceInfo = PTPDataset.deviceInfo(try await connection.transaction(PTPCode.getDeviceInfo).data)
        try await enterRemoteMode()
        try await connection.transaction(PTPCode.canonSetEventMode, [PTPCode.eventModePTPIP])
        _ = try await events()
        startBackgroundTasks()
    }

    func close() async {
        keepAliveTask?.cancel()
        eventTask?.cancel()
        _ = try? await connection.transaction(PTPCode.canonSetEventMode, [0], check: false)
        _ = try? await connection.transaction(PTPCode.canonSetRemoteMode, [0], check: false)
        _ = try? await connection.transaction(PTPCode.closeSession, check: false)
        await connection.close()
    }

    private func enterRemoteMode() async throws {
        for _ in 0..<10 {
            let response = try await connection.transaction(PTPCode.canonSetRemoteMode, [remoteMode], check: false)
            if response.code == PTPCode.ok { return }
            if response.code == PTPCode.deviceBusy {
                try await Task.sleep(nanoseconds: 200_000_000)
                continue
            }
            if remoteMode != PTPCode.remoteModeDefault {
                remoteMode = PTPCode.remoteModeDefault
                continue
            }
            throw PTPIPError.response(opcode: PTPCode.canonSetRemoteMode, code: response.code)
        }
    }

    private func startBackgroundTasks() {
        let connection = connection
        keepAliveTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                guard !Task.isCancelled else { return }
                _ = try? await connection.transaction(PTPCode.canonKeepAlive, check: false)
            }
        }
        eventTask = Task {
            while !Task.isCancelled {
                do {
                    _ = try await connection.readEvent()
                } catch {
                    return
                }
            }
        }
    }

    // MARK: - Events

    func events() async throws -> [(type: UInt32, body: Data)] {
        var all: [(type: UInt32, body: Data)] = []
        while true {
            let (records, more) = PTPDataset.eventRecords(try await connection.transaction(PTPCode.canonGetEvent).data)
            all += records
            if !more { return all }
        }
    }

    func waitForNewObjects(timeout: TimeInterval = 10) async throws -> [PTPObjectInfo] {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            let objects = try await events().compactMap { PTPDataset.objectAdded(type: $0.type, record: $0.body) }
            if !objects.isEmpty { return objects }
            try await Task.sleep(nanoseconds: 300_000_000)
        }
        return []
    }

    // MARK: - Shooting

    func shoot(autoFocus: Bool = true) async throws {
        if supports(PTPCode.canonRemoteReleaseOn) {
            try await connection.transaction(PTPCode.canonRemoteReleaseOn, [PTPCode.releaseHalfFull, autoFocus ? 0 : 1])
            try await Task.sleep(nanoseconds: 200_000_000)
            try await connection.transaction(PTPCode.canonRemoteReleaseOff, [PTPCode.releaseHalfFull])
        } else {
            try await connection.transaction(PTPCode.canonRemoteRelease)
        }
    }

    // MARK: - Live view

    func setProperty(_ property: UInt32, value: UInt32) async throws {
        var payload = Data()
        payload.appendLE(UInt32(12))
        payload.appendLE(property)
        payload.appendLE(value)
        try await connection.transaction(PTPCode.canonSetDevicePropValueEx, dataOut: payload)
    }

    func startLiveView() async throws {
        try await setProperty(PTPCode.propEVFOutputDevice, value: evfOutputDevice)
    }

    func stopLiveView() async {
        try? await setProperty(PTPCode.propEVFOutputDevice, value: 0)
    }

    /// 프레임 하나. 카메라가 아직 준비되지 않았으면 nil
    func liveViewFrame() async throws -> Data? {
        let mobile: UInt32 = (evfOutputDevice & 0xC) != 0 && (evfOutputDevice & 2) == 0 ? 1 : 0
        let response = try await connection.transaction(PTPCode.canonGetViewFinderData, [0x0020_0000, mobile, 0], check: false)
        if response.code == PTPCode.canonEVFNotReady || response.data.isEmpty { return nil }
        guard response.code == PTPCode.ok else {
            throw PTPIPError.response(opcode: PTPCode.canonGetViewFinderData, code: response.code)
        }
        return PTPDataset.evfJPEG(response.data)
    }
}
