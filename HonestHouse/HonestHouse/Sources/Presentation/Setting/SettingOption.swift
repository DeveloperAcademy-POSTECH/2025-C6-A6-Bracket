//
//  SettingList.swift
//  HonestHouse
//
//  Created by Rama on 11/16/25.
//

import SwiftUI

enum SettingOption: CaseIterable {
    case connectCamera
    case termsOfService
    case privacyPolicy
    case contact
    case team
    case instagram
    
    var title: String {
        switch self {
        case .connectCamera:
            return "카메라 연결"
        case .termsOfService:
            return "서비스 이용약관"
        case .privacyPolicy:
            return "개인정보 처리방침"
        case .contact:
            return "문의하기"
        case .team:
            return "Bracket Team"
        case .instagram:
            return "Instagram"
        }
    }
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .instagram, .connectCamera:
            EmptyView()
        default:
            InfoTextView(type: self)
        }
    }
    
    var externalURL: URL? {
        switch self {
        case .instagram:
            return URL(string: "http://instagram.com/bracket.house")
        default:
            return nil
        }
    }
    
    var textContetns: String? {
        switch self {
        case .termsOfService:
            return SettingConstants.termsOfService
        case .privacyPolicy:
            return SettingConstants.privacyPolicy
        default:
            return nil
        }
    }
}
