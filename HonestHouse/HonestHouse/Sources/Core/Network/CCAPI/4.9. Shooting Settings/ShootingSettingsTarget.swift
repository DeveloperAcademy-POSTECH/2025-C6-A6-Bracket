//
//  ShootingSettingsTarget.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

import Moya

enum ShootingSettingsTarget {
    case getShootingSetting(VersionType)                                         /// 모든 촬영 매개변수
    case getShootingMode                                                         /// 사진촬영 모드
    case putShootingMode(ShootingSettings.ShootingModeRequest)                   /// 사진촬영 모드
    case getAv                                                                   /// 조리개
    case putAv(ShootingSettings.AVRequest)                                       /// 조리개
    case getTv                                                                   /// 셔터스피드
    case putTv(ShootingSettings.TVRequest)                                       /// 셔터스피드
    case getIso                                                                  /// ISO
    case putIso(ShootingSettings.ISORequest)                                     /// ISO
    case getExposureCompensation                                                 /// 노출보정
    case putExposureCompensation(ShootingSettings.ExposureCompensationRequest)   /// 노출보정
    case getWhiteBalance                                                         /// 화이트밸런스
    case putWhiteBalance(ShootingSettings.WhiteBalanceRequest)                   /// 화이트밸런스
    case getColorTemperature                                                     /// 색온도
    case putColorTemperature(ShootingSettings.ColorTemperatureRequest)           /// 색온도
    case getWbShift                                     /// 화이트밸런스 보정 (Blue/Amber, Green/Magenta)
    case putWbShift(ShootingSettings.WBShiftRequest)    /// 화이트밸런스 보정 (Blue/Amber, Green/Magenta)
    case getPictureStyle                                                         /// 픽쳐스타일
    case putPictureStyle(ShootingSettings.PictureStyleRequest)                   /// 픽쳐스타일
}

extension ShootingSettingsTarget: BaseTargetType {
    var path: String {
        // UserDefaults에서 카메라 타입 가져오기
        guard let cameraType = CameraType.current else {
            // TODO: 에러 처리
            return defaultPath
        }
        
        switch self {
        case .getShootingSetting:
            let version = cameraType.shootingSettingsVersion(for: .getShootingSetting)
            return ShootingSettingsAPI.getShootingSetting.path(with: version)
            
        case .getShootingMode, .putShootingMode:
            let version = cameraType.shootingSettingsVersion(for: .shootingMode)
            let endpoint = cameraType.hasShootingModeDial
            ? ShootingSettingsAPI.shootingModeDial
            : ShootingSettingsAPI.shootingMode
            return endpoint.path(with: version)
            
        case .getAv, .putAv:
            let version = cameraType.shootingSettingsVersion(for: .av)
            return ShootingSettingsAPI.av.path(with: version)
            
        case .getTv, .putTv:
            let version = cameraType.shootingSettingsVersion(for: .tv)
            return ShootingSettingsAPI.tv.path(with: version)
            
        case .getIso, .putIso:
            let version = cameraType.shootingSettingsVersion(for: .iso)
            return ShootingSettingsAPI.iso.path(with: version)
            
        case .getExposureCompensation, .putExposureCompensation:
            let version = cameraType.shootingSettingsVersion(for: .exposureCompensation)
            return ShootingSettingsAPI.exposureCompensation.path(with: version)
            
        case .getWhiteBalance, .putWhiteBalance:
            let version = cameraType.shootingSettingsVersion(for: .whiteBalance)
            return ShootingSettingsAPI.whiteBalance.path(with: version)
            
        case .getColorTemperature, .putColorTemperature:
            let version = cameraType.shootingSettingsVersion(for: .colorTemperature)
            return ShootingSettingsAPI.colorTemperature.path(with: version)
            
        case .getWbShift, .putWbShift:
            let version = cameraType.shootingSettingsVersion(for: .wbShift)
            return ShootingSettingsAPI.wbShift.path(with: version)
            
        case .getPictureStyle, .putPictureStyle:
            let version = cameraType.shootingSettingsVersion(for: .pictureStyle)
            return ShootingSettingsAPI.pictureStyle.path(with: version)
        }
    }
    
    private var defaultPath: String {
        switch self {
        case .getShootingSetting:
            return ShootingSettingsAPI.getShootingSetting.path(with: .ver100)
            
        case .getShootingMode, .putShootingMode:
            return ShootingSettingsAPI.shootingMode.path(with: .ver110)
            
        case .getAv, .putAv:
            return ShootingSettingsAPI.av.path(with: .ver100)
    
        case .getTv, .putTv:
            return ShootingSettingsAPI.tv.path(with: .ver100)
            
        case .getIso, .putIso:
            return ShootingSettingsAPI.iso.path(with: .ver100)

        case .getExposureCompensation, .putExposureCompensation:
            return ShootingSettingsAPI.exposureCompensation.path(with: .ver100)

        case .getWhiteBalance, .putWhiteBalance:
            return ShootingSettingsAPI.whiteBalance.path(with: .ver100)

        case .getColorTemperature, .putColorTemperature:
            return ShootingSettingsAPI.colorTemperature.path(with: .ver100)

        case .getWbShift, .putWbShift:
            return ShootingSettingsAPI.wbShift.path(with: .ver100)
            
        case .getPictureStyle, .putPictureStyle:
            return ShootingSettingsAPI.pictureStyle.path(with: .ver100)
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getShootingSetting,
                .getShootingMode,
                .getAv,
                .getTv,
                .getIso,
                .getExposureCompensation,
                .getWhiteBalance,
                .getColorTemperature,
                .getWbShift,
                .getPictureStyle:
                return .get

        case .putShootingMode,
                .putAv,
                .putTv,
                .putIso,
                .putExposureCompensation,
                .putWhiteBalance,
                .putColorTemperature,
                .putWbShift,
                .putPictureStyle:
            return .put

        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getShootingSetting,
                .getShootingMode,
                .getAv,
                .getTv,
                .getIso,
                .getExposureCompensation,
                .getWhiteBalance,
                .getColorTemperature,
                .getWbShift,
                .getPictureStyle:
            return .requestPlain
    
        case .putShootingMode(let request):
            return .requestJSONEncodable(request)

        case .putAv(let request):
            return .requestJSONEncodable(request)

        case .putTv(let request):
            return .requestJSONEncodable(request)

        case .putIso(let request):
            return .requestJSONEncodable(request)

        case .putExposureCompensation(let request):
            return .requestJSONEncodable(request)

        case .putWhiteBalance(let request):
            return .requestJSONEncodable(request)

        case .putColorTemperature(let request):
            return .requestJSONEncodable(request)
            
        case .putWbShift(let request):
            return .requestJSONEncodable(request)
            
        case .putPictureStyle(let request):
            return .requestJSONEncodable(request)
        }
    }
}
