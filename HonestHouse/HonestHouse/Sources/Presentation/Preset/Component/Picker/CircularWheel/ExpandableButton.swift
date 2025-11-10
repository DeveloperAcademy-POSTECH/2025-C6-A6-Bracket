//
//  ExpandableButton.swift
//  HonestHouse
//
//  Created by Subeen on 11/10/25.
//

import SwiftUI

struct ExpandableButton: View {
    
    @Bindable var viewModel: CircularWheelViewModel
    let coordinateSpace: String
    @Binding var value: Int  // 현재 값 전달받기
    
    var body: some View {
        Button {
            
        } label: {
            Text(viewModel.settingType.formatValue(value))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 64, height: 64)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.15))
                )
        }
        .background(
            GeometryReader { geometry in
                Color.clear
                    .preference(
                        key: ButtonFrameKey.self,
                        value: geometry.frame(in: .named(coordinateSpace))
                    )
            }
        )
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if value.translation == .zero {
                        return
                    }
                    
                    if !viewModel.isDragging {
                        viewModel.startDragging()
                    }
                    
                    // 거리와 각도를 동시에 업데이트
                    viewModel.updateDragWithAngle(value.translation)
                }
                .onEnded { _ in
                    if viewModel.isDragging {
                        viewModel.endDragging()
                        print("\(viewModel.circleSize)")
                    } else {
                        viewModel.toggleCircle()
                    }
                }
        )
    }
}

#Preview {
    @Previewable @State var value = 0
    ExpandableButton(viewModel: .init(settingType: .exposure, isDimmed: .constant(false)), coordinateSpace: "", value: $value)
}
