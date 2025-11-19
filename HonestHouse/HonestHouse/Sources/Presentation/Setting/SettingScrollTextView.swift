//
//  SettingScrollTextView.swift
//  HonestHouse
//
//  Created by 이현주 on 11/18/25.
//

import SwiftUI

struct SettingScrollTextView: View {
    @Environment(\.dismiss) private var dismiss
    let menu: SettingOption
    
    var body: some View {
        ScrollView {
            if let contents = menu.textContetns {
                Text(contents)
                    .fontStyle(.num6)
                    .foregroundStyle(Color.g0)
                    .screenPadding()
            }
        }
        .background(Color.g12)
        .navigationBarWithBack(title: "\(menu.title)", showShadow: true) {
            dismiss()
        } rightView: { EmptyView() }
    }
}
