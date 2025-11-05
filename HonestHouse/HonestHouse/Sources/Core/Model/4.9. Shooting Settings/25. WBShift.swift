//
//  WBShift.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

struct WBShift {
    let value: Value?
    let ability: Ability?
}

extension WBShift {
    struct Value: Codable {
        let blueAmber: Int?
        let magentaGreen: Int?
    }
}
    
extension WBShift {
    struct Ability: Codable {
        let blueAmberAbility: Range?
        let magentaGreenAbility: Range?
    }
}

extension WBShift.Ability {
    struct Range: Codable {
        let min: Int?
        let max: Int?
        let step: Int?
    }
}

