//
//  CameraConnectionManagerType.swift
//  HonestHouse
//
//  Created by Rama on 11/2/25.
//

import Foundation

protocol CameraConnectionManagerType: ObservableObject {
    var isConnected: Bool { get }
    var connectionState: ConnectionState { get }
    var errorMessage: String? { get }
    
    func connectCamera(ipAddress: String)
    func disconnectCamera()
}
