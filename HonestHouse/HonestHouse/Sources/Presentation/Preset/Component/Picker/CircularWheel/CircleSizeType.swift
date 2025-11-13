//
//  CircleSizeType.swift
//  HonestHouse
//
//  Created by Subeen on 11/13/25.
//


import SwiftUI

enum CircleSizeType {
    case small
    case medium
    case large
    
    var size: Double {
        switch self {
        case .small:
            return 120
        case .medium:
            return 260
        case .large:
            return 370
        }
    }
}

@Observable
final class CircularWheelViewModel {
    // MARK: - Properties
    var isCircleVisible = false
    var circleSize: CGFloat = 120
    var isDragging = false
    let settingType: WheelSettingType
    @ObservationIgnored @Binding var isDimmed: Bool
    
    // Computed property
    var circleSizeType: CircleSizeType {
        WheelCalculator.circleSizeType(from: circleSize)
    }
    
    // MARK: - Initialization
    init(settingType: WheelSettingType, isDimmed: Binding<Bool>) {
        self.settingType = settingType
        self._isDimmed = isDimmed
    }
    
    // MARK: - Methods
    func toggleCircle() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isCircleVisible.toggle()
            isDimmed = isCircleVisible
            if !isCircleVisible {
                circleSize = 120
            }
        }
    }
    
    func startDragging() {
        isDragging = true
        isDimmed = true
        if !isCircleVisible {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isCircleVisible = true
                circleSize = 120
            }
        }
    }
    
    func updateCircleSize(with distance: CGFloat) {
        circleSize = WheelCalculator.mapDragToCircleSize(distance)
    }
    
    func endDragging() {
        isDragging = false
        isDimmed = false
        withAnimation {
            circleSize = 120
        }
        toggleCircle()
    }
}
