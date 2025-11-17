//
//  WiFiMonitorManager.swift
//  HonestHouse
//
//  Created by BoMin Lee on 11/16/25.
//

import Foundation
import Network

final class WiFiMonitorManager {
    static let shared = WiFiMonitorManager()

    private let monitorQueue = DispatchQueue(label: "wifi.monitor", qos: .userInitiated)

    private init() {}

    func checkConnection() async -> Bool {
        guard !BaseURLConstants.cameraIP.isEmpty else {
            return false
        }

        let host = BaseURLConstants.cameraIP
        let port = UInt16(BaseURLConstants.port) ?? 8080

        return await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
            var isResumed = false

            let connection = NWConnection(
                host: NWEndpoint.Host(host),
                port: NWEndpoint.Port(integerLiteral: port),
                using: .tcp
            )

            let timeout = DispatchWorkItem { [weak connection] in
                guard !isResumed else { return }
                isResumed = true
                connection?.cancel()
                continuation.resume(returning: false)
            }

            monitorQueue.asyncAfter(deadline: .now() + 2.0, execute: timeout)

            connection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    guard !isResumed else { return }
                    isResumed = true
                    timeout.cancel()
                    connection.cancel()
                    continuation.resume(returning: true)
                case .failed, .cancelled:
                    guard !isResumed else { return }
                    isResumed = true
                    timeout.cancel()
                    continuation.resume(returning: false)
                default:
                    break
                }
            }

            connection.start(queue: self.monitorQueue)
        }
    }
}
