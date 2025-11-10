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
    
    /// AlertPresentable 에러를 Alert로 표시
    /// - Parameters:
    ///   - error: Binding<(AlertPresentable & Error)?>
    ///   - actions: 에러에 따라 Alert 버튼들을 정의하는 ViewBuilder
    func errorAlert<E: AlertPresentable, Actions: View>(
        error: Binding<E?>,
        @ViewBuilder actions: @escaping (E) -> Actions
    ) -> some View {
        self.alert(
            error.wrappedValue?.alertInfo.title ?? "",
            isPresented: Binding(
                get: { error.wrappedValue != nil },
                set: { if !$0 { error.wrappedValue = nil } }
            )
        ) {
            if let currentError = error.wrappedValue {
                actions(currentError)
            }
        } message: {
            if let message = error.wrappedValue?.alertInfo.message {
                Text(message)
            }
        }
    }
    
    /*
    Pinch to zoom
    Double tap to zoom in and out
    Drag to pan
    */
    func zoomableGesture(
        minZoomScale: CGFloat = 1.0,
        maxZoomScale: CGFloat = 3.0,
        doubleTapZoomScale: CGFloat = 3.0
    ) -> some View {
        ZoomableGestureView(
            minZoomScale: minZoomScale,
            maxZoomScale: maxZoomScale,
            doubleTapZoomScale: doubleTapZoomScale
        ) {
            self
        }
    }
}
