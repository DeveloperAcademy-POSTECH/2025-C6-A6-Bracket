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

    private var lastDataReceivedAt: Date = Date()
    private var connectionCheckTimer: Timer?
    private let connectionTimeout: TimeInterval = 2.0
    
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
//        Logger.info("Starting event monitoring", category: .eventMonitor)
        await parser.reset()
        lastDataReceivedAt = Date()

        let result = await startStreaming(
            onDataReceived: { [weak self] data in
                guard let self = self else { return }
                // 데이터 도착 시간 업데이트
                self.lastDataReceivedAt = Date()
//                Logger.debug("EventMonitor data received: \(data.count) bytes - timer reset", category: .eventMonitor)
                
//                Logger.debug("EventMonitor received data: \(data.count) bytes", category: .eventMonitor)
                Task {
                    await self.parser.appendChunk(data)
                    let events = await self.parser.extractEvents()
                    if !events.isEmpty {
//                        Logger.info("Parsed \(events.count) event(s)", category: .eventMonitor)
                        await MainActor.run {
                            for event in events {
                                onEvent(event)
                            }
                        }
                    }
                    else {
//                        Logger.debug("No events extracted from chunk", category: .eventMonitor)
                    }
                }
            },
            onError: { [weak self] error in
//                Logger.error("EventMonitor error: \(error.localizedDescription)", category: .eventMonitor)
                self?.stopConnectionCheckTimer()
                onError(error)
            }
        )
        
        if result {
            startConnectionCheckTimer(onError: onError)
        }
        
//        Logger.info("Event monitoring start result: \(result)", category: .eventMonitor)
        return result
    }

    func stopMonitoring() async throws {
        stopConnectionCheckTimer()
        try await stopStreaming()
        await parser.reset()
    }
    
    private func startConnectionCheckTimer(onError: @escaping (Error) -> Void) {
        stopConnectionCheckTimer()
        
//        Logger.info("Starting connection check timer (timeout: \(connectionTimeout)s)", category: .eventMonitor)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.connectionCheckTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                
                let timeSinceLastData = Date().timeIntervalSince(self.lastDataReceivedAt)
//                Logger.debug("Connection check: \(String(format: "%.1f", timeSinceLastData))s since last data", category: .eventMonitor)
                
                if timeSinceLastData >= self.connectionTimeout {
//                    Logger.error("Connection lost - no data received for \(String(format: "%.1f", timeSinceLastData))s", category: .eventMonitor)
                    self.stopConnectionCheckTimer()
                    
                    let error = CCAPIError.networkError(URLError(.networkConnectionLost))
                    onError(error)
                }
            }
        }
    }
    
    private func stopConnectionCheckTimer() {
        DispatchQueue.main.async { [weak self] in
            self?.connectionCheckTimer?.invalidate()
            self?.connectionCheckTimer = nil
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
