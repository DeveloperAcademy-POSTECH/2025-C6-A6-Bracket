//
//  ConnectionGuideView.swift
//  HonestHouse
//
//  Created by Rama on 11/3/25.
//

import SwiftUI

struct ConnectionGuideView: View {
    @EnvironmentObject var cameraConnectionManager: CameraConnectionManager
    
    @State private var ipAddress: String = ""
    @State private var showSuccessAlert = false
    @State private var showFailureAlert = false
    @State private var connectionError: ConnectionError?
    @State private var navigateToCompletion = false
    
    let type: ConnectionType
    
    var body: some View {
        VStack(spacing: 24) {
            if type == .ip { ipAddressTextField() }
            
            ForEach(Array(type.guideDescription.enumerated()), id: \.offset) { index, description in
                guideStepView(number: index + 1, description: description)
            }
            
            Spacer()
            
            connectButton()
        }
        .padding(.vertical, 38)
        .padding(.horizontal, 16)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("\(type.guideTitle)")
                    .fontStyle(.num4)
                    .foregroundColor(.g0)
            }
        }
        .navigationDestination(isPresented: $navigateToCompletion) {
            ConnectionCompletionView()
        }
        .onChange(of: cameraConnectionManager.connectionState) { _, newState in
            switch newState {
            case .connected:
                showSuccessAlert = true
            case .failed(let error):
                connectionError = error
                showFailureAlert = true
            default:
                break
            }
        }
        .alert("연결 성공", isPresented: $showSuccessAlert) {
            Button("확인") {
                navigateToCompletion = true
            }
        } message: {
            Text("카메라가 성공적으로 연결되었습니다.")
        }
        .alert("연결 실패", isPresented: $showFailureAlert, presenting: connectionError) { error in
            Button("취소") { }
        } message: { error in
            Text(error.localizedDescription)
        }
    }
    
    private func guideStepView(number: Int, description: String) -> some View {
        HStack(alignment: .top, spacing: 20) {
            Image("guideNumber\(number)")
                .resizable()
                .frame(width: 28, height: 28)
            
            Text(description)
                .fontStyle(.num4)
                .foregroundStyle(Color.g0)
            
            Spacer()
        }
    }
    
    private func ipAddressTextField() -> some View {
        ZStack(alignment: .center) {
            if ipAddress.isEmpty {
                Text("예시) https://192.168.1.2:443")
                    .fontStyle(.num4)
                    .foregroundColor(.g6)
            }
            
            TextField("", text: $ipAddress)
                .fontStyle(.num4)
                .foregroundColor(.g0)
                .tint(.g6)
                .multilineTextAlignment(.center)
                .keyboardType(.URL)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        }
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

            if !ipAddress.isEmpty {
                parseAndSetURLComponents(from: ipAddress)
            }

            cameraConnectionManager.connectCamera(ipAddress: BaseURLConstants.cameraIP)
        } label: {
            Text("연결하기")
                .fontStyle(.num3)
                .foregroundColor(.g12)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(Color.g0)
                .cornerRadius(62)
        }
        .padding(.horizontal, 16)
    }

    private func parseAndSetURLComponents(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        if let scheme = url.scheme {
            BaseURLConstants.scheme = scheme
        }
        
        if let host = url.host {
            BaseURLConstants.cameraIP = host
        }

        if let port = url.port {
            BaseURLConstants.port = String(port)
        }
    }
}
