//
//  ConnectionError.swift
//  HonestHouse
//
//  Created by Rama on 11/4/25.
//

import Foundation

enum ConnectionError: Error, LocalizedError, Equatable {
    case authenticationFailed
    case cameraBusy
    case invalidIPAddress
    case ccapiUnavailableOnBluetoothWiFi
    case generic(String)
    
    var errorDescription: String? {
        switch self {
        case .authenticationFailed:
            return "카메라 인증에 실패했습니다. 다시 시도해주세요."
        case .cameraBusy:
            return "카메라가 사용 중이거나 응답이 없습니다."
        case .invalidIPAddress:
            return "입력한 주소가 올바르지 않습니다."
        case .ccapiUnavailableOnBluetoothWiFi:
            return "블루투스로 켠 카메라 Wi-Fi에서는 CCAPI가 응답하지 않습니다. 'PTP/IP로 연결'을 시도하거나, 카메라에서 CCAPI 연결 후 '주소'로 연결해주세요."
        case .generic(let message):
            return "알 수 없는 오류가 발생했습니다: \(message)"
        }
    }
}

extension ConnectionError {
    static func from(_ error: Error) -> ConnectionError {
        if let ccapiError = error as? CCAPIError {
            switch ccapiError {
            case .authenticationFailed(_):
                return .authenticationFailed
            case .deviceBusy, .deviceShooting:
                return .cameraBusy
            default:
                return .generic(ccapiError.localizedDescription)
            }
        }
        
        return .generic(error.localizedDescription)
    }
}
