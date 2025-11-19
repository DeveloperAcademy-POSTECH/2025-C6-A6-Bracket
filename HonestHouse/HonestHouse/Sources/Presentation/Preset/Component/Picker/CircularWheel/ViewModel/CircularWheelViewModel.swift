//
//  CircularWheelViewModel.swift
//  HonestHouse
//
//  Created by Subeen on 11/13/25.
//

import SwiftUI

@Observable
final class CircularWheelViewModel {
    var isCircleVisible = false
    var circleSize: CGFloat = 120
    var isDragging = false
    var buttonType: PresetDetailSettingButtonType = .activated
    let settingType: WheelSettingType

    var circleSizeType: CircularWheelSizeType {
        CircularWheelCalculator.wheelSizeType(from: circleSize)
    }
    
    init(settingType: WheelSettingType) {
        self.settingType = settingType
    }
    
    func toggleCircle() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isCircleVisible.toggle()
            if !isCircleVisible {
                circleSize = 120
            }
        }
    }
    
    func startDragging() {
        isDragging = true
        
        if !isCircleVisible {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isCircleVisible = true
                buttonType = .selected
                circleSize = 120
            }
        }
    }
    
    func updateCircleSize(with distance: CGFloat) {
        circleSize = CircularWheelCalculator.mapDragTowheelSize(distance)
    }
    
    func endDragging() {
        isDragging = false
        
        withAnimation {
            circleSize = 120
            buttonType = .activated
        }
        
        toggleCircle()
    }
}

