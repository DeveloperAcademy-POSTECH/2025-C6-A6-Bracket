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
    private lazy var parser: EventMonitorParser = {
        return EventMonitorParser()
    }()

    override init() {
        super.init()
    }

    override var endpoint: String {
        guard let cameraType = CameraType.current else {
            return "ver100/event/monitoring"
        }

        let version = cameraType.eventMonitorVersion
        return "\(version.description)/event/monitoring"
    }

    override var httpMethod: String {
        return "GET"
    }

    @discardableResult
    func startMonitoring(
        onEvent: @escaping (CameraStatus.EventMonitorResponse) -> Void,
        onError: @escaping (Error) -> Void
    ) async -> Bool {
        await parser.reset()

        return await startStreaming(
            onDataReceived: { [weak self] data in
                guard let self = self else { return }
                Task {
                    await self.parser.appendChunk(data)
                    let events = await self.parser.extractEvents()
                    if !events.isEmpty {
                        Logger.debug("Parsed \(events.count) event(s)", category: .eventMonitor)
                        await MainActor.run {
                            for event in events {
                                onEvent(event)
                            }
                        }
                    }
                }
            },
            onError: onError
        )
    }

    func stopMonitoring() async throws {
        try await stopStreaming()
        await parser.reset()
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
