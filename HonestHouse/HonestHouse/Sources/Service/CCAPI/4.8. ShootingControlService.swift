//
//  ShootingControlService.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/29/25.
//

import Foundation

protocol ShootingControlServiceType {
    func ignoreShootingMode(request: ShootingControl.IgnoreShootingModeRequest) async throws
}

final class ShootingControlService: BaseService, ShootingControlServiceType {
    func ignoreShootingMode(request: ShootingControl.IgnoreShootingModeRequest) async throws {
        try await self.request(ShootingControlTarget.ignoreShootingMode(request))
    }
}

final class StubShootingControlService: ShootingControlServiceType {
    func ignoreShootingMode(request: ShootingControl.IgnoreShootingModeRequest) async throws {
    }
}
