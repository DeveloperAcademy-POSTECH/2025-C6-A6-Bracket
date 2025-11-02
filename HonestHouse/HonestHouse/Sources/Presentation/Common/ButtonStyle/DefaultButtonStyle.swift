//
//  DefaultButtonStyle.swift
//  HonestHouse
//
//  Created by Subeen on 11/3/25.
//

import SwiftUI

struct DefaultButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.labelL)
            .foregroundStyle(Color.g12)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(Color.g0)
            .clipShape(RoundedRectangle(cornerRadius: 62))
    }
}
