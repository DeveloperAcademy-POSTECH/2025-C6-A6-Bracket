//
//  ConnectionGuideView.swift
//  HonestHouse
//
//  Created by Rama on 11/3/25.
//

import SwiftUI

struct ConnectionGuideView: View {
    var type: connectionType
    
    @State private var ipAddress: String = ""
    @EnvironmentObject var cameraConnectionManager: CameraConnectionManager
    
    @State private var isAlertPresented = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 24) {
            if type == .ip { ipAddressTextField() }
            
            ForEach(Array(type.guideDescription.enumerated()), id: \.offset) { index, description in
                guideStepView(number: index + 1, description: description)
            }
            
            Spacer()
            
            connectionStatusView()
            
            connectButton()
        }
        .padding(.vertical, 38)
        .padding(.horizontal, 16)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("\(type.guideTitle)")
                    .font(.num4)
                    .foregroundColor(.g0)
            }
        }
        .onChange(of: cameraConnectionManager.connectionState) { _, newState in
            handleConnectionStateChange(newState)
        }
        .alert(alertTitle, isPresented: $isAlertPresented) {
            Button("확인") {}
        } message: {
            Text(alertMessage)
        }
    }
    
    private func guideStepView(number: Int, description: String) -> some View {
        HStack(alignment: .top, spacing: 20) {
            Image("guideNumber\(number)")
                .resizable()
                .frame(width: 28, height: 28)
            
            Text(description)
                .font(.num4)
                .foregroundStyle(Color.g0)
            
            Spacer()
        }
    }
    
    //TODO: IP 직접 입력 후 연결 구현 필요
    private func ipAddressTextField() -> some View {
        TextField("http://192.168.1.2:8080/ccapi/", text: $ipAddress)
            .font(.num4)
            .foregroundColor(.g0)
            .multilineTextAlignment(.center)
            .keyboardType(.webSearch)
            .padding(.vertical, 12)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 100)
                    .stroke(Color.g0, lineWidth: 1)
            )
            .padding(.horizontal, 16)
    }
    
    private func connectButton() -> some View {
        Button {
            if cameraConnectionManager.connectionState != .connecting {
                cameraConnectionManager.connectionState = .disconnected
            }
            
            cameraConnectionManager.connectCamera(ipAddress: BaseURLConstants.cameraIP)
        } label: {
            Text("연결하기")
                .font(.num3)
                .foregroundColor(.g12)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(Color.g0)
                .cornerRadius(62)
        }
        .padding(.horizontal, 16)
    }
    
    //TODO: 연결 UI 로그용, 추후 삭제
    private func connectionStatusView() -> some View {
        switch cameraConnectionManager.connectionState {
        case .disconnected:
            Text("Disconnected")
                .foregroundColor(.gray)
        case .connecting:
            Text("Disconnected")
                .foregroundColor(.gray)
        case .connected:
            Text("Connected")
                .foregroundColor(.green)
        case .failed(let error):
            Text("Connection Failed: \(error)")
                .foregroundColor(.red)
        }
    }
    
    private func handleConnectionStateChange(_ state: ConnectionState) {
        switch state {
        case .connected:
            alertTitle = "연결 성공"
            alertMessage = "카메라가 성공적으로 연결되었습니다."
            isAlertPresented = true
        case .failed(let error):
            alertTitle = "연결 실패"
            alertMessage = error.localizedDescription
            isAlertPresented = true
        case .connecting, .disconnected:
            break
        }
    }
}
