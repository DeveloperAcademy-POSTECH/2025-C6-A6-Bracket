//
//  RootView.swift
//  HonestHouse
//
//  Created by 이현주 on 11/16/25.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var container: DIContainer
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            } else {
                MainView(vm: MainViewModel(container: container))
            }
        }
    }
}
