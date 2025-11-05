//
//  LiveStreamView.swift
//  CCAPI_test
//
//  Created by Subeen on 10/27/25.
//

import SwiftUI

struct LiveStreamView: View {
    @EnvironmentObject var container: DIContainer
    @EnvironmentObject var cameraConnectionManager: CameraConnectionManager
    
    @State var vm: LiveStreamViewModel

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

            Text("상태: \(cameraConnectionManager.connectionState == .connected ? (vm.isStreaming ? "스트리밍" : "연결됨") : "연결 안 됨")")
                .font(.caption)
                .foregroundColor(cameraConnectionManager.connectionState == .connected ? (vm.isStreaming ? .green : .orange) : .gray)

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
                        await startLiveView()
                    }
                } label: {
                    Text(vm.isStreaming ? "스트리밍 중" : "라이브뷰 시작")
                        .padding()
                        .background(vm.isStreaming ? Color.orange : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(cameraConnectionManager.connectionState != .connected || vm.isStreaming)

                Button {
                    Task {
                        // TODO: 제대로 동작하게 수정 필요
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

    @MainActor
    private func startLiveView() async {
        guard cameraConnectionManager.connectionState == .connected else {
            vm.errorMessage = "먼저 카메라를 연결하세요"
            return
        }

        vm.errorMessage = nil
        vm.startLiveView()
        Logger.info("라이브뷰 시작", category: .ui)
    }

    @MainActor
    private func stopLiveView() async {
        vm.stopLiveView()
        Logger.info("라이브뷰 중지", category: .ui)
    }
}
