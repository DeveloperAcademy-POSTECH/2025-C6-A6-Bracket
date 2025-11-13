//
//  CustomAlertView.swift
//  HonestHouse
//
//  Created by 이현주 on 11/13/25.
//

import SwiftUI

struct CustomAlertView: View {
    let config: CustomAlertConfig
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 28) {
                VStack(spacing: 12) {
                    Text(config.title)
                        .font(.num3)
                        .foregroundColor(.g0)
                    
                    Text(config.message)
                        .font(.captionL)
                        .foregroundColor(.g5)
                        .multilineTextAlignment(.center)
                }
                
                buttonStack
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .frame(width: 324)
            .background {
                ZStack {
                    VisualEffectBlurView()
                        .blur(radius: 20, opaque: true)
                        .overlay {
                            Color.g10
                        }
                }
            }
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 4)
        }
    }
    
    @ViewBuilder
    private var buttonStack: some View {
        if config.buttons.count == 1 {
            alertButton(config.buttons[0])
        } else {
            HStack(spacing: 0) {
                ForEach(Array(config.buttons.enumerated()), id: \.element.id) { index, button in
                    alertButton(button)
                    
                    if index < config.buttons.count - 1 {
                        Spacer()
                    }
                }
            }
        }
    }
    
    private func alertButton(_ button: CustomAlertConfig.AlertButton) -> some View {
        Button {
            button.action()
            isPresented = false
        } label: {
            Text(button.title)
                .font(.num3)
                .foregroundColor(buttonTitleColor(for: button.style))
                .padding(.vertical, 13)
                .background(buttonBGColor(for: button.style))
                .clipShape(Capsule())
                .overlay {
                    Capsule().strokeBorder(buttonBorderColor(for: button.style), lineWidth: 0.5)
                }
                .frame(maxWidth: .infinity)
        }
    }
    
    private func buttonTitleColor(for style: CustomAlertConfig.AlertButton.ButtonStyle) -> Color {
        switch style {
        case .default:
            return Color.g12
        case .cancel:
            return Color.g0
        }
    }
    
    private func buttonBGColor(for style: CustomAlertConfig.AlertButton.ButtonStyle) -> Color {
        switch style {
        case .default:
            return Color.yellow1
        case .cancel:
            return Color.clear
        }
    }
    
    private func buttonBorderColor(for style: CustomAlertConfig.AlertButton.ButtonStyle) -> Color {
        switch style {
        case .default:
            return Color.clear
        case .cancel:
            return Color.white
        }
    }
}
