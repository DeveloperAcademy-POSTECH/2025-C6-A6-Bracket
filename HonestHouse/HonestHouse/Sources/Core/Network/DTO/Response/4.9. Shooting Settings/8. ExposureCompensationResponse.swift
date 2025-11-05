//
//  ExposureCompensationResponse.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

extension ShootingSettings {
    /// 4.9.8. 노출 보정
    struct ExposureCompensationResponse: BaseResponse {
        let value: String?
        let ability: [String]?
    }
}

extension ShootingSettings.ExposureCompensationResponse {
    typealias EntityType = ExposureCompensation
    
    func toEntity() -> ExposureCompensation {
        ExposureCompensation(
            value: value,
            ability: ability
        )
    }
    
    static var stub1: ShootingSettings.ExposureCompensationResponse {
        .init(
            value: "",
            ability: [""]
        )
    }
}
