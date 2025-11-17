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
    
    var body: some View {
        VStack(alignment: .center) {
                ZStack {
                    Color.g12.ignoresSafeArea()
                    
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(SettingOption.allCases, id: \.self) { item in
                                if item == .connectCamera {
                                    Button {
                                        cameraConnectionManager.showConnectionSheet = true
                                    } label: {
                                        settingRow(item: item)
                                    }
                                    .buttonStyle(.plain)
                                } else if item == .instagram {
                                    Button {
                                        if let url = item.externalURL {
                                            UIApplication.shared.open(url)
                                        }
                                    } label: {
                                        settingRow(item: item)
                                    }
                                    .buttonStyle(.plain)
                                } else {
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
                        Text("v 1.0(1)")
                            .fontStyle(.num7)
                            .foregroundStyle(Color.g7)
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
