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
    var viewMode: PresetDetailViewMode
    let settingType: WheelSettingType

    var circleSizeType: CircularWheelSizeType {
        CircularWheelCalculator.wheelSizeType(from: circleSize)
    }
    
    init(viewMode: PresetDetailViewMode, settingType: WheelSettingType) {
        self.viewMode = viewMode
        self.settingType = settingType
    }
    
    func toggleCircle() {
        if viewMode == .view { return }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isCircleVisible.toggle()
            if !isCircleVisible {
                circleSize = 120
            }
        }
    }
    
    func startDragging() {
        if viewMode == .view { return }
        
        isDragging = true
        
        if !isCircleVisible {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isCircleVisible = true
                circleSize = 120
            }
        }
    }
    
    func updateCircleSize(with distance: CGFloat) {
        if viewMode == .view { return }
        
        circleSize = CircularWheelCalculator.mapDragTowheelSize(distance)
    }
    
    func endDragging() {
        if viewMode == .view { return }
        
        isDragging = false
        
        withAnimation {
            circleSize = 120
        }
        
        toggleCircle()
    }
}
