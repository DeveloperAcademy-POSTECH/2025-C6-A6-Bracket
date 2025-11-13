//
//  BaseURLConstants.swift
//  HonestHouse
//
//  Created by Rama on 11/2/25.
//

enum BaseURLConstants {
    static var cameraIP = ""
    static var scheme = ""
    static var port = ""
    static var baseURL: String {
        "\(scheme)://\(cameraIP):\(port)/ccapi/"
    }
}
