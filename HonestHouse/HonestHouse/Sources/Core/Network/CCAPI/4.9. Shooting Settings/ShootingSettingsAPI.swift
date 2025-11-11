//
//  ShootingSettingsAPI.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

import Foundation

/// 촬영 설정 (Shooting Settings)
enum ShootingSettingsAPI {
    case getShootingSetting                     /// 모든 촬영 매개변수
    case shootingMode                           /// 사진촬영 모드 (촬영 다이얼 없는 모델)
    case shootingModeDial                       /// 사진촬영 모드 (촬영 다이얼 있는 모델)
    case av                                     /// 조리개
    case tv                                     /// 셔터스피드
    case iso                                    /// ISO
    case exposureCompensation                   /// 노출보정
    case whiteBalance                           /// 화이트밸런스
    case colorTemperature                        /// 색온도
    case wbShift                                /// 화이트밸런스 보정 (Blue/Amber, Green/Magenta)
    case pictureStyle                           /// 픽쳐스타일
    
    var endpoint: String {
        switch self {
        case .getShootingSetting:
            return "shooting/settings"
            
        case .shootingMode:
            return "shooting/settings/shootingmode"
            
        case .shootingModeDial:
            return "shooting/settings/shootingmodedial"
            
        case .av:
            return "shooting/settings/av"
            
        case .tv:
            return "shooting/settings/tv"
            
        case .iso:
            return "shooting/settings/iso"
            
        case .exposureCompensation:
            return "shooting/settings/exposure"
            
        case .whiteBalance:
            return "shooting/settings/wb"
            
        case .colorTemperature:
            return "shooting/settings/colortemperature"
            
        case .wbShift:
            return "shooting/settings/wbshift"
            
        case .pictureStyle:
            return "shooting/settings/picturestyle"
        }
    }
    
    func path(with version: VersionType) -> String {
        return "\(version.description)/\(endpoint)"
    }
}
