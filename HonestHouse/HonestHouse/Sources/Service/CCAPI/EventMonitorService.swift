//
//  EventMonitorService.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/30/25.
//

import Foundation

class EventMonitorService: StreamService {
    // MARK: - Singleton
    // TODO: 현재 빠른 테스트를 위해서 싱글톤 -> 추후 다른 서비스와 같이 주입하는 방식으로 변경 필요
    static let shared = EventMonitorService()

    private override init() {
        super.init()
    }

    // MARK: - Configuration Override
    override var endpoint: String {
        return "ver100/event/monitoring"
    }

    override var httpMethod: String {
        return "GET"
    }

    @discardableResult
    func startMonitoring(
        onEvent: @escaping (CameraStatus.EventMonitorResponse) -> Void,
        onError: @escaping (Error) -> Void
    ) async -> Bool {
        return await startStreaming(
            onData: { [weak self] data in
                self?.handleReceivedData(data, onEvent: onEvent)
            },
            onError: onError
        )
    }

    func stopMonitoring() async throws {
        try await stopStreaming()
    }

    private func handleReceivedData(_ data: Data, onEvent: @escaping (CameraStatus.EventMonitorResponse) -> Void) {
        var buffer = data

        while let event = parseEventData(&buffer) {
            onEvent(event)
        }
    }

    private func parseEventData(_ buffer: inout Data) -> CameraStatus.EventMonitorResponse? {
        guard buffer.count >= 9 else {
            /// buffer가 너무 작아서 데이터를 더 기다려야 함.
            return nil
        }

        guard buffer[0] == 0xFF && buffer[1] == 0x00 else {
            /// Invalid Start Byte
            if let startIndex = buffer.firstIndex(where: { $0 == 0xFF }) {
                buffer = buffer.suffix(from: startIndex)
            } else {
                buffer.removeAll()
            }
            return nil
        }
        /// Valid Start Byte
        guard buffer[2] == 0x02 else {
            buffer.removeFirst(3)
            return nil
        }
        
        /// Data Type Checked -> Event Data
        let dataSize = UInt32(buffer[3]) << 24 |
                      UInt32(buffer[4]) << 16 |
                      UInt32(buffer[5]) << 8 |
                      UInt32(buffer[6])

        let totalSize = 7 + Int(dataSize) + 2

        guard buffer.count >= totalSize else {
            return nil
        }

        let endByteIndex = 7 + Int(dataSize)
        guard buffer[endByteIndex] == 0xFF && buffer[endByteIndex + 1] == 0xFF else {
            /// Invalid End Byte
            buffer.removeFirst(7)
            return nil
        }
        /// Valid End Byte
        let jsonData = buffer[7..<(7 + Int(dataSize))]

        buffer.removeFirst(totalSize)

        do {
            let decoder = JSONDecoder()
            let event = try decoder.decode(CameraStatus.EventMonitorResponse.self, from: jsonData)
            
            return event
        } catch {
            return nil
        }
    }
}
