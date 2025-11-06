//
//  View+Extension.swift
//  HonestHouse
//
//  Created by 이현주 on 11/3/25.
//

import SwiftUI

extension View {
    /*
     <사용법>
     VStack {
     Text("Content")
     }
     .screenPadding()
     */
    func screenPadding() -> some View {
        self.padding(.horizontal, Spacing.screen)
    }
    
    /*
     <사용법>
     .navigationBarWithBack(title: "", showShadow: false) {
     dismiss()
     } rightView: {
     EmptyView()
     }
     */
    func navigationBarWithBack<RightContent: View>(
        title: String,
        showShadow: Bool,
        onBackTapped: (() -> Void)? = nil,
        @ViewBuilder rightView: () -> RightContent = { EmptyView() }
    ) -> some View {
        self.modifier(
            NavigationBarWithBackButton(
                title: title,
                showShadow: showShadow,
                onBackTapped: onBackTapped,
                rightView: rightView
            )
        )
    }
}
