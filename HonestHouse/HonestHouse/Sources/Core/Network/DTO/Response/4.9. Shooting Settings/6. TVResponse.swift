//
//  TVResponse.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

extension ShootingSettings {
    /// 4.9.6. TV 셔터스피드
    struct TVResponse: BaseResponse {
        let value: String?
        let ability: [String]?
    }
}

extension ShootingSettings.TVResponse {
    typealias EntityType = TV
    
    func toEntity() -> TV {
        TV(
            value: value,
            ability: ability
        )
    }
    
    static var stub1: ShootingSettings.TVResponse {
        .init(
            value: "",
            ability: [""]
        )
    }
}
