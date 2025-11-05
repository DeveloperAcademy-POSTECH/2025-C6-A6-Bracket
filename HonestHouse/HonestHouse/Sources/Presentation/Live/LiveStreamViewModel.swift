//
//  LiveStreamViewModel.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/30/25.
//

import SwiftUI

@Observable
final class LiveStreamViewModel {

    private let container: DIContainer
    
    var isStreaming = false
    var currentImage: UIImage?
    var afFrames: [LiveViewInfo.AFFrame] = []
    var errorMessage: String?
    var fps: Double = 0.0
    
    private var frameCount = 0
    private var fpsStartTime = Date()
    private let fpsUpdateInterval: TimeInterval = 1.0
    
    init(container: DIContainer) {
        self.container = container
    }

    func startLiveView() {
        guard !isStreaming else {
            Logger.warning("Already streaming", category: .viewModel)
            return
        }

        Task { @MainActor in
            let success = await container.services.liveViewService.startLiveView(
                onFrame: { [weak self] frame in
                    self?.handleFrame(frame)
                },
                onError: { [weak self] error in
                    self?.handleError(error)
                },
                size: "medium",
                display: "on"
            )

            if success {
                isStreaming = true
                errorMessage = nil
                resetFPS()
            } else {
                errorMessage = "Failed to start live view"
            }
        }
    }

    func stopLiveView() {
        guard isStreaming else {
            Logger.warning("Not streaming", category: .viewModel)
            return
        }

        Task { @MainActor in
            do {
                try await container.services.liveViewService.stopLiveView()
                isStreaming = false
                currentImage = nil
                afFrames.removeAll()
            } catch {
                errorMessage = "Failed to stop live view: \(error.localizedDescription)"
            }
        }
    }

    private func handleFrame(_ frame: ParsedFrame) {
        switch frame.type {
        case .image:
            if let image = frame.image {
                currentImage = image
                updateFPS()
                Logger.debug("Image frame processed: \(image.size.width)x\(image.size.height)", category: .viewModel)
            } else {
                Logger.warning("Image frame received but UIImage(data:) returned nil", category: .viewModel)
            }

        case .info:
            if let info = frame.info {
                afFrames = info.afFrame ?? []
                Logger.debug("Info frame processed: \(afFrames.count) AF frames", category: .viewModel)
            }

        case .event:
            Logger.debug("Event frame received", category: .viewModel)
        }
    }

    private func handleError(_ error: Error) {
        isStreaming = false
        errorMessage = "Connection error: \(error.localizedDescription)"
        Logger.error("LiveView error: \(error)", category: .viewModel)
    }

    private func updateFPS() {
        frameCount += 1

        let elapsed = Date().timeIntervalSince(fpsStartTime)
        if elapsed >= fpsUpdateInterval {
            fps = Double(frameCount) / elapsed
            resetFPS()
        }
    }

    private func resetFPS() {
        frameCount = 0
        fpsStartTime = Date()
    }
}
