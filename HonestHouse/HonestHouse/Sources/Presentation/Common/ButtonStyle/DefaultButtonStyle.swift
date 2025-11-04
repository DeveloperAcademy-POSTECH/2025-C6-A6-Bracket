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
    
    let type: DefaultButtonType
    
    init(_ type: DefaultButtonType) {
        self.type = type
    }
    
    func makeBody(configuration: Configuration) -> some View {
        switch type {
            
        case .activated:
            configuration.label
                .font(.labelL)
                .foregroundStyle(Color.g12) // font
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(Color.g0)       // background
                .clipShape(RoundedRectangle(cornerRadius: 62))
            
        case .deactivated:
            configuration.label
                .font(.labelL)
                .foregroundStyle(Color.g7)  // font
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(Color.g12)      // background
                .clipShape(RoundedRectangle(cornerRadius: 62))
                .overlay {
                    RoundedRectangle(cornerRadius: 62).strokeBorder(Color.g10, lineWidth: 1.5)
                }
                .disabled(true)
        }
    }
}
