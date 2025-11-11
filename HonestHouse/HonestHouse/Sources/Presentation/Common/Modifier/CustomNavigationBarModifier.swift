//
//  CustomNavigationBarModifier.swift
//  HonestHouse
//
//  Created by 이현주 on 11/3/25.
//

import SwiftUI

struct NavigationBarWithBackButton<RightContent: View>: ViewModifier {
    @EnvironmentObject var container: DIContainer

    let title: String
    let rightView: RightContent
    let backgroundColor: Color
    let onBackTapped: (() -> Void)?
    let showShadow: Bool

    init(
        title: String,
        backgroundColor: Color = Color.clear,
        showShadow: Bool,
        onBackTapped: (() -> Void)? = nil,
        @ViewBuilder rightView: () -> RightContent
    ) {
        self.title = title
        self.backgroundColor = backgroundColor
        self.showShadow = showShadow
        self.onBackTapped = onBackTapped
        self.rightView = rightView()
    }

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            // modifier가 적용되는 원본 뷰
            content.safeAreaPadding(.top, 44)

            if showShadow {
                ShadowView(startBottom: false)
                    .ignoresSafeArea(edges: .top)
            }
        
            // Navigation Bar
            ZStack(alignment: .center) {
                HStack {
                    Spacer()
                    // Center - Title
                    Text(title)
                        .font(.num4)
                        .lineLimit(1)
                    Spacer()
                }
                HStack(spacing: 0) {
                    Button {
                        if let customAction = onBackTapped {
                            customAction()
                        } else {
                            container.navigationRouter.pop()
                        }
                    } label: {
                        Image(.chevronLeft)
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    Spacer()
                    // Right - Custom View
                    rightView
                        .frame(height: 24)
                        .frame(minWidth: 24)
                }
            }
            .screenPadding()
            .foregroundStyle(Color.g0)
            .background(backgroundColor)
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}
