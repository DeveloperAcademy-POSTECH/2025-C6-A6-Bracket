//
//  PTPIPTestView.swift
//  HonestHouse
//
//  블루투스로 켠 카메라 Wi-Fi에서 PTP/IP(Camera Connect 방식) 동작을 실기로 확인하는 화면
//

import SwiftUI

struct PTPIPTestView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: PTPIPTestViewModel

    init(host: String, bluetoothViewModel: BluetoothConnectionViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: PTPIPTestViewModel(host: host, bluetoothViewModel: bluetoothViewModel))
    }

    var body: some View {
        ZStack {
            Color.g12.ignoresSafeArea()

            VStack(spacing: 16) {
                header()
                liveViewArea()
                controls()
                logArea()
            }
            .padding(.horizontal, 16)
        }
        .navigationBarHidden(true)
        .task { await viewModel.connect() }
        .onDisappear { Task { await viewModel.disconnect() } }
    }

    private func header() -> some View {
        VStack(spacing: 4) {
            ZStack {
                Text("PTP/IP 테스트")
                    .fontStyle(.num4)
                    .foregroundColor(.g0)
                HStack {
                    Button { dismiss() } label: {
                        Image(.closeIcon)
                            .resizable()
                            .frame(width: 36, height: 36)
                    }
                    Spacer()
                }
            }
            .frame(height: 36)
            .padding(.top, 26)

            Text(statusText)
                .fontStyle(.captionM)
                .foregroundStyle(statusColor)
        }
    }

    private var statusText: String {
        switch viewModel.state {
        case .idle: return "연결 안 됨"
        case .connecting: return "\(viewModel.host) 연결 중... (카메라 화면 확인)"
        case .connected: return viewModel.cameraDescription
        case .failed(let message): return message
        }
    }

    private var statusColor: Color {
        if case .failed = viewModel.state { return .red1 }
        return .g4
    }

    private func liveViewArea() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.g11)
            if let image = viewModel.liveViewImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Text(viewModel.isLiveViewOn ? "프레임 대기 중" : "라이브뷰 꺼짐")
                    .fontStyle(.captionM)
                    .foregroundStyle(Color.g7)
            }
        }
        .aspectRatio(3 / 2, contentMode: .fit)
    }

    private func controls() -> some View {
        let connected = viewModel.state == .connected
        return VStack(spacing: 12) {
            Picker("EVF 출력", selection: $viewModel.evfOutputDevice) {
                Text("EVF 2 (PC)").tag(UInt32(2))
                Text("EVF 8 (모바일)").tag(UInt32(8))
            }
            .pickerStyle(.segmented)
            .disabled(viewModel.isLiveViewOn)

            HStack(spacing: 12) {
                actionButton("촬영", enabled: connected && !viewModel.isBusy) {
                    await viewModel.shoot()
                }
                actionButton(viewModel.isLiveViewOn ? "라이브뷰 끄기" : "라이브뷰", enabled: connected) {
                    await viewModel.toggleLiveView()
                }
                actionButton("BLE 셔터", enabled: true) {
                    await viewModel.shutterOverBluetooth()
                }
            }

            if case .failed = viewModel.state {
                actionButton("다시 연결", enabled: true) {
                    await viewModel.connect()
                }
            }
        }
    }

    private func actionButton(_ title: String, enabled: Bool, action: @escaping () async -> Void) -> some View {
        Button {
            Task { await action() }
        } label: {
            Text(title)
                .fontStyle(.body2)
                .foregroundColor(.g12)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(enabled ? Color.yellow1 : Color.g8)
                .cornerRadius(62)
        }
        .disabled(!enabled)
    }

    private func logArea() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("로그")
                    .fontStyle(.labelM)
                    .foregroundStyle(Color.g0)
                Spacer()
                Button("복사") {
                    UIPasteboard.general.string = viewModel.logText
                }
                .fontStyle(.labelM)
                .foregroundStyle(Color.yellow1)
            }
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(viewModel.logs.enumerated()), id: \.offset) { index, line in
                            Text(line)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(Color.g4)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .id(index)
                        }
                    }
                }
                .onChange(of: viewModel.logs.count) { _, count in
                    proxy.scrollTo(count - 1, anchor: .bottom)
                }
            }
            .padding(8)
            .background(Color.g11)
            .cornerRadius(8)
        }
    }
}
