//
//  SupportEmail.swift
//  HonestHouse
//
//  Created by 이현주 on 11/18/25.
//

import SwiftUI

struct SupportEmail {
    let toAddress: String
    let subject: String
    var body = SettingConstants.contactBody
    
    func send(openURL: OpenURLAction) {
        let urlString = "mailto:\(toAddress)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")"
        guard let url = URL(string: urlString) else { return }
        openURL(url) { accepted in
            if !accepted {
                Logger.error("ERROR: 현재 기기는 이메일을 지원하지 않습니다.")
            }
        }
    }
}
