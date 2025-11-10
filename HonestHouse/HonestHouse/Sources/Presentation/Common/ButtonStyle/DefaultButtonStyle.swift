//
//  DefaultButtonStyle.swift
//  HonestHouse
//
//  Created by Subeen on 11/3/25.
//

import SwiftUI

enum DefaultButtonType {
    case activated
    case deactivated
}

struct DefaultButtonStyle: ButtonStyle {
    private let type: DefaultButtonType
    
    init(_ type: DefaultButtonType) {
        self.type = type
    }
    
    func makeBody(configuration: Configuration) -> some View {
        switch type {
        case .activated:
            configuration.label
                .font(.num3)
                .foregroundStyle(Color.g12)
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(Color.yellow1)
                .clipShape(RoundedRectangle(cornerRadius: 62))
            
        case .deactivated:
            configuration.label
                .font(.num3)
                .foregroundStyle(Color.g7)
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(Color.yellow1)
                .clipShape(RoundedRectangle(cornerRadius: 62))
                .overlay {
                    RoundedRectangle(cornerRadius: 62).strokeBorder(Color.g10, lineWidth: 1.5)
                }
                .disabled(true)
        }
    }
}
