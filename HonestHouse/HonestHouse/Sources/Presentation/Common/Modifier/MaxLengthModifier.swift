//
//  MaxLengthModifier.swift
//  HonestHouse
//
//  Created by Subeen on 11/16/25.
//

import SwiftUI

struct MaxLengthModifier: ViewModifier {
    @Binding var text: String
    let maxLength: Int
    
    func body(content: Content) -> some View {
        content
            .onChange(of: text) { _, newValue in
                if newValue.count > maxLength {
                    text = String(newValue.prefix(maxLength))
                }
            }
    }
}
