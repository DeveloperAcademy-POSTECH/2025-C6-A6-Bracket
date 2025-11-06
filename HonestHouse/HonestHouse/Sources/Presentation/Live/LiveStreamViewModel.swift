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
    var errorMessage: String? //TODO: Error State로 변경
    var fps: Double = 0.0

    private var frameCount = 0
    private var fpsStartTime = Date()
    private let fpsUpdateInterval: TimeInterval = 1.0

    private var frameStream: AsyncStream<ParsedFrame>?
    private var frameContinuation: AsyncStream<ParsedFrame>.Continuation?
    private var renderTask: Task<Void, Never>?
    private var lifecycleTask: Task<Void, Never>?

    init(container: DIContainer) {
        self.container = container
    }
    
    func observeViewLifecycle() async {
        defer {
            Logger.info("View lifecycle ended - cleaning up", category: .viewModel)
            stopStreaming()
        }

        configureStreaming()

        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(0.5))
        }

        Logger.info("Task cancellation detected", category: .viewModel)
    }

    private func configureStreaming() {
        guard !isStreaming else {
            Logger.warning("Already streaming", category: .viewModel)
            return
        }

        let (stream, continuation) = AsyncStream.makeStream(
            of: ParsedFrame.self,
            bufferingPolicy: .bufferingNewest(1)
        )

        frameStream = stream
        frameContinuation = continuation

        Task { @MainActor in
            let success = await container.services.liveViewService.startLiveView(
                onFrame: { [weak self] frame in
                    self?.frameContinuation?.yield(frame)
                },
                onError: { [weak self] error in
                    self?.handleError(error)
                    self?.frameContinuation?.finish()
                },
                size: "medium",
                display: "on"
            )

            if success {
                isStreaming = true
                errorMessage = nil
                resetFPS()
                startRenderLoop()
            } else {
                errorMessage = "Failed to start live view"
                frameContinuation?.finish()
            }
        }
    }

    private func stopStreaming() {
        guard isStreaming else {
            Logger.warning("Not streaming", category: .viewModel)
            return
        }
        
        lifecycleTask?.cancel()
        lifecycleTask = nil
        
        frameContinuation?.finish()
        frameContinuation = nil
        renderTask?.cancel()
        renderTask = nil

        Task { @MainActor in
            do {
                try await container.services.liveViewService.stopLiveView()
                isStreaming = false
                currentImage = nil
                afFrames.removeAll()
                fps = 0.0
                Logger.info("Streaming stopped successfully", category: .viewModel)
            } catch {
                Logger.error("Stop streaming error: \(error)", category: .viewModel)
            }
        }
    }

    private func startRenderLoop() {
        renderTask = Task { @MainActor in
            guard let stream = frameStream else { return }
            Logger.info("Render loop started", category: .viewModel)

            for await frame in stream {
                guard !Task.isCancelled else {
                    Logger.info("Render loop cancelled", category: .viewModel)
                    break
                }

                handleFrame(frame)
            }

            Logger.info("Render loop ended", category: .viewModel)
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

        frameContinuation?.finish()
        renderTask?.cancel()
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
