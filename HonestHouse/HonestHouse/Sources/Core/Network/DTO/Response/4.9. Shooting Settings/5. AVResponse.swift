//
//  AVResponse.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

extension ShootingSettings {
    /// 4.9.5. AV 조리개
    struct AVResponse: BaseResponse {
        let value: String?
        let ability: [String]?
    }
}

extension ShootingSettings.AVResponse {
    typealias EntityType = AV
    
    func toEntity() -> AV {
        AV(
            value: value,
            ability: ability
        )
    }
    
    static var stub1: ShootingSettings.AVResponse {
        .init(
            value: "",
            ability: [""]
        )
    }
}
