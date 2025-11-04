//
//  CameraConnectionManager.swift
//  HonestHouse
//
//  Created by Rama on 11/2/25.
//
import SwiftUI

@MainActor
final class CameraConnectionManager: ObservableObject {
    
    @Published var connectionState: ConnectionState = .disconnected
    
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
                print("✅ 카메라 연결 성공")
            } catch {
                let connectionError = ConnectionError.from(error)
                self.connectionState = .failed(connectionError)
                print("❌ 카메라 연결 실패: \(connectionError.localizedDescription)")
            }
        }
    }
    
    func disconnectCamera() {
        connectionState = .disconnected
    }
}
