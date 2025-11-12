//
//  ToastView.swift
//  HonestHouse
//
//  Created by Rama on 10/26/25.
//

import SwiftUI

struct ToastView: View {
    let message: String
    
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Text(message)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom, 50)
        }
        .opacity(isShowing ? 1 : 0)
        .animation(.easeIn(duration: 0.3), value: isShowing)
        .onChange(of: isShowing) { _, newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        isShowing = false
                    }
                }
            }
        }
    }
}
