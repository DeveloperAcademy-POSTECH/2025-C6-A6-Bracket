//
//  Preset.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/27/25.
//

import SwiftData
import Foundation

@Model
final class Preset: Hashable {
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Private Storage (SwiftData 저장용)
    private var pictureStyleRawValue: String
    private var shootingModeRawValue: String

    // MARK: - Computed Properties (사용자 접근용)
    @Transient
    var pictureStyle: PictureStyleType {
        get {
            guard let style = PictureStyleType(rawValue: pictureStyleRawValue) else {
                fatalError("Invalid picture style: \(pictureStyleRawValue)")
            }
            return style
        }
        set {
            pictureStyleRawValue = newValue.rawValue
        }
    }

    @Transient
    var shootingMode: ShootingModeType {
        get {
            guard let mode = ShootingModeType(rawValue: shootingModeRawValue) else {
                fatalError("Invalid shooting mode: \(shootingModeRawValue)")
            }
            return mode
        }
        set {
            shootingModeRawValue = newValue.rawValue
        }
    }

    // MARK: - Optional Settings
    var aperture: String?
    var shutterSpeed: String?
    var iso: String?

    var exposureCompensation: String?
    var colorTemperature: Int?

    var tintBlueAmber: Int?
    var tintMagentaGreen: Int?
    
    var isSelected: Bool

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
        updatedAt: Date = Date(),
        isSelected: Bool = false
    ) {
        self.id = id
        self.name = name
        self.pictureStyleRawValue = pictureStyle.rawValue
        self.shootingModeRawValue = shootingMode.rawValue
        self.aperture = aperture
        self.shutterSpeed = shutterSpeed
        self.iso = iso
        self.exposureCompensation = exposureCompensation
        self.colorTemperature = colorTemperature
        self.tintBlueAmber = tintBlueAmber
        self.tintMagentaGreen = tintMagentaGreen
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isSelected = isSelected
    }
}

// MARK: - Hashable Conformance
extension Preset {
    static func == (lhs: Preset, rhs: Preset) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Preset {
    var settingsDescription: String {
        let apertureValue = aperture ?? "Auto"
        let isoValue = iso ?? "Auto"
        return "F: [\(apertureValue)] ISO: [\(isoValue)]"
    }
}

extension Preset {

    static var stub1: Preset {
        .init(id: .init(), name: "프리셋1", pictureStyle: .auto, shootingMode: .av, aperture: "1", shutterSpeed: "1/100", iso: "1000", exposureCompensation: "1/3", colorTemperature: 3400, tintBlueAmber: 10, tintMagentaGreen: 10, createdAt: .init(), updatedAt: .init())
    }
    
    static var stub2: Preset {
        .init(id: .init(), name: "프리셋2", pictureStyle: .faithful, shootingMode: .p, aperture: "10", shutterSpeed: "1/1000", iso: "4000", exposureCompensation: "0", colorTemperature: 3400, tintBlueAmber: 10, tintMagentaGreen: 10, createdAt: .init(), updatedAt: .init())
    }
    
    static var stub3: Preset {
        .init(id: .init(), name: "프리셋3", pictureStyle: .landscape, shootingMode: .tv, aperture: "22", shutterSpeed: "1/10", iso: "auto", exposureCompensation: "-1/3", colorTemperature: 4800, tintBlueAmber: 20, tintMagentaGreen: -10, createdAt: .init(), updatedAt: .init())
    }
}
