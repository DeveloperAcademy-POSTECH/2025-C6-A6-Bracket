//
//  CameraConnectionManagerType.swift
//  HonestHouse
//
//  Created by Rama on 11/2/25.
//

import Foundation

protocol CameraConnectionManagerType {
    func connectCamera(ipAddress: String, port: Int)
    func disconnectCamera()
}
