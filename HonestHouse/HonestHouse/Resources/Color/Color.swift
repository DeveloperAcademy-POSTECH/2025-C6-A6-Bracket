//
//  Color.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

import SwiftUI

extension Color {
    
    // Neutral Colors
    static let g12: Color = .init(hex: "17171C")    /// 17171C
    static let g11: Color = .init(hex: "222229")    /// 222229
    static let g10: Color = .init(hex: "353740")    /// 353740
    static let g9: Color = .init(hex: "4B4C59")     /// 4B4C59
    static let g8: Color = .init(hex: "63646F")     /// 63646F
    static let g7: Color = .init(hex: "878892")     /// 878892
    static let g6: Color = .init(hex: "A3A3AA")     /// A3A3AA
    static let g5: Color = .init(hex: "BBBBC0")     /// BBBBC0
    static let g4: Color = .init(hex: "CECFD4")     /// CECFD4
    static let g3: Color = .init(hex: "DEDFE3")     /// DEDFE3
    static let g2: Color = .init(hex: "DEE0E3")     /// DEE0E3
    static let g1: Color = .init(hex: "FAFAFA")     /// FAFAFA
    static let g0: Color = .init(hex: "FFFFFF")     /// FFFFFF
    
    // Semantic Colors
    static let red1: Color = .init(hex: "FF383C")       /// FF383C
    static let yellow1: Color = .init(hex: "E6FF79")    /// E6FF79
    static let yellow2: Color = .init(hex: "586621")    /// 586621
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")

        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >>  8) & 0xFF) / 255.0
        let b = Double((rgb >>  0) & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
