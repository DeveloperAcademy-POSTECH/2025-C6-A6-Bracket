//
//  View+ErrorHandling.swift
//  HonestHouse
//
//  Created by Claude on 11/6/25.
//

import SwiftUI

extension View {
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
}
