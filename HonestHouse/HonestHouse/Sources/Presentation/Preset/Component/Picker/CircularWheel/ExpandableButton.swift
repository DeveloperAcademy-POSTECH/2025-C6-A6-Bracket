//
//  ExpandableButton.swift
//  HonestHouse
//
//  Created by Subeen on 11/10/25.
//

import SwiftUI

struct ExpandableButton: View {
    
    @Bindable var viewModel: CircularWheelViewModel
    @Binding var value: Int
    let coordinateSpace: String
    
    var body: some View {
        
        VStack {

            Button {
                viewModel.isCircleVisible.toggle()
            } label: {
                viewModel.settingType.icon
                    .frame(width: 64, height: 64)
            }
            .buttonStyle(PresetDetailSettingButtonStyle(.activated))
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
                        } else {
                            viewModel.toggleCircle()
                        }
                    }
            )
        }
    }
}

#Preview {
    @Previewable @State var value = 0
    ExpandableButton(viewModel: .init(settingType: .exposureCompensation, isDimmed: .constant(false)), value: $value, coordinateSpace: "")
}
