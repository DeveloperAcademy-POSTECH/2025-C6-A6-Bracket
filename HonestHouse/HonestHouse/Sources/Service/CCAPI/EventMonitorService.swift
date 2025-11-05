//
//  EventMonitorService.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/30/25.
//

import Foundation

protocol EventMonitorServiceType {
    func startMonitoring(
        onEvent: @escaping (CameraStatus.EventMonitorResponse) -> Void,
        onError: @escaping (Error) -> Void
    ) async -> Bool
    func stopMonitoring() async throws
}

final class EventMonitorService: StreamService, EventMonitorServiceType {
    override init() {
        super.init()
    }

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
        /// 최소 크기 확인
        guard buffer.count >= 2 else {
            return nil
        }
        
        /// Start Byte 검증
        let firstByte = buffer[0]
        let secondByte = buffer[1]
        
        guard firstByte == 0xFF && secondByte == 0x00 else {
            /// Invalid Start Byte - 첫 바이트 제거하고 재시도
            print("❌ Invalid start bytes, removing first byte")
            buffer.removeFirst()
            return nil
        }
        
        /// 전체 헤더 크기 확인
        guard buffer.count >= 9 else {
            return nil
        }
        
        /// Data Type 검증
        guard buffer[2] == 0x02 else {
            buffer.removeFirst(3)
            return nil
        }
        
        // Data Type Checked -> Event Data
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
            // Invalid End Byte
            buffer.removeFirst(7)
            return nil
        }
        
        // Valid End Byte
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

final class StubEventMonitorService: EventMonitorServiceType {
    func startMonitoring(
        onEvent: @escaping (CameraStatus.EventMonitorResponse) -> Void,
        onError: @escaping (Error) -> Void
    ) async -> Bool {
        return true
    }

    func stopMonitoring() async throws {
    }
}
