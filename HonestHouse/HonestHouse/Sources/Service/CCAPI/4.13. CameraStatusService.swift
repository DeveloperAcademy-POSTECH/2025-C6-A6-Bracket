//
//  CameraStatusService.swift
//  HonestHouse
//
//  Created by Rama on 11/10/25.
//

import Foundation

protocol CameraStatusServiceType {
    func getPolling(timeout: TimeoutType) async throws
}

final class CameraStatusService: BaseService, CameraStatusServiceType {
    func getPolling(timeout: TimeoutType) async throws {
        try await request(CameraStatusTarget.getPolling(timeout))
    }
}

final class StubCameraStatusService: CameraStatusServiceType {
    func getPolling(timeout: TimeoutType) async throws {
    }
}
