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
    
    var body: some View {
        Button {
            
        } label: {
            Text("dd")
                .background(Color.red.opacity(0.3))
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
                    
                    viewModel.updateDragDistance(value.translation)
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

#Preview {
    ExpandableButton(viewModel: .init(), coordinateSpace: "")
}
