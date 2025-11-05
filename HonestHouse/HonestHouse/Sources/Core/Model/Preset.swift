//
//  Preset.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/27/25.
//

import Foundation

final class Preset: Hashable, Identifiable {
    
    var id: UUID
    var name: String
    var createdAt: Date
    var updatedAt: Date
    
    var pictureStyle: PictureStyleType
    var shootingMode: ShootingModeType
    
    var aperture: String?
    var shutterSpeed: String?
    var iso: String?
    var exposureCompensation: String?
    var colorTemperature: Int?
    var tintBlueAmber: Int?
    var tintMagentaGreen: Int?
    
    init(
        id: UUID = UUID(),
        name: String,
        pictureStyle: PictureStyleType,
        shootingMode: ShootingModeType,
        aperture: String? = nil,
        shutterSpeed: String? = nil,
        iso: String? = nil,
        exposureCompensation: String? = nil,
        colorTemperature: Int? = nil,
        tintBlueAmber: Int? = nil,
        tintMagentaGreen: Int? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.pictureStyle = pictureStyle
        self.shootingMode = shootingMode
        self.aperture = aperture
        self.shutterSpeed = shutterSpeed
        self.iso = iso
        self.exposureCompensation = exposureCompensation
        self.colorTemperature = colorTemperature
        self.tintBlueAmber = tintBlueAmber
        self.tintMagentaGreen = tintMagentaGreen
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    func copy() -> Preset {
        Preset(
            id: self.id,
            name: self.name,
            pictureStyle: self.pictureStyle,
            shootingMode: self.shootingMode,
            aperture: self.aperture,
            shutterSpeed: self.shutterSpeed,
            iso: self.iso,
            exposureCompensation: self.exposureCompensation,
            colorTemperature: self.colorTemperature,
            tintBlueAmber: self.tintBlueAmber,
            tintMagentaGreen: self.tintMagentaGreen,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension Preset {
    static func == (lhs: Preset, rhs: Preset) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Preset {
    // TODO: 추후 UIAdapter 등으로 분리 요망
    var modeDescription: String? {
        let apertureValue = aperture ?? "Auto"
        let shutterSpeedValue = shutterSpeed ?? "Auto"
        
        switch shootingMode {
        case .av: return "F:[\(apertureValue.suffix(3))]"
        case .tv: return "S:[\(shutterSpeedValue)]"
        case .p: return nil
        }
    }
    
    var isoDescription: String {
        let isoValue = iso ?? "Auto"
        
        return "ISO:[\(isoValue)]"
    }
}

extension Preset {
    static var stub1: Preset {
        .init(
            id: .init(),
            name: "프리셋1",
            pictureStyle: .auto,
            shootingMode: .av,
            aperture: "1",
            shutterSpeed: "1/100",
            iso: "1000",
            exposureCompensation: "1/3",
            colorTemperature: 3400,
            tintBlueAmber: 10,
            tintMagentaGreen: 10,
            createdAt: .init(),
            updatedAt: .init()
        )
    }
    
    static var stub2: Preset {
        .init(
            id: .init(),
            name: "프리셋2",
            pictureStyle: .faithful,
            shootingMode: .p,
            aperture: "10",
            shutterSpeed: "1/1000",
            iso: "4000",
            exposureCompensation: "0",
            colorTemperature: 3400,
            tintBlueAmber: 10,
            tintMagentaGreen: 10,
            createdAt: .init(),
            updatedAt: .init()
        )
    }
    
    static var stub3: Preset {
        .init(
            id: .init(),
            name: "프리셋3",
            pictureStyle: .landscape,
            shootingMode: .tv,
            aperture: "22",
            shutterSpeed: "1/10",
            iso: "auto",
            exposureCompensation: "-1/3",
            colorTemperature: 4800,
            tintBlueAmber: 20,
            tintMagentaGreen: -10,
            createdAt: .init(),
            updatedAt: .init()
        )
    }
}

