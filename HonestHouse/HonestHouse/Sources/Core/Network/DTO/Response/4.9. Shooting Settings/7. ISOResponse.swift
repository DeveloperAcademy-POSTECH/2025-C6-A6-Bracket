//
//  ISOResponse.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

extension ShootingSettings {
    /// 4.9.7 ISO
    struct ISOResponse: BaseResponse {
        let value: String?
        let ability: [String]?
    }
}

extension ShootingSettings.ISOResponse {
    typealias EntityType = ISO
    
    func toEntity() -> ISO {
        ISO(
            value: value,
            ability: ability
        )
    }
    
    static var stub1: ShootingSettings.ISOResponse {
        .init(
            value: "",
            ability: [""]
        )
    }
}
