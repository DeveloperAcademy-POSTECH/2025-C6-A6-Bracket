//
//  ShootingSettingsService.swift
//  HonestHouse
//
//  Created by Subeen on 10/23/25.
//

import Foundation

protocol ShootingSettingsServiceType {
    /// 촬영 모드
    func getShootingMode() async throws -> ShootingSettings.ShootingModeResponse
    func putShootingMode(request: ShootingSettings.ShootingModeRequest) async throws -> ShootingSettings.ShootingModeResponse
    func getShootingModeDial() async throws -> ShootingSettings.ShootingModeResponse
    func putShootingModeDial(request: ShootingSettings.ShootingModeRequest) async throws -> ShootingSettings.ShootingModeResponse
    /// 조리개
    func getAV() async throws -> ShootingSettings.AVResponse
    func putAV(request: ShootingSettings.AVRequest) async throws -> ShootingSettings.AVResponse
    /// 셔터스피드
    func getTV() async throws -> ShootingSettings.TVResponse
    func putTV(request: ShootingSettings.TVRequest) async throws -> ShootingSettings.TVResponse
    /// ISO
    func getISO() async throws -> ShootingSettings.ISOResponse
    func putISO(request: ShootingSettings.ISORequest) async throws -> ShootingSettings.ISOResponse
    /// 노출 보정
    func getExposureCompensation() async throws -> ShootingSettings.ExposureCompensationResponse
    func putExposureCompensation(request: ShootingSettings.ExposureCompensationRequest) async throws -> ShootingSettings.ExposureCompensationResponse
    /// 화이트 밸런스
    func getWhiteBalance() async throws -> ShootingSettings.WhiteBalanceResponse
    func putWhiteBalance(request: ShootingSettings.WhiteBalanceRequest) async throws -> ShootingSettings.WhiteBalanceResponse
    /// 색온도
    func getColorTemperature() async throws -> ShootingSettings.ColorTemperatureResponse
    func putColorTemperature(request: ShootingSettings.ColorTemperatureRequest) async throws -> ShootingSettings.ColorTemperatureResponse
    /// 화이트 밸런스 쉬프트(틴트)
    func getWbShift() async throws -> ShootingSettings.WBShiftResponse
    func putWbShift(request: ShootingSettings.WBShiftRequest) async throws -> ShootingSettings.WBShiftResponse
    /// 픽쳐스타일
    func getPictureStyle() async throws -> ShootingSettings.PictureStyleResponse
    func putPictureStyle(request: ShootingSettings.PictureStyleRequest) async throws -> ShootingSettings.PictureStyleResponse
}

final class ShootingSettingsService: BaseService, ShootingSettingsServiceType {
    func getShootingMode() async throws -> ShootingSettings.ShootingModeResponse {
        let response = try await request(ShootingSettingsTarget.getShootingMode, decoding: ShootingSettings.ShootingModeResponse.self)
        return response
    }
    
    func putShootingMode(request: ShootingSettings.ShootingModeRequest) async throws -> ShootingSettings.ShootingModeResponse {
        let response = try await self.request(ShootingSettingsTarget.putShootingMode(request), decoding: ShootingSettings.ShootingModeResponse.self)
        return response
    }
    
    func getShootingModeDial() async throws -> ShootingSettings.ShootingModeResponse {
        let response = try await request(ShootingSettingsTarget.getShootingMode, decoding: ShootingSettings.ShootingModeResponse.self)
        return response
    }
    
    func putShootingModeDial(request: ShootingSettings.ShootingModeRequest) async throws -> ShootingSettings.ShootingModeResponse {
        let response = try await self.request(ShootingSettingsTarget.putShootingMode(request), decoding: ShootingSettings.ShootingModeResponse.self)
        return response
    }
    
    func getAV() async throws -> ShootingSettings.AVResponse {
        let response = try await request(ShootingSettingsTarget.getAv, decoding: ShootingSettings.AVResponse.self)
        return response
    }

    func putAV(request: ShootingSettings.AVRequest) async throws -> ShootingSettings.AVResponse {
        let response = try await self.request(ShootingSettingsTarget.putAv(request), decoding: ShootingSettings.AVResponse.self)
        return response
    }

    func getTV() async throws -> ShootingSettings.TVResponse {
        let response = try await request(ShootingSettingsTarget.getTv, decoding: ShootingSettings.TVResponse.self)
        return response
    }

    func putTV(request: ShootingSettings.TVRequest) async throws -> ShootingSettings.TVResponse {
        let response = try await self.request(ShootingSettingsTarget.putTv(request), decoding: ShootingSettings.TVResponse.self)
        return response
    }

    func getISO() async throws -> ShootingSettings.ISOResponse {
        let response = try await request(ShootingSettingsTarget.getIso, decoding: ShootingSettings.ISOResponse.self)
        return response
    }

    func putISO(request: ShootingSettings.ISORequest) async throws -> ShootingSettings.ISOResponse {
        let response = try await self.request(ShootingSettingsTarget.putIso(request), decoding: ShootingSettings.ISOResponse.self)
        return response
    }

    func getExposureCompensation() async throws -> ShootingSettings.ExposureCompensationResponse {
        let response = try await request(ShootingSettingsTarget.getExposureCompensation, decoding: ShootingSettings.ExposureCompensationResponse.self)
        return response
    }

    func putExposureCompensation(request: ShootingSettings.ExposureCompensationRequest) async throws -> ShootingSettings.ExposureCompensationResponse {
        let response = try await self.request(ShootingSettingsTarget.putExposureCompensation(request), decoding: ShootingSettings.ExposureCompensationResponse.self)
        return response
    }

    func getWhiteBalance() async throws -> ShootingSettings.WhiteBalanceResponse {
        let response = try await request(ShootingSettingsTarget.getWhiteBalance, decoding: ShootingSettings.WhiteBalanceResponse.self)
        return response
    }

    func putWhiteBalance(request: ShootingSettings.WhiteBalanceRequest) async throws -> ShootingSettings.WhiteBalanceResponse {
        let response = try await self.request(ShootingSettingsTarget.putWhiteBalance(request), decoding: ShootingSettings.WhiteBalanceResponse.self)
        return response
    }

    func getColorTemperature() async throws -> ShootingSettings.ColorTemperatureResponse {
        let response = try await request(ShootingSettingsTarget.getColorTemperature, decoding: ShootingSettings.ColorTemperatureResponse.self)
        return response
    }

    func putColorTemperature(request: ShootingSettings.ColorTemperatureRequest) async throws -> ShootingSettings.ColorTemperatureResponse {
        let response = try await self.request(ShootingSettingsTarget.putColorTemperature(request), decoding: ShootingSettings.ColorTemperatureResponse.self)
        return response
    }

    func getWbShift() async throws -> ShootingSettings.WBShiftResponse {
        let response = try await request(ShootingSettingsTarget.getWbShift, decoding: ShootingSettings.WBShiftResponse.self)
        return response
    }

    func putWbShift(request: ShootingSettings.WBShiftRequest) async throws -> ShootingSettings.WBShiftResponse {
        let response = try await self.request(ShootingSettingsTarget.putWbShift(request), decoding: ShootingSettings.WBShiftResponse.self)
        return response
    }

    func getPictureStyle() async throws -> ShootingSettings.PictureStyleResponse {
        let response = try await request(ShootingSettingsTarget.getPictureStyle, decoding: ShootingSettings.PictureStyleResponse.self)
        return response
    }

    func putPictureStyle(request: ShootingSettings.PictureStyleRequest) async throws -> ShootingSettings.PictureStyleResponse {
        let response = try await self.request(ShootingSettingsTarget.putPictureStyle(request), decoding: ShootingSettings.PictureStyleResponse.self)
        return response
    }
}

class StubShootingSettingsService: ShootingSettingsServiceType {
    func putShootingMode(request: ShootingSettings.ShootingModeRequest) async throws -> ShootingSettings.ShootingModeResponse {
        return .stub1
    }
    
    func getShootingModeDial() async throws -> ShootingSettings.ShootingModeResponse {
        return .stub1
    }
    
    func putShootingModeDial(request: ShootingSettings.ShootingModeRequest) async throws -> ShootingSettings.ShootingModeResponse {
        return .stub1
    }
    
    func getAV() async throws -> ShootingSettings.AVResponse {
        return .stub1
    }
    
    func putAV(request: ShootingSettings.AVRequest) async throws -> ShootingSettings.AVResponse {
        return .stub1
    }
    
    func getTV() async throws -> ShootingSettings.TVResponse {
        return .stub1
    }
    
    func putTV(request: ShootingSettings.TVRequest) async throws -> ShootingSettings.TVResponse {
        return .stub1
    }
    
    func getISO() async throws -> ShootingSettings.ISOResponse {
        return .stub1
    }
    
    func putISO(request: ShootingSettings.ISORequest) async throws -> ShootingSettings.ISOResponse {
        return .stub1
    }
    
    func getExposureCompensation() async throws -> ShootingSettings.ExposureCompensationResponse {
        return .stub1
    }

    func putExposureCompensation(request: ShootingSettings.ExposureCompensationRequest) async throws -> ShootingSettings.ExposureCompensationResponse {
        return .stub1
    }
    
    func getWhiteBalance() async throws -> ShootingSettings.WhiteBalanceResponse {
        return .stub1
    }
    
    func putWhiteBalance(request: ShootingSettings.WhiteBalanceRequest) async throws -> ShootingSettings.WhiteBalanceResponse {
        return .stub1
    }
    
    func getColorTemperature() async throws -> ShootingSettings.ColorTemperatureResponse {
        return .stub1
    }
    
    func putColorTemperature(request: ShootingSettings.ColorTemperatureRequest) async throws -> ShootingSettings.ColorTemperatureResponse {
        return .stub1
    }
    
    func getWbShift() async throws -> ShootingSettings.WBShiftResponse {
        return .stub1
    }
    
    func putWbShift(request: ShootingSettings.WBShiftRequest) async throws -> ShootingSettings.WBShiftResponse {
        return .stub1
    }
    
    func putPictureStyle(request: ShootingSettings.PictureStyleRequest) async throws -> ShootingSettings.PictureStyleResponse {
        return .stub1
    }
    
    func getShootingMode() async throws -> ShootingSettings.ShootingModeResponse {
        return .stub1
    }
    
    func getPictureStyle() async throws -> ShootingSettings.PictureStyleResponse {
        return .stub1
    }
}
