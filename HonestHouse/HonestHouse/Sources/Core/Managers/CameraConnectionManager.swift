//
//  CameraConnectionManager.swift
//  HonestHouse
//
//  Created by Rama on 11/2/25.
//
import SwiftUI

@MainActor
final class CameraConnectionManager: ObservableObject {
    
    @Published var productName: String = ""
    @Published var connectionState: ConnectionState = .disconnected
    @Published var showConnectionSheet = false
    
    private let networkManager: NetworkManager
    private let jsonDecoder = JSONDecoder()
    
    
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
                
                let cameraInfo = try await getCameraInfo(with: .ver100)
                
                if let productName = cameraInfo.productName {
                    self.productName = productName
                }
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
    
    func getCameraInfo(with: VersionType) async throws -> CameraInformation.CameraFixedInformationResponse {
        let response = try await networkManager.request(CameraInformationTarget.getCameraFixedInformation)
        
        do {
            let decodedResponse = try jsonDecoder.decode(CameraInformation.CameraFixedInformationResponse.self, from: response.data)
            return decodedResponse
        } catch {
            throw error
        }
    }
}
