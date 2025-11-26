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
    var isFocused: FocusState<Bool>.Binding
    
    var body: some View {
        TextField(placeholder, text: $text)
            .maxLength($text, 22)
            .textFieldStyle(.plain)
            .fontStyle(.num2)
            .foregroundStyle(Color.g0)
            .multilineTextAlignment(.leading)
            .focused(isFocused)
            .onSubmit {
                isFocused.wrappedValue = false
            }
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
