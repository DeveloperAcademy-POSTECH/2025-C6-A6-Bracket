//
//  BaseURLConstants.swift
//  HonestHouse
//
//  Created by Rama on 11/2/25.
//

//TODO: 동시성 안전성 적용 필요

enum BaseURLConstants {
    static var cameraIP = ""
    static var scheme = ""
    static var port = ""
    static var baseURL: String {
        "\(scheme)://\(cameraIP):\(port)/ccapi/"
    }
}
