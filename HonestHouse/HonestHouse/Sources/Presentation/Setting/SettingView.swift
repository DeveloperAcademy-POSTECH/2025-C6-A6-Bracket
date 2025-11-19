//
//  SettingView.swift
//  HonestHouse
//
//  Created by Rama on 11/16/25.
//

import SwiftUI

struct SettingView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var cameraConnectionManager: CameraConnectionManager
    @Environment(\.openURL) var openURL
    
    private let email = SupportEmail(toAddress: SettingConstants.teamEmail, subject: SettingConstants.contactTitle)
    
    var body: some View {
        VStack(alignment: .center) {
            ZStack {
                Color.g12.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(SettingOption.allCases, id: \.self) { item in
                            switch item {
                            case .connectCamera:
                                Button {
                                    cameraConnectionManager.showConnectionSheet = true
                                } label: {
                                    settingRow(item: item)
                                }
                                .buttonStyle(.plain)
                                
                            case .contact:
                                Button {
                                    email.send(openURL: openURL)
                                } label: {
                                    settingRow(item: item)
                                }
                                .buttonStyle(.plain)
                                
                            case .instagram:
                                Button {
                                    if let url = item.externalURL {
                                        openURL(url)
                                    }
                                } label: {
                                    settingRow(item: item)
                                }
                                .buttonStyle(.plain)
                                
                            default:
                                NavigationLink(destination: item.destination) {
                                    settingRow(item: item)
                                }
                                .buttonStyle(.plain)
                            }
                            
                            if item != SettingOption.allCases.last {
                                Divider()
                                    .background(Color.g9)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                VStack {
                    Spacer()
                    Text("v \(SettingConstants.appVersion)")
                        .fontStyle(.num7)
                        .foregroundStyle(Color.g7)
                        .padding(.bottom, 35)
                }
            }
            .navigationBarWithBack(title: "설정", showShadow: false) {
                dismiss()
            } rightView: { EmptyView() }
                .navigationBarTitleDisplayMode(.automatic)
            
        }
    }
    
    private func settingRow(item: SettingOption) -> some View {
        HStack() {
            Text(item.title)
                .fontStyle(.num4)
                .foregroundStyle(Color.g0)
            
            Spacer()
        }
        .frame(height: 61)
        .contentShape(Rectangle())
    }
}

#Preview {
    SettingView()
}
