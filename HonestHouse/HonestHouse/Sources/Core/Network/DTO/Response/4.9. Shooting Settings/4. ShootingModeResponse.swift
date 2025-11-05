//
//  ShootingModeResponse.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

extension ShootingSettings {
    /// 4.9.2. Get / Change shooting mode (models with a shooting mode dial)
    struct ShootingModeResponse: BaseResponse {
        let value: String?
    }
}

extension ShootingSettings.ShootingModeResponse {
    typealias EntityType = ShootingMode
    
    func toEntity() -> ShootingMode {
        ShootingMode(value: value)
    }

    static var stub1: ShootingSettings.ShootingModeResponse {
        .init(value: "")
    }
}

