//
//  CircularWheelViewModel.swift
//  HonestHouse
//
//  Created by Subeen on 11/13/25.
//

import SwiftUI

@Observable
final class CircularWheelViewModel {
    // MARK: - Properties
    var isCircleVisible = false
    var circleSize: CGFloat = 120
    var isDragging = false
    let settingType: WheelSettingType
    @ObservationIgnored @Binding var isDimmed: Bool
    
    // Computed property
    var circleSizeType: CircularWheelSizeType {
        CircularWheelCalculator.wheelSizeType(from: circleSize)
    }
    
    init(settingType: WheelSettingType, isDimmed: Binding<Bool>) {
        self.settingType = settingType
        self._isDimmed = isDimmed
    }
    
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
        circleSize = CircularWheelCalculator.mapDragTowheelSize(distance)
    }
    
    func endDragging() {
        withAnimation {
            circleSize = 120
        }
        isDragging = false
        isDimmed = false
        
        toggleCircle()
    }
}

