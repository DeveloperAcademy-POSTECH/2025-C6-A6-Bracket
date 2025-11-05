//
//  Services.swift
//  HonestHouse
//
//  Created by Subeen on 10/23/25.
//

import Foundation
import SwiftData

protocol ServiceType {
    var shootingControlService: ShootingControlServiceType { get set }
    var shootingSettingsService: ShootingSettingsServiceType { get set }
    var imageOperationsService: ImageOperationsServiceType { get set }
    var liveViewService: LiveViewServiceType { get }
    var eventMonitorService: EventMonitorServiceType { get }
}

class Services: ServiceType {
    var shootingControlService: ShootingControlServiceType
    var shootingSettingsService: ShootingSettingsServiceType
    var imageOperationsService: ImageOperationsServiceType
    var liveViewService: LiveViewServiceType
    var eventMonitorService: EventMonitorServiceType

    init() {
        self.shootingControlService = ShootingControlService()
        self.shootingSettingsService = ShootingSettingsService()
        self.imageOperationsService = ImageOperationsService()
        self.liveViewService = LiveViewService()
        self.eventMonitorService = EventMonitorService()
    }
}

// MARK: - StubServices

class StubServices: ServiceType {
    var shootingControlService: ShootingControlServiceType = StubShootingControlService()
    var shootingSettingsService: ShootingSettingsServiceType = StubShootingSettingsService()
    var imageOperationsService: ImageOperationsServiceType = StubImageOperationsService()
    var liveViewService: LiveViewServiceType = StubLiveViewService()
    var eventMonitorService: EventMonitorServiceType = StubEventMonitorService()
}
