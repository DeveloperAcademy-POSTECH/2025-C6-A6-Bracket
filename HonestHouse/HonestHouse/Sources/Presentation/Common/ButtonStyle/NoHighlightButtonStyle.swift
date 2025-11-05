//
//  NoHighlightButtonStyle.swift
//  HonestHouse
//
//  Created by Subeen on 11/4/25.
//

import SwiftUI

/// 버튼 꾹 눌렀을 때, 회색 하이라이팅 뜨는 것 제거
struct NoHighlightButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
