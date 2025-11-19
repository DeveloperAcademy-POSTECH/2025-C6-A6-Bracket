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
        GeometryReader { geo in
            ZStack {
                Color.g12.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: geo.size.height * 0.37)
                    
                    LottieView(animation: .named("BracketLottie"))
                        .playing()
                    
                    Spacer()
                        .frame(height: geo.size.height * 0.48)
                }
            }
        }
    }
}


#Preview {
    SplashView()
}
