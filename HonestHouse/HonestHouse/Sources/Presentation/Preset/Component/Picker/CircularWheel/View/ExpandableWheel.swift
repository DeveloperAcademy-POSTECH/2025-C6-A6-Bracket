//
//  ExpandableWheel.swift
//  HonestHouse
//
//  Created by Subeen on 11/13/25.
//

import Foundation
import SwiftUI

// 드래그로 값을 지정하는 휠
struct ExpandableWheel: View {
    
    @Bindable var viewModel: CircularWheelViewModel
    @Binding var index: Int
    @Binding var preset: Preset
    
    let type: WheelSettingType
    let isVisible: Bool
    
    private var currentAngle: Double {
        CircularWheelCalculator.indexToAngle(index: index, type: type)
    }
    
    private var thumbPosition: CGPoint {
        let angle = (currentAngle - 90) * .pi / 180
        let radius = viewModel.circleSize / 2
        
        return CGPoint(
            x: radius + radius * Foundation.cos(angle),
            y: radius + radius * Foundation.sin(angle)
        )
    }
    
    var body: some View {
        ZStack {
            // 원
            Circle()
                .stroke(type.strokeColor, lineWidth: 4)
                .frame(width: viewModel.circleSize, height: viewModel.circleSize)
            
            // 라벨
            ForEach(0..<type.range.upperBound + 1, id: \.self) { idx in
                if shouldShowLabel(at: idx) {
                    WheelLabelView(
                        index: idx,
                        currentIndex: index,
                        type: type,
                        circleSize: viewModel.circleSize,
                        circleSizeType: viewModel.circleSizeType
                    )
                }
            }
            
            // 썸
            Circle()
                .fill(Color.g0)
                .frame(width: 12, height: 12)
                .position(thumbPosition)
            
            // 제스처 영역
            Circle()
                .fill(Color.clear)
                .contentShape(Circle())
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            handleDrag(at: gesture.location)
                        }
                        .onEnded { _ in
                            viewModel.isDragging = false
//                            viewModel.isCircleVisible = false
                            withAnimation {
                                viewModel.isCircleVisible.toggle()
                            }
                            setValue()
                        }
                )
        }
        .frame(width: viewModel.circleSize, height: viewModel.circleSize)
        .sensoryFeedback(.selection, trigger: index)
    }
    
    // 휠 제스처
    private func handleDrag(at location: CGPoint) {
        let center = viewModel.circleSize / 2
        let deltaX = location.x - center
        let deltaY = location.y - center
        
        guard sqrt(deltaX * deltaX + deltaY * deltaY) > 5 else { return }
        
        if !viewModel.isDragging {
            viewModel.isDragging = true
        }
        
        let angleInRadians = atan2(deltaX, -deltaY)
        let angleInDegrees = angleInRadians * 180 / .pi
        let clampedAngle = max(type.minAngle, min(type.maxAngle, angleInDegrees))
        
        index = CircularWheelCalculator.angleToIndex(
            angle: clampedAngle,
            type: type,
            circleSize: viewModel.circleSizeType
        )
    }
    
    private func setValue() {
        switch type {
        case .tintMagentaGreen:
            preset.tintMagentaGreen = CameraConstants.tintMagentaGreenValues[index]
            
        case .exposureCompensation:
            preset.exposureCompensation = CameraConstants.exposureCompensationValues[index]
            
        case .colorTemperature:
            preset.exposureCompensation = CameraConstants.colorTemperatureValues[index].description
        }
    }
    
    private func shouldShowLabel(at idx: Int) -> Bool {
        switch type {
        case .tintMagentaGreen:
            guard idx < CameraConstants.tintMagentaGreenValues.count else { return false }
            let value = CameraConstants.tintMagentaGreenValues[idx]
            return viewModel.circleSizeType == .small ? value % 3 == 0 : true
            
        case .exposureCompensation:
            guard idx < CameraConstants.exposureCompensationValues.count else { return false }
            return idx % 3 == 0
            
        case .colorTemperature:
            guard idx < CameraConstants.colorTemperatureValues.count else { return false }
            return idx == 0 || idx == type.range.upperBound || idx == index
        }
    }
}
