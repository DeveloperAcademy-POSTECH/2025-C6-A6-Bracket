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
    
    case tint = "Tint"
    case exposure = "Exp"
    case colorTemp = "Temp"
}

struct CameraPreset: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var cameraMode: CameraMode
    var aperture: Double
    var shutterSpeed: Double 
    var iso: Int
    var filter: String
    
    var tint: Int
    var exposureCompensation: Double
    var colorTemperature: Int
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        cameraMode: CameraMode = .P,
        aperture: Double = 1.0,
        shutterSpeed: Double = 30,
        iso: Int = 400,
        filter: String = "",
        
        tint: Int = 0,
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
        self.filter = filter
        
        self.tint = tint
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
            filter: self.filter,
            
            tint: self.tint,
            exposureCompensation: self.exposureCompensation,
            colorTemperature: self.colorTemperature,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}
