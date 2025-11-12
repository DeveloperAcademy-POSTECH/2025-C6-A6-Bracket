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
    
    // CameraType.current를 통해 UserDefaults에서 관리되는 값을 사용
    var connectedCameraType: CameraType? {
        get {
            return CameraType.current
        }
        set {
            CameraType.current = newValue
        }
    }
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
        
        if let savedCameraType = CameraType.current {
            connectionState = .connected
            productName = savedCameraType.displayName  // 추가
        }
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
                    self.connectedCameraType = CameraType(rawValue: productName)
                }
                
            } catch {
                let connectionError = ConnectionError.from(error)
                self.connectionState = .failed(connectionError)
                self.connectedCameraType = nil
                Logger.error(error.localizedDescription, category: .connection)
            }
        }
    }
    
    func disconnectCamera() {
        connectionState = .disconnected
        CameraType.clearCurrent()
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
