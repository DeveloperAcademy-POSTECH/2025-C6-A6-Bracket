//
//  WBShiftResponse.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

extension ShootingSettings {
    /// 4.9.25 화이트 밸런스 보정
    struct WBShiftResponse: BaseResponse {
        let value: Value?
        let ability: Ability?
    }
}

extension ShootingSettings.WBShiftResponse {
    struct Value: Codable {
        let blueAmber: Int?
        let magentaGreen: Int?

        enum CodingKeys: String, CodingKey {
            case blueAmber = "ba"
            case magentaGreen = "mg"
        }
    }
}

extension ShootingSettings.WBShiftResponse {
    struct Ability: Codable {
        let blueAmberAbility: Range?
        let magentaGreenAbility: Range?

        enum CodingKeys: String, CodingKey {
            case blueAmberAbility = "ba"
            case magentaGreenAbility = "mg"
        }
    }
}

extension ShootingSettings.WBShiftResponse.Ability {
    struct Range: Codable {
        let min: Int?
        let max: Int?
        let step: Int?
    }
}

extension ShootingSettings.WBShiftResponse {
    typealias EntityType = WBShift
    
    func toEntity() -> WBShift {
        // map을 체이닝해서 깔끔하게 처리
        let entityValue = value.map { responseValue in
            WBShift.Value(
                blueAmber: responseValue.blueAmber,
                magentaGreen: responseValue.magentaGreen
            )
        }
        
        let entityAbility = ability.map { list in
            WBShift.Ability(
                blueAmberAbility: list.blueAmberAbility.map { range in
                    WBShift.Ability.Range(
                        min: range.min,
                        max: range.max,
                        step: range.step
                    )
                },
                magentaGreenAbility: list.magentaGreenAbility.map { range in
                    WBShift.Ability.Range(
                        min: range.min,
                        max: range.max,
                        step: range.step
                    )
                }
            )
        }
        
        return WBShift(value: entityValue, ability: entityAbility)
    }
    
    static var stub1: ShootingSettings.WBShiftResponse {
        .init(
            value: .init(
                blueAmber: 0,
                magentaGreen: 0
            ),
            ability: .init(
                blueAmberAbility: .init(
                    min: 0,
                    max: 0,
                    step: 0
                ),
                magentaGreenAbility: .init(
                    min: 0,
                    max: 0,
                    step: 0
                )
            )
        )
    }
}
