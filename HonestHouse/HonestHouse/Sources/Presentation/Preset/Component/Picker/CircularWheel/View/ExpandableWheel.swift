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
    let presetViewModel: PresetDetailViewModel
    
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
                            withAnimation {
                                viewModel.isCircleVisible.toggle()
                            }
                            // 드래그 종료 시 preset 값 업데이트 및 카메라 적용
                            updatePresetAndApplyCamera()
                        }
                )
        }
        .frame(width: viewModel.circleSize, height: viewModel.circleSize)
        .sensoryFeedback(.selection, trigger: index)
        // index가 변경될 때마다 Preset 값 업데이트 및 카메라 설정 적용
        .onChange(of: index) { oldValue, newValue in
            // View 모드가 아니고, 실제로 값이 변경되었을 때만 적용
            guard viewModel.viewMode != .view, oldValue != newValue else { return }
            
            // Preset 값 업데이트 및 카메라 적용
            updatePresetAndApplyCamera()
        }
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
    
    // Preset 값 업데이트 및 카메라 적용
    private func updatePresetAndApplyCamera() {
        switch type {
        case .tintMagentaGreen:
            guard index >= 0 && index < CameraConstants.tintMagentaGreenValues.count else {
                Logger.error("Invalid index \(index) for tintMagentaGreen", category: .preset)
                return
            }
            
            let value = CameraConstants.tintMagentaGreenValues[index]
            preset.tintMagentaGreen = value
            
            guard viewModel.viewMode != .view else { return }
            Task {
                await presetViewModel.applyCameraSettings(for: .tintMagentaGreen, value: value)
            }
            
        case .exposureCompensation:
            guard index >= 0 && index < CameraConstants.exposureCompensationValues.count else {
                Logger.error("Invalid index \(index) for exposureCompensation", category: .preset)
                return
            }
            
            let value = CameraConstants.exposureCompensationValues[index]
            preset.exposureCompensation = value
            
            guard viewModel.viewMode != .view else { return }
            Task {
                await presetViewModel.applyCameraSettings(for: .exposure, value: value)
            }
            
        case .colorTemperature:
            guard index >= 0 && index < CameraConstants.colorTemperatureValues.count else {
                Logger.error("Invalid index \(index) for colorTemperature", category: .preset)
                return
            }
            
            let value = CameraConstants.colorTemperatureValues[index]
            preset.colorTemperature = value
            
            guard viewModel.viewMode != .view else { return }
            Task {
                await presetViewModel.applyCameraSettings(for: .colorTemp, value: value)
            }
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
