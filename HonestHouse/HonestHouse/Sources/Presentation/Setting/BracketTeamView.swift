//
//  BracketTeamView.swift
//  HonestHouse
//
//  Created by 이현주 on 11/18/25.
//

import SwiftUI

struct BracketTeamView: View {
    @Environment(\.dismiss) private var dismiss
    let menu: SettingOption = .team
    
    var body: some View {
        VStack {
            Spacer().frame(height: 200)
            
            Image(.teamIntro)
                .resizable()
                .frame(maxWidth: .infinity)
            
            Spacer().frame(height: 300)
            
            Text("Thanks to Lumi, Jiku, NoRim")
                .fontStyle(.num7)
                .foregroundStyle(Color.g5)
                .padding(.bottom, 35)
        }
        .screenPadding()
        .background(Color.g12)
        .navigationBarWithBack(title: "\(menu.title)", showShadow: false) {
            dismiss()
        } rightView: { EmptyView() }
    }
}

#Preview {
    BracketTeamView()
}
