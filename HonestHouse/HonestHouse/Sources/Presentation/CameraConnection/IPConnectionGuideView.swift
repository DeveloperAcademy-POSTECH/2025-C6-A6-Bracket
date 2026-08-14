//
//  IPConnectionGuideView.swift
//  HonestHouse
//
//  Created by Rama on 11/18/25.
//

import SwiftUI

struct IPConnectionGuideView: View {
    @EnvironmentObject var cameraConnectionManager: CameraConnectionManager
    
    @State private var ipAddress: String = ""
    @State private var showSuccessAlert = false
    @State private var showFailureAlert = false
    @State private var connectionError: ConnectionError?
    
    var body: some View {
        ZStack {
            VStack(spacing: 36) {
                ConnectionNavigationBar(title: "주소 연결")
                    .padding(.top, 26)
                
                ipAddressTextField()
                
                VStack(spacing: 24) {
                    ForEach(Array(ConnectionType.ip.guideDescription.enumerated()), id: \.offset) { index, description in
                        GuideStepView(number: index + 1, description: description)
                    }
                }
                
                Spacer()
            }
            
            VStack {
                Spacer()
                
                connectButton()
            }
        }
        .padding(.horizontal, 16)
        .navigationBarHidden(true)
        .contentShape(Rectangle())
        .onTapGesture {
            hideKeyboard()
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
                cameraConnectionManager.showConnectionSheet = false
            }
        } message: {
            Text("\(cameraConnectionManager.productName)와 연결되었습니다.")
        }
        .alert("연결 실패", isPresented: $showFailureAlert, presenting: connectionError) { error in
            Button("취소") { }
        } message: { error in
            Text(error.localizedDescription)
        }
    }
    
    private func ipAddressTextField() -> some View {
        ZStack(alignment: .center) {
            if ipAddress.isEmpty {
                Text("http://192.168.1.2:8080")
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

            if ipAddress.isEmpty {
                BaseURLConstants.scheme = "http"
                BaseURLConstants.cameraIP = "192.168.1.2"
                BaseURLConstants.port = "8080"
            } else if !parseAndSetURLComponents(from: ipAddress) {
                cameraConnectionManager.connectionState = .failed(.invalidIPAddress)
                return
            }

            cameraConnectionManager.connectCamera(ipAddress: BaseURLConstants.cameraIP)
        } label: {
            Text("연결하기")
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

extension IPConnectionGuideView {
    /// 입력 문자열을 파싱해 scheme/IP/port를 원자적으로 설정
    /// 스킴이 없으면 http로 보정, 포트가 없으면 스킴 기준 기본값(http: 8080, https: 443) 적용
    @discardableResult
    private func parseAndSetURLComponents(from urlString: String) -> Bool {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalized = trimmed.contains("://") ? trimmed : "http://\(trimmed)"

        guard let components = URLComponents(string: normalized),
              let scheme = components.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              let host = components.host,
              !host.isEmpty else {
            Logger.warning("Invalid connection URL input: \(urlString)", category: .connection)
            return false
        }

        let port: Int
        if let inputPort = components.port {
            port = inputPort
        } else {
            port = scheme == "https" ? 443 : 8080
        }

        BaseURLConstants.scheme = scheme
        BaseURLConstants.cameraIP = host
        BaseURLConstants.port = String(port)
        return true
    }
}
