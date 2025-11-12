//
//  ProgressWithTextView.swift
//  HonestHouse
//
//  Created by 이현주 on 11/3/25.
//

import SwiftUI

struct ProgressWithTextView: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            ProgressView()
                .scaleEffect(1.3)
                .tint(Color.g0)

            Text(text)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Color.g0)
        }
    }
}
