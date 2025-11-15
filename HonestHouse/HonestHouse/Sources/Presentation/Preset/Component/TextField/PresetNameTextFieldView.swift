//
//  PresetNameTextFieldView.swift
//  HonestHouse
//
//  Created by Subeen on 11/16/25.
//

import SwiftUI

struct PresetNameTextFieldView: View {
    let placeholder: String
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        TextField(placeholder, text: $text)
            .maxLength($text, 22)
            .textFieldStyle(.plain)
            .fontStyle(.num2)
            .foregroundStyle(Color.g0)
            .multilineTextAlignment(.leading)
            .focused($isFocused)
            .onSubmit {
                isFocused = false
                if text.isEmpty {
                    text = "새 프리셋"
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
