//
//  CapsuleRoundStroke.swift
//  HonestHouse
//
//  Created by BoMin Lee on 11/5/25.
//

import SwiftUI

struct CapsuleRoundStroke: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = rect.height / 2

        // 왼쪽 반원
        path.addArc(
            center: CGPoint(x: radius, y: radius),
            radius: radius,
            startAngle: .degrees(95),
            endAngle: .degrees(265),
            clockwise: false
        )

        // 오른쪽 반원
        path.move(to: CGPoint(x: rect.width - radius + 5, y: 0))
        path.addArc(
            center: CGPoint(x: rect.width - radius, y: radius),
            radius: radius,
            startAngle: .degrees(275),
            endAngle: .degrees(85),
            clockwise: false
        )

        return path
    }
}

#Preview {
    TrishotSelectionView(vm: .init(container: .stub, targetOrder: 0))
}
