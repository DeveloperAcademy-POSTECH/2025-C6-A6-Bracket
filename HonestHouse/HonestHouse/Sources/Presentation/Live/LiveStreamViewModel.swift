//
//  LiveStreamViewModel.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/30/25.
//

import SwiftUI

@Observable
final class LiveStreamViewModel {

    // MARK: - Properties

    var isStreaming = false
    var currentImage: UIImage?
    var afFrames: [LiveViewInfo.AFFrame] = []
    var errorMessage: String?
    var fps: Double = 0.0
    
    private var frameCount = 0
    private var fpsStartTime = Date()
    private let fpsUpdateInterval: TimeInterval = 1.0
    
    private var container: DIContainer

    // MARK: - Initialization
    
    init(container: DIContainer) {
        self.container = container
    }
}

// MARK: - Public Methods

extension LiveStreamViewModel {

    func startLiveView() {
        guard !isStreaming else {
            print("Already streaming")
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
            print("Not streaming")
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
}

// MARK: - Private Methods

extension LiveStreamViewModel {

    private func handleFrame(_ frame: ParsedFrame) {
        switch frame.type {
        case .image:
            if let image = frame.image {
                currentImage = image
                updateFPS()
                print("🖼️ Image frame processed: \(image.size.width)x\(image.size.height)")
            } else {
                print("⚠️ Image frame received but UIImage(data:) returned nil")
            }

        case .info:
            if let info = frame.info {
                afFrames = info.afFrame ?? []
                print("ℹ️ Info frame processed: \(afFrames.count) AF frames")
            }

        case .event:
            print("📢 Event frame received")
        }
    }

    private func handleError(_ error: Error) {
        isStreaming = false
        errorMessage = "Connection error: \(error.localizedDescription)"
        print("❌ LiveView error: \(error)")
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
