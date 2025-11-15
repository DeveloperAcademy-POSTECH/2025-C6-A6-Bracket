//
//  Int+Extension.swift
//  HonestHouse
//
//  Created by Subeen on 11/16/25.
//

extension Int {
    var withSign: String {
        switch self {
        case 0:
            return "0"  // 또는 "􀛺0"
        case let x where x > 0:
            return "+\(x)"
        default:
            return "\(self)"
        }
    }
}
