//
//  SplashView.swift
//  HonestHouse
//
//  Created by 이현주 on 11/16/25.
//

import SwiftUI
import Lottie

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.g12.ignoresSafeArea(.all)
            
            LottieView(animation: .named("BracketLotti.json"))
                .playing()
                .padding(.horizontal, 130)
        }
    }
}

#Preview {
    SplashView()
}
