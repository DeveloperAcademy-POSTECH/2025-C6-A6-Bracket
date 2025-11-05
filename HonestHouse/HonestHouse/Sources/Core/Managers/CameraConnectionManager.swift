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
    @Published var connectionState: ConnectionState = .disconnected
    @Published var showConnectionSheet = false
    
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
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
                self.connectionState = .connected
                Logger.info("카메라 연결 성공", category: .connection)
                
                let cameraInfo = try await getCameraInfo()
                
                if let productName = cameraInfo.productName {
                    self.productName = productName
                }
            } catch {
                let connectionError = ConnectionError.from(error)
                self.connectionState = .failed(connectionError)
                Logger.error(error.localizedDescription, category: .connection)
            }
        }
    }
    
    func disconnectCamera() {
        connectionState = .disconnected
    }
    
    func checkConnectionStatus() async -> Bool {
        do {
            _ = try await getCameraInfo()
            self.connectionState = .connected
            return true
        } catch {
            self.connectionState = .disconnected
            return false
        }
    }
    
    func getCameraInfo() async throws -> CameraInformation.CameraFixedInformationResponse {
        let response = try await request(CameraInformationTarget.getCameraFixedInformation, decoding: CameraInformation.CameraFixedInformationResponse.self)
        
        return response
    }
}
