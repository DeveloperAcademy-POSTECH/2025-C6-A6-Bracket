//
//  BluetoothGuideView.swift
//  HonestHouse
//
//  Created by Rama on 11/18/25.
//

import SwiftUI

struct BluetoothConnectionGuideView: View {
    @EnvironmentObject var cameraConnectionManager: CameraConnectionManager
    
    var body: some View {
        ZStack {
            VStack(spacing: 36) {
                ConnectionNavigationBar(title: "블루투스 연결")
                    .padding(.top, 38)
                
                VStack(spacing: 24) {
                    ForEach(Array(ConnectionType.bluetooth.guideDescription.enumerated()), id: \.offset) { index, description in
                        GuideStepView(number: index + 1, description: description)
                    }
                }
                
                Spacer()
            }
            
            VStack {
                Spacer()
                
                connectBluetoothButton()
            }
        }
        .padding(.horizontal, 16)
        .navigationBarHidden(true)
    }
    
    private func connectBluetoothButton() -> some View {
        Button {
            if cameraConnectionManager.connectionState != .connecting {
                cameraConnectionManager.connectionState = .disconnected
            }
            
//            cameraConnectionManager.connectCamera(ipAddress: BaseURLConstants.cameraIP)
        } label: {
            Text("Bluetooth 연결하기")
                .fontStyle(.num3)
                .foregroundColor(.g12)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.yellow1)
                .cornerRadius(62)
        }
        .padding(.horizontal, 16)
    }
}
