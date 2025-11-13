//
//  View+Extension.swift
//  HonestHouse
//
//  Created by 이현주 on 11/3/25.
//

import SwiftUI

extension View {
    
    // 폰트 line height 적용
    /*
     <사용법>
     Text("Hello World!)
        .fontStyle(.num1)
     */
    func fontStyle(_ style: FontStyle) -> some View {
        let spacing = style.lineHeight - style.size
        return self
            .font(style.font)
            .lineSpacing(spacing)
            .padding(.vertical, spacing / 2)
    }
    
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
    
    // Error Alert
    /*
     <사용법>
     .customErrorAlert(error: $vm.currentError) { error in
         switch error {
         case .photoLoadingFailed:
             AlertButton.cancel("취소") { vm.goToBack() }
             AlertButton.default("재시도") { vm.startGrouping() }
            ...
        }
     */
    func customErrorAlert<E: AlertPresentable>(
        error: Binding<E?>,
        @AlertButtonBuilder actions: @escaping (E) -> [CustomAlertConfig.AlertButton]
    ) -> some View {
        let isPresented = Binding<Bool>(
            get: { error.wrappedValue != nil },
            set: { if !$0 { error.wrappedValue = nil } }
        )
        
        let config: CustomAlertConfig? = error.wrappedValue.map { currentError in
            CustomAlertConfig(
                title: currentError.alertInfo.title,
                message: currentError.alertInfo.message ?? "",
                buttons: actions(currentError)
            )
        }
        
        return self.customAlert(isPresented: isPresented, config: config)
    }
    
    // 일반 Alert
    /*
     <사용법>
     .customAlert(
         title: "카메라로 촬영해보세요",
         message: "카메라로 촬영해보세요",
         isPresented: $showAlert
     ) {
         // 버튼 갯수 만큼
         AlertButton.cancel("취소")
         AlertButton.default("확인") {
             action()
         }
     }
     */
    func customAlert(
        title: String,
        message: String = "",
        isPresented: Binding<Bool>,
        @AlertButtonBuilder actions: @escaping () -> [CustomAlertConfig.AlertButton]
    ) -> some View {
        let config = CustomAlertConfig(
            title: title,
            message: message,
            buttons: actions()
        )
        
        return self.customAlert(isPresented: isPresented, config: config)
    }
    
    // 기본 Alert
    func customAlert(
        isPresented: Binding<Bool>,
        config: CustomAlertConfig?
    ) -> some View {
        ZStack {
            self
            
            if isPresented.wrappedValue, let config = config {
                CustomAlertView(config: config, isPresented: isPresented)
                    .transition(.opacity)
                    .zIndex(999)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isPresented.wrappedValue)
    }
    
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
