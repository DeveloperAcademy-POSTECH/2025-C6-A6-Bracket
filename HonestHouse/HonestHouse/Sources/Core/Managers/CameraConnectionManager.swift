//
//  CameraConnectionManager.swift
//  HonestHouse
//
//  Created by Rama on 11/2/25.
//

import Foundation

enum ConnectionState: Equatable {
    case disconnected
    case connecting
    case connected
    case failed(String)
}

@MainActor
final class CameraConnectionManager: ObservableObject {
    
    @Published var isConnected: Bool = false
    @Published var connectionState: ConnectionState = .disconnected
    @Published var errorMessage: String?
    
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    func connectCamera(ipAddress: String) {
        connectionState = .connecting
        errorMessage = nil
        
        networkManager.configure(cameraIP: ipAddress)
        
        Task {
            do {
                try await networkManager.initializeAuthentication()
                self.isConnected = true
                self.connectionState = .connected
                print("✅ 카메라 연결 성공")
            } catch {
                self.isConnected = false
                self.connectionState = .failed(error.localizedDescription)
                self.errorMessage = error.localizedDescription
                print("❌ 카메라 연결 실패: \(error)")
            }
        }
    }
    
    func disconnectCamera() {
        // TODO: 필요시 구현
        isConnected = false
        connectionState = .disconnected
    }
}
