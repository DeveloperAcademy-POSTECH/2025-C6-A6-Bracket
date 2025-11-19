//
//  ExpandableButton.swift
//  HonestHouse
//
//  Created by Subeen on 11/13/25.
//

import SwiftUI

struct ExpandableButton: View {
    @Bindable var viewModel: CircularWheelViewModel
    @Binding var value: Int
    let coordinateSpace: String
    
    var body: some View {
        Button {
            viewModel.toggleCircle()
        } label: {
            viewModel.settingType.icon
                .renderingMode(.template)
                .frame(width: 64, height: 64)
        }
        .buttonStyle(PresetDetailSettingButtonStyle(viewModel.buttonType))
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { dragValue in
                    if dragValue.translation == .zero { return }
                    
                    if !viewModel.isDragging {
                        viewModel.startDragging()
                    }
                    
                    // 원 크기 업데이트
                    let distance = sqrt(
                        pow(dragValue.translation.width, 2) +
                        pow(dragValue.translation.height, 2)
                    )
                    viewModel.updateCircleSize(with: distance)
                    
                    // 각도 계산해서 index 업데이트
                    let angleInRadians = atan2(dragValue.translation.width, -dragValue.translation.height)
                    var angleInDegrees = angleInRadians * 180 / .pi
                    
                    // 타입별 각도 범위 제한
                    angleInDegrees = max(viewModel.settingType.minAngle,
                                        min(viewModel.settingType.maxAngle, angleInDegrees))
                    
                    // index 업데이트
                    value = CircularWheelCalculator.angleToIndex(
                        angle: angleInDegrees,
                        type: viewModel.settingType,
                        circleSize: viewModel.circleSizeType
                    )
                }
                .onEnded { _ in
                    if viewModel.isDragging {
                        viewModel.endDragging()
                    }
                }
        )
    }
}
