//
//  CircularWheelPickerView.swift
//  HonestHouse
//
//  Created by Subeen on 11/10/25.
//

import SwiftUI

struct CircularWheelPickerView: View {
    
    @State var vm: CircularWheelViewModel
    private let coordinateSpaceName = "circleExpandSpace"
    
    @State var value: Int = 0
    
    var body: some View {
        
        ExpandableButton(viewModel: vm, coordinateSpace: coordinateSpaceName, value: $value)
            .overlay {
                if vm.isCircleVisible {
                    ExpandableCircle(
                        viewModel: vm,
                        value: $value,
                        type: vm.settingType,
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
            CircularWheelPickerView(vm: .init(settingType: .tintMagentaGreen, isDimmed: .constant(true)))
            Spacer()
            CircularWheelPickerView(vm: .init(settingType: .exposureCompensation, isDimmed: .constant(false)))
            Spacer()
            CircularWheelPickerView(vm: .init(settingType: .colorTemperature, isDimmed: .constant(false)))
        }
    }
    .preferredColorScheme(.dark)
}
