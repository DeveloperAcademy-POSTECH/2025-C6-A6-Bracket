//
//  TextField+Extension.swift
//  HonestHouse
//
//  Created by Subeen on 11/16/25.
//

import SwiftUI

extension TextField {
    // 텍스트필드의 최대 글자수 지정
    func maxLength(_ text: Binding<String>, _ maxLength: Int) -> some View {
        return self.modifier(MaxLengthModifier(text: text, maxLength: maxLength))
    }
}
