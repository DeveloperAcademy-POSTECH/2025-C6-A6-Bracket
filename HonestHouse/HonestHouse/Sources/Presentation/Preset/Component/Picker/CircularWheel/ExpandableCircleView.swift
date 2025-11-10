//
//  ExpandableCircleView.swift
//  HonestHouse
//
//  Created by Subeen on 11/10/25.
//

import SwiftUI

struct ExpandableCircleView: View {
    
    @State var vm = CircularWheelViewModel()
    private let coordinateSpaceName = "circleExpandSpace"
    
    @State var value: Int = 0
    
    var body: some View {
        ExpandableButton(viewModel: vm, coordinateSpace: coordinateSpaceName)
            .onPreferenceChange(ButtonFrameKey.self) { frame in
                // 버튼 중심점 계산
                let center = CGPoint(
                    x: frame.midX,
                    y: frame.midY
                )
                vm.updateButtonCenter(center)
            }
            .overlay {
                if vm.isCircleVisible {
                    ExpandableCircle(isDragging: $vm.isDragging, value: $value, type: .exposure, size: vm.circleSize, center: vm.buttonCenter, isVisible: vm.isCircleVisible)
                        .allowsHitTesting(false)
                }
            }
            .coordinateSpace(name: coordinateSpaceName)
    }
}

#Preview {
    ZStack {
        Color.g12
        HStack {
            ExpandableCircleView()
            Spacer()
            ExpandableCircleView()
            Spacer()
            ExpandableCircleView()
        }

        
    }
        .preferredColorScheme(.dark)
}
