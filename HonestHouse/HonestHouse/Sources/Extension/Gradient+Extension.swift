//
//  Gradient+Extension.swift
//  HonestHouse
//
//  Created by Subeen on 11/9/25.
//

import SwiftUI

extension LinearGradient {
    
    static let magentaGreenGradient: LinearGradient = .init(
        colors: [
            .init(hex: "FF5CC6"),
            .init(hex: "FFFFFF"),
            .init(hex: "59FF6D")
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let exposureGradient: LinearGradient = .init(
        colors: [.init(hex: "FFFFFF")],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let colorTemperatureGradient: LinearGradient = .init(
        colors: [
            .init(hex: "36BCFF"),
            .init(hex: "FFFFFF"),
            .init(hex: "FFCD38"),
        ],
        startPoint: .bottomLeading,
        endPoint: .topTrailing
    )
}
