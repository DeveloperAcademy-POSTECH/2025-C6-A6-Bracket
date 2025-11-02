//
//  LiveStreamView.swift
//  CCAPI_test
//
//  Created by Subeen on 10/27/25.
//

import SwiftUI

struct LiveStreamView: View {
    @State private var vm = LiveStreamViewModel()
    @State private var isConnected = false

    var body: some View {

        VStack(spacing: 20) {
            if let image = vm.currentImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Text("라이브뷰 대기 중")
                    .foregroundColor(.gray)
            }

            Text("상태: \(isConnected ? (vm.isStreaming ? "스트리밍" : "연결됨") : "연결 안 됨")")
                .font(.caption)
                .foregroundColor(isConnected ? (vm.isStreaming ? .green : .orange) : .gray)

            if vm.isStreaming {
                Text("FPS: \(String(format: "%.1f", vm.fps))")
                    .font(.caption)
            }

            if let error = vm.errorMessage {
                Text("에러: \(error)")
                    .font(.caption)
                    .foregroundColor(.red)
            }

            HStack(spacing: 15) {
                Button {
                    Task {
                        await connectCamera()
                    }
                } label: {
                    Text(isConnected ? "연결됨" : "카메라 연결")
                        .padding()
                        .background(isConnected ? Color.green : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(isConnected)

                Button {
                    Task {
                        await startLiveView()
                    }
                } label: {
                    Text(vm.isStreaming ? "스트리밍 중" : "라이브뷰 시작")
                        .padding()
                        .background(vm.isStreaming ? Color.orange : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(!isConnected || vm.isStreaming)

                Button {
                    Task {
                        await stopLiveView()
                    }
                } label: {
                    Text("중지")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(!vm.isStreaming)
            }
        }
        .padding()
    }

    // MARK: - Private Methods

    @MainActor
    private func connectCamera() async {
        vm.errorMessage = nil

        do {
            NetworkManager.shared.configure(cameraIP: BaseURLConstants.cameraIP)
            try await NetworkManager.shared.initializeAuthentication()

            isConnected = true
            print("✅ 카메라 연결 성공")
        } catch {
            vm.errorMessage = "연결 실패: \(error.localizedDescription)"
            print("❌ 카메라 연결 실패: \(error)")
        }
    }

    @MainActor
    private func startLiveView() async {
        guard isConnected else {
            vm.errorMessage = "먼저 카메라를 연결하세요"
            return
        }

        vm.errorMessage = nil
        vm.startLiveView()
        print("✅ 라이브뷰 시작")
    }

    @MainActor
    private func stopLiveView() async {
        vm.stopLiveView()
        print("✅ 라이브뷰 중지")
    }
}
