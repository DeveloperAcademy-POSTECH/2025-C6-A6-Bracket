//
//  Models.swift
//  HonestHouse
//
//  Created by Subeen on 11/4/25.
//

import Foundation
import SwiftUI

// MARK: - Enums
enum CameraMode: String, CaseIterable, Codable {
    case P = "P"
    case Av = "Av"
    case Tv = "Tv"
}

enum ViewMode {
    case view
    case edit
    case create
}

enum ButtonState {
    case active     // 흰색 - 수정 가능
    case disabled   // 검정색 - 비활성화/Auto
    case viewOnly   // 노란색 - 조회 전용
}

enum SettingType: String {
    case cameraMode = "Camera Mode"
    case aperture = "f"
    case shutterSpeed = "s"
    case iso = "ISO"
    case filter = "Filter"
    case exposure = "Exposure"
    case colorTemp = "Color Temp"
}

// MARK: - Data Model
struct CameraPreset: Identifiable, Codable {
    let id: UUID
    var name: String
    var cameraMode: CameraMode
    var aperture: Double?        // nil when Auto
    var shutterSpeed: Double?    // nil when Auto
    var iso: Int
    var filterEnabled: Bool
    var exposureCompensation: Double
    var colorTemperature: Int
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        cameraMode: CameraMode = .P,
        aperture: Double? = nil,
        shutterSpeed: Double? = nil,
        iso: Int = 400,
        filterEnabled: Bool = false,
        exposureCompensation: Double = 0.0,
        colorTemperature: Int = 5000,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.cameraMode = cameraMode
        self.aperture = aperture
        self.shutterSpeed = shutterSpeed
        self.iso = iso
        self.filterEnabled = filterEnabled
        self.exposureCompensation = exposureCompensation
        self.colorTemperature = colorTemperature
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    func copy() -> CameraPreset {
        CameraPreset(
            id: self.id,
            name: self.name,
            cameraMode: self.cameraMode,
            aperture: self.aperture,
            shutterSpeed: self.shutterSpeed,
            iso: self.iso,
            filterEnabled: self.filterEnabled,
            exposureCompensation: self.exposureCompensation,
            colorTemperature: self.colorTemperature,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

// MARK: - Camera Value Constants
struct CameraConstants {
    static let isoValues: [Int] = [100, 200, 400, 640, 800, 1000, 1600, 2000, 2500, 3200, 4000, 5000, 6400, 8000, 10000, 12800, 16000]
    
    static let apertureValues: [Double] = [1.2, 1.4, 1.6, 1.8, 2.0, 2.8, 4.0, 5.6, 8.0, 11.0, 16.0]
    
    static let shutterSpeedValues: [Double] = [
        1/8000, 1/6400, 1/5000, 1/4000, 1/3200, 1/2500, 1/2000, 1/1600,
        1/1250, 1/1000, 1/800, 1/640, 1/500, 1/400, 1/320, 1/250,
        1/200, 1/160, 1/125, 1/100, 1/80, 1/60, 1/50, 1/40,
        1/30, 1/25, 1/20, 1/15, 1/13, 1/10, 1/8, 1/6,
        1/5, 1/4, 0.3, 0.4, 0.5, 0.6, 0.8, 1, 1.3, 1.6, 2, 2.5, 3.2, 4, 5, 6, 8, 10, 13, 15, 20, 25, 30
    ]
    
    static let exposureCompensationRange: ClosedRange<Double> = -3.0...3.0
    static let exposureCompensationStep: Double = 0.3
    
    static let colorTemperatureRange: ClosedRange<Int> = 2000...10000
    static let colorTemperatureStep: Int = 100
}
