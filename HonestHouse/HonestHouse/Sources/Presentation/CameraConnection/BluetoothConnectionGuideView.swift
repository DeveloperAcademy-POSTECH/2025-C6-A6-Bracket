//
//  BluetoothGuideView.swift
//  HonestHouse
//
//  Created by Rama on 11/18/25.
//

import SwiftUI

struct BluetoothConnectionGuideView: View {
    @EnvironmentObject var cameraConnectionManager: CameraConnectionManager
    @StateObject private var viewModel = BluetoothConnectionViewModel()

    @State private var showSuccessAlert = false
    @State private var showFailureAlert = false
    @State private var connectionError: ConnectionError?
    @State private var showPTPIPTest = false

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

            VStack(spacing: 12) {
                Spacer()

                stepStatusView()

                if viewModel.wifiInfo != nil {
                    connectOptionButtons()
                } else {
                    connectBluetoothButton()
                }
            }
        }
        .padding(.horizontal, 16)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showPTPIPTest) {
            if let ip = viewModel.wifiInfo?.ipAddress {
                PTPIPTestView(host: ip, bluetoothViewModel: viewModel)
            }
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
        .alert("연결 실패", isPresented: $showFailureAlert, presenting: connectionError) { _ in
            Button("취소") { }
        } message: { error in
            Text(error.localizedDescription)
        }
    }

    @ViewBuilder
    private func stepStatusView() -> some View {
        if viewModel.step != .idle {
            HStack(spacing: 8) {
                if viewModel.step.isRunning {
                    ProgressView()
                        .tint(.g0)
                }
                Text(viewModel.step.message)
                    .fontStyle(.captionM)
                    .foregroundStyle(isFailed ? Color.red1 : Color.g4)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 16)
        }
    }

    private var isFailed: Bool {
        if case .failed = viewModel.step { return true }
        return false
    }

    private func connectBluetoothButton() -> some View {
        Button {
            if cameraConnectionManager.connectionState != .connecting {
                cameraConnectionManager.connectionState = .disconnected
            }
            Task { await viewModel.start() }
        } label: {
            Text(isFailed ? "다시 시도하기" : "Bluetooth 연결하기")
                .fontStyle(.num3)
                .foregroundColor(.g12)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(viewModel.step.isRunning ? Color.g6 : Color.yellow1)
                .cornerRadius(62)
        }
        .disabled(viewModel.step.isRunning)
        .padding(.horizontal, 16)
    }

    private func connectOptionButtons() -> some View {
        VStack(spacing: 12) {
            Button {
                Task { await viewModel.connectWithCCAPI(using: cameraConnectionManager) }
            } label: {
                Text("CCAPI로 연결")
                    .fontStyle(.num3)
                    .foregroundColor(.g12)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.yellow1)
                    .cornerRadius(62)
            }
            .disabled(cameraConnectionManager.connectionState == .connecting)

            Button {
                showPTPIPTest = true
            } label: {
                Text("PTP/IP로 연결 (실험)")
                    .fontStyle(.num3)
                    .foregroundColor(.g0)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 62)
                            .stroke(Color.g0, lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 16)
    }
}
