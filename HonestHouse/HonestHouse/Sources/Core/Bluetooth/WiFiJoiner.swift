//
//  WiFiJoiner.swift
//  HonestHouse
//
//  BLE로 받은 카메라 Wi-Fi 정보로 자동 접속하고, 카메라 포트에 닿을 때까지 대기
//

import Foundation
import Network
import NetworkExtension

enum WiFiJoinError: LocalizedError {
    case missingSSID
    case joinFailed(String)
    case unreachable(String, UInt16)

    var errorDescription: String? {
        switch self {
        case .missingSSID: return "카메라 Wi-Fi 이름을 받지 못했습니다."
        case .joinFailed(let reason): return "카메라 Wi-Fi 접속에 실패했습니다. (\(reason))"
        case .unreachable(let host, let port): return "카메라(\(host):\(port))에 연결할 수 없습니다."
        }
    }
}

enum WiFiJoiner {
    static func join(_ info: CameraWiFiInfo) async throws {
        guard let ssid = info.ssid, !ssid.isEmpty else { throw WiFiJoinError.missingSSID }
        let configuration: NEHotspotConfiguration
        if let password = info.password, !password.isEmpty {
            configuration = NEHotspotConfiguration(ssid: ssid, passphrase: password, isWEP: false)
        } else {
            configuration = NEHotspotConfiguration(ssid: ssid)
        }
        configuration.joinOnce = false
        do {
            try await NEHotspotConfigurationManager.shared.apply(configuration)
        } catch let error as NSError where error.domain == NEHotspotConfigurationErrorDomain
                    && error.code == NEHotspotConfigurationError.alreadyAssociated.rawValue {
            return
        } catch {
            throw WiFiJoinError.joinFailed(error.localizedDescription)
        }
    }

    /// Wi-Fi 전환 직후에는 바로 붙지 않을 수 있어 일정 시간 재시도
    static func waitUntilReachable(host: String, port: UInt16, timeout: TimeInterval = 15) async throws {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if await isReachable(host: host, port: port) { return }
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }
        throw WiFiJoinError.unreachable(host, port)
    }

    static func isReachable(host: String, port: UInt16, timeout: TimeInterval = 2) async -> Bool {
        await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
            let queue = DispatchQueue(label: "wifi.reachability")
            let connection = NWConnection(host: NWEndpoint.Host(host), port: NWEndpoint.Port(rawValue: port)!, using: .tcp)
            let state = ReachabilityState()
            connection.stateUpdateHandler = { newState in
                switch newState {
                case .ready:
                    state.finish(true, connection, continuation)
                case .failed, .cancelled:
                    state.finish(false, connection, continuation)
                default:
                    break
                }
            }
            connection.start(queue: queue)
            queue.asyncAfter(deadline: .now() + timeout) {
                state.finish(false, connection, continuation)
            }
        }
    }
}

/// 연결 큐에서만 접근
private final class ReachabilityState: @unchecked Sendable {
    private var finished = false

    func finish(_ result: Bool, _ connection: NWConnection, _ continuation: CheckedContinuation<Bool, Never>) {
        guard !finished else { return }
        finished = true
        connection.cancel()
        continuation.resume(returning: result)
    }
}
