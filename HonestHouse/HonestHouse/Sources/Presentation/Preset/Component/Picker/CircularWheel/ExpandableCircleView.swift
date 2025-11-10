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
                ExpandableCircle(type: .mg, size: vm.circleSize, center: vm.buttonCenter, isVisible: vm.isCircleVisible)
            }
            .coordinateSpace(name: coordinateSpaceName)
    }
}

#Preview {
    ExpandableCircleView()
        .preferredColorScheme(.dark)
}
