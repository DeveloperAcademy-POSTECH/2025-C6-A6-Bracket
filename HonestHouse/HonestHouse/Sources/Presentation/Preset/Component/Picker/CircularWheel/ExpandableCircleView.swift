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
            .overlay {
                if vm.isCircleVisible {
                    ExpandableCircle(
                        viewModel: vm,
                        value: $value,
                        type: .exposure,
                        size: vm.circleSize,
                        isVisible: vm.isCircleVisible
                    )
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
