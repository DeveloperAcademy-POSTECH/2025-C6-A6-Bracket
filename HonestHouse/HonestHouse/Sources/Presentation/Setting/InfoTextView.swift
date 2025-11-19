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
        switch type {
        case .privacyPolicy:
            SettingScrollTextView(menu: .privacyPolicy)
            
        case .termsOfService:
            SettingScrollTextView(menu: .termsOfService)
            
        case .team:
            BracketTeamView()
            
        default:
            EmptyView()
        }
    }
}
