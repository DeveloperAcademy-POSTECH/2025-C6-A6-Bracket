//
//  CameraType.swift
//  HonestHouse
//
//  Created by BoMin Lee on 11/7/25.
//

import Foundation

enum CameraType: String, CaseIterable {
    case eos1DXMarkIII = "EOS-1D X Mark III"
    case eosR5 = "EOS R5"
    case eosR6 = "EOS R6"
    case eosR3 = "EOS R3"
    case eosR7 = "EOS R7"
    case eosR6MarkII = "EOS R6 Mark II"
    case eosR8 = "EOS R8"
    case eosR50 = "EOS R50"
    case powerShotV10 = "PowerShot V10"
    case eosR5MARKII = "EOS R5 Mark II"
    case eosR1 = "EOS R1"
    case eosR50V = "EOS R50V"
        
    var displayName: String {
        return rawValue
    }
    
    private static let userDefaultsKey = "connectedCameraType"
    
    /// 현재 연결된 카메라 타입을 UserDefaults에서 불러오기
    static var current: CameraType? {
        get {
            guard let rawValue = UserDefaults.standard.string(forKey: userDefaultsKey) else {
                return nil
            }
            return CameraType(rawValue: rawValue)
        }
        set {
            if let newValue = newValue {
                UserDefaults.standard.set(newValue.rawValue, forKey: userDefaultsKey)
            } else {
                UserDefaults.standard.removeObject(forKey: userDefaultsKey)
            }
        }
    }
    
    /// UserDefaults에서 카메라 타입 제거
    static func clearCurrent() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
    
    /// 모드 다이얼 유무
    var hasShootingModeDial: Bool {
        switch self {
        case .eosR50, .eosR6MarkII, .eos1DXMarkIII, .eosR5, .eosR6, .eosR3, .eosR7, .eosR8, .powerShotV10, .eosR5MARKII, .eosR1:
            return true
        case .eosR50V:
            return false
        }
    }
    
    /// Image Operations API 버전
    var imageOperationsVersion: VersionType {
        switch self {
        case .eos1DXMarkIII, .eosR5, .eosR6, .eosR3, .eosR7:
            return .ver110
        case .eosR50, .eosR6MarkII, .eosR8, .powerShotV10:
            return .ver120
        case .eosR50V, .eosR5MARKII, .eosR1:
            return .ver140
        }
    }

    /// Event Monitor API 버전
    var eventMonitorVersion: VersionType {
        switch self {
        case .eos1DXMarkIII, .eosR1, .eosR5, .eosR6, .eosR3, .eosR7, .eosR8, .eosR50, .powerShotV10, .eosR5MARKII, .eosR6MarkII, .eosR50V:
            return .ver100
        }
    }

    /// Shooting Control API 버전
    var shootingControlVersion: VersionType {
        switch self {
        case .eos1DXMarkIII, .eosR1, .eosR5, .eosR6, .eosR3, .eosR7, .eosR8, .powerShotV10, .eosR5MARKII, .eosR50, .eosR6MarkII, .eosR50V:
            return .ver100
        }
    }

    /// Shooting Settings API별 버전 반환
    func shootingSettingsVersion(for api: ShootingSettingsAPI) -> VersionType {
        switch self {
        case .eosR50V:
            // R50V는 shooting mode만 ver110, 나머지는 ver100
            switch api {
            case .shootingMode:
                return .ver110
            default:
                return .ver100
            }

        // 다른 카메라들은 모든 Shooting Settings API가 ver100
        default:
            return .ver100
        }
    }
}
