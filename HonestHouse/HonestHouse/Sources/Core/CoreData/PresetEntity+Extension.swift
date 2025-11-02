//
//  PresetEntity+Extension.swift
//  HonestHouse
//
//  Created by Subeen on 11/3/25.
//

import Foundation
import CoreData

extension PresetEntity {
    /// CoreData Entity를 Preset 모델로 변환
    func toPreset() -> Preset {
        guard let presetId = self.presetId,
              let name = self.name,
              let pictureStyleRaw = self.pictureStyle,
              let shootingModeRaw = self.shootingMode,
              let createdAt = self.createdAt,
              let updatedAt = self.updatedAt else {
            fatalError("PresetEntity의 필수 속성이 nil입니다.")
        }
        
        guard let pictureStyle = PictureStyleType(rawValue: pictureStyleRaw),
              let shootingMode = ShootingModeType(rawValue: shootingModeRaw) else {
            fatalError("Invalid enum rawValue - pictureStyle: \(pictureStyleRaw), shootingMode: \(shootingModeRaw)")
        }
        
        return Preset(
            id: presetId,
            name: name,
            pictureStyle: pictureStyle,
            shootingMode: shootingMode,
            aperture: self.aperture,
            shutterSpeed: self.shutterSpeed,
            iso: self.iso,
            exposureCompensation: self.exposureCompensation,
            colorTemperature: self.colorTemperature == 0 ? nil : Int(self.colorTemperature),
            tintBlueAmber: self.tintBlueAmber == 0 ? nil : Int(self.tintBlueAmber),
            tintMagentaGreen: self.tintMagentaGreen == 0 ? nil : Int(self.tintMagentaGreen),
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
