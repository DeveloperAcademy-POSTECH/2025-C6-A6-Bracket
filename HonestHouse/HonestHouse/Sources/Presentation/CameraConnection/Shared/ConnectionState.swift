//
//  ConnectionState.swift
//  HonestHouse
//
//  Created by Rama on 11/3/25.
//

import Foundation

enum ConnectionState: Equatable {
    case disconnected
    case connecting
    case connected
    case failed(ConnectionError)
}
