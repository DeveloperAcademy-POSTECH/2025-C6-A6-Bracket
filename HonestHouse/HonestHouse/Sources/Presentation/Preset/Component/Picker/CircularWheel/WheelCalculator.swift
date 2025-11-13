//
//  WheelCalculator.swift
//  HonestHouse
//
//  Created by Subeen on 11/13/25.
//


//
//  WheelCalculator.swift
//  HonestHouse
//
//  Created by Subeen on 11/13/25.
//

import Foundation

struct WheelCalculator {
    
    // MARK: - 인덱스 ↔ 각도 변환
    
    static func indexToAngle(index: Int, type: WheelSettingType) -> Double {
        let totalCount: Int
        switch type {
        case .tintMagentaGreen:
            totalCount = CameraConstants.tintMagentaGreenValues.count
        case .exposureCompensation:
            totalCount = CameraConstants.exposureCompensationValues.count
        case .colorTemperature:
            totalCount = CameraConstants.colorTemperatureValues.count
        }
        
        let normalized = Double(index) / Double(totalCount - 1)
        return type.minAngle + type.angleRange * normalized
    }
    
    static func angleToIndex(angle: Double, type: WheelSettingType, circleSize: CircleSizeType) -> Int {
        // 각도를 정규화 (0~1)
        let normalized = (angle - type.minAngle) / type.angleRange
        
        let totalCount: Int
        switch type {
        case .tintMagentaGreen:
            totalCount = CameraConstants.tintMagentaGreenValues.count
        case .exposureCompensation:
            totalCount = CameraConstants.exposureCompensationValues.count
        case .colorTemperature:
            totalCount = CameraConstants.colorTemperatureValues.count
        }
        
        let rawIndex = normalized * Double(totalCount - 1)
        let closestIndex = Int(round(rawIndex))
        
        // 타입과 크기에 따른 스냅 적용
        return snapToValidIndex(closestIndex, type: type, size: circleSize)
    }
    
    // MARK: - 스냅 로직 (간단한 버전)
    
    static func snapToValidIndex(_ index: Int, type: WheelSettingType, size: CircleSizeType) -> Int {
        // 범위 제한
        let maxIndex: Int
        switch type {
        case .tintMagentaGreen:
            maxIndex = CameraConstants.tintMagentaGreenValues.count - 1
        case .exposureCompensation:
            maxIndex = CameraConstants.exposureCompensationValues.count - 1
        case .colorTemperature:
            maxIndex = CameraConstants.colorTemperatureValues.count - 1
        }
        
        let clamped = min(max(index, 0), maxIndex)
        
        // 타입별 특별 규칙
        switch type {
        case .tintMagentaGreen:
            if size == .small {
                // 3의 배수 값만 선택 (-6, -3, 0, 3, 6)
                let validIndices = CameraConstants.tintMagentaGreenValues.enumerated()
                    .compactMap { index, value in
                        value % 3 == 0 ? index : nil
                    }
                
                return validIndices.min(by: { 
                    abs($0 - clamped) < abs($1 - clamped) 
                }) ?? clamped
            }
            return clamped
            
        case .exposureCompensation:
            // 항상 3의 배수 인덱스
            return (clamped / 3) * 3
            
        case .colorTemperature:
            return clamped
        }
    }
    
    // MARK: - 원 크기 계산
    
    static func circleSizeType(from diameter: CGFloat) -> CircleSizeType {
        if diameter < 260 {
            return .small
        } else if diameter < 370 {
            return .medium
        } else {
            return .large
        }
    }
    
    static func mapDragToCircleSize(_ distance: CGFloat) -> CGFloat {
        let minSize: CGFloat = 120
        let maxSize: CGFloat = 370
        let maxDistance: CGFloat = 120
        
        let normalizedDistance = min(distance, maxDistance)
        let ratio = normalizedDistance / maxDistance
        
        return minSize + (maxSize - minSize) * ratio
    }
}