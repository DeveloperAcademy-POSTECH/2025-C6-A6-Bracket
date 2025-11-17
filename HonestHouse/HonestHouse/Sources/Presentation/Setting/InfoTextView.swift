//
//  InfoTextView.swift
//  HonestHouse
//
//  Created by Rama on 11/16/25.
//

import SwiftUI

struct InfoTextView: View {
    @Environment(\.dismiss) private var dismiss
    
    let type: SettingOption
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                switch type {
                case .privacyPolicy:
                    Text(SettingConstants.privacyPolicy)
                        .fontStyle(.num6)
                        .foregroundStyle(Color.g0)
                    
                case .termsOfService:
                    Text(SettingConstants.termsOfService)
                        .fontStyle(.num6)
                        .foregroundStyle(Color.g0)
                    
                case .contact:
                    Text(SettingConstants.teamEmail)
                        .fontStyle(.num6)
                        .foregroundStyle(Color.g0)
                    
                case .team:
                    VStack {
                        Spacer().frame(height: 200)
                        
                        Image(.teamIntro)
                            .resizable()
                            .frame(maxWidth: .infinity)
                            .padding(16)
                        
                        Spacer().frame(height: 300)
                        
                        Text("Thanks to Lumi, Jiku, NoRim")
                            .fontStyle(.num7)
                            .foregroundStyle(Color.g5)
                    }
                    
                default:
                    EmptyView()
                }
            }
            .padding()
        }
        .navigationBarWithBack(title: "\(type.title)", showShadow: false) {
            dismiss()
        } rightView: { EmptyView() }
        .navigationBarTitleDisplayMode(.automatic)
        .background(Color.g12)
        .navigationTitle(type.title)
    }
}
