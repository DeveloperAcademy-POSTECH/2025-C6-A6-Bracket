//
//  ShadowView.swift
//  HonestHouse
//
//  Created by 이현주 on 11/4/25.
//

import SwiftUI

struct ShadowView: View {
    let startBottom: Bool
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color(Color.black).opacity(0), location: 0.0),
                .init(color: Color(Color.black), location: 1.0)
            ]),
            startPoint: startBottom ? .top : .bottom,
            endPoint: startBottom ? .bottom : .top
        )
        .frame(height: 120)
    }
}

