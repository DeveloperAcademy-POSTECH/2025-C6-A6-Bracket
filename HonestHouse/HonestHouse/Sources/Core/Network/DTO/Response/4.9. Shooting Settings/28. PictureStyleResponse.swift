//
//  PictureStyleResponse.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/24/25.
//

extension ShootingSettings {
    /// 4.9.28. Picture Style 픽쳐스타일
    struct PictureStyleResponse: BaseResponse {
        let value: String?
        let ability: [String]?
    }
}

extension ShootingSettings.PictureStyleResponse {
    typealias EntityType = PictureStyle
    
    func toEntity() -> PictureStyle {
        PictureStyle(
            value: value,
            ability: ability
        )
    }
    
    static var stub1: ShootingSettings.PictureStyleResponse {
        .init(
            value: "",
            ability: [""]
        )
    }
}
