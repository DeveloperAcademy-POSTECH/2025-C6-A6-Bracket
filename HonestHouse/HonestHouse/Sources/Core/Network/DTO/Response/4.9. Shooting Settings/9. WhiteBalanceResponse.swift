//
//  WhiteBalanceResponse.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

extension ShootingSettings {
    /// 4.9.9. 화이트밸런스
    struct WhiteBalanceResponse: BaseResponse {
        let value: String?
        let ability: [String]?
    }
}

extension ShootingSettings.WhiteBalanceResponse {
    typealias EntityType = WhiteBalance
    
    func toEntity() -> WhiteBalance {
        WhiteBalance(
            value: value,
            ability: ability
        )
    }
    
    static var stub1: ShootingSettings.WhiteBalanceResponse {
        .init(
            value: "",
            ability: [""]
        )
    }
}
