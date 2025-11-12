//
//  ButtonFrameKey.swift
//  HonestHouse
//
//  Created by Subeen on 11/10/25.
//

import SwiftUI

// 버튼의 프레임 정보를 전달하기 위한 PreferenceKey
struct ButtonFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
