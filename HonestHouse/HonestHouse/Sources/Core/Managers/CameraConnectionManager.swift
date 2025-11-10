//
//  CameraConnectionManager.swift
//  HonestHouse
//
//  Created by Rama on 11/2/25.
//
import SwiftUI

@MainActor
final class CameraConnectionManager: BaseService, ObservableObject {
    @Published var productName: String = ""
    @Published var showConnectionSheet = false
    
    @Published var connectionState: ConnectionState = .disconnected {
        didSet {
            handleConnectionStateChange(
                oldValue: oldValue,
                newValue: connectionState
            )
        }
    }
    
    private let networkManager: NetworkManager
    private let statusService: CameraStatusServiceType // DIContainer를 사용하지 않고 별도 주입
    private var pollingTask: Task<Void, Never>?
    
    init(
        networkManager: NetworkManager = .shared,
        statusService: CameraStatusServiceType = CameraStatusService()
    ) {
        self.networkManager = networkManager
        self.statusService = statusService
    }
    
    func connectCamera(ipAddress: String) {
        guard !ipAddress.isEmpty else {
            self.connectionState = .failed(.invalidIPAddress)
            return
        }
        
        connectionState = .connecting
        
        networkManager.configure(cameraIP: ipAddress)
        
        Task {
            do {
                try await networkManager.initializeAuthentication()
                
                let cameraInfo = try await getCameraInfo()
                                
                if let productName = cameraInfo.productName {
                    self.productName = productName
                }
                
                self.connectionState = .connected
                Logger.info("카메라 연결 성공", category: .connection)
            } catch {
                let connectionError = ConnectionError.from(error)
                self.connectionState = .failed(connectionError)
                Logger.error(error.localizedDescription, category: .connection)
            }
        }
    }
    
    func disconnectCamera() {
        stopConnectionMonitoring()
        connectionState = .disconnected
    }
    
    func getCameraInfo() async throws -> CameraInformation.CameraFixedInformationResponse {
        let response = try await request(CameraInformationTarget.getCameraFixedInformation, decoding: CameraInformation.CameraFixedInformationResponse.self)
        
        return response
    }
    
    func startConnectionMonitoring() {
        pollingTask?.cancel()

        pollingTask = Task {
            while !Task.isCancelled {
                do {
                    try await statusService.getPolling(timeout: .long)
                    
                    if connectionState != .connected {
                        await MainActor.run {
                            connectionState = .connected
                        }
                    }

                    try? await Task.sleep(for: .seconds(5)) // 5초 간격으로 연결 확인

                } catch {
                    if connectionState == .connected {
                        await MainActor.run {
                            connectionState = .disconnected
                        }
                        Logger.warning("Connection lost", category: .connection)
                    }
                }
            }
        }
    }
    
    func stopConnectionMonitoring() {
        pollingTask?.cancel()
        pollingTask = nil
    }
    
    private func handleConnectionStateChange(
        oldValue: ConnectionState,
        newValue: ConnectionState
    ) {
        switch newValue {
        case .connected:
            if oldValue != .connected {
                startConnectionMonitoring()
                Logger.info("Started monitoring on connection", category: .connection)
            }
            
        case .disconnected, .failed:
            if oldValue == .connected {
                stopConnectionMonitoring()
                showConnectionSheet = true
                Logger.warning("Stopped monitoring on disconnection", category: .connection)
            }
            
        case .connecting:
            break
        }
    }
}
