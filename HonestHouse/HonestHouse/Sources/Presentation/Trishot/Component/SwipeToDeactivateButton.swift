//
//  SwipeToDeactivateButton.swift
//  HonestHouse
//
//  Created by BoMin Lee on 11/10/25.
//

import SwiftUI

struct SwipeToDeactivateButton: View {
    let action: () -> Void

    @State private var dragOffset: CGFloat = 0
    @State private var isCompleted: Bool = false

    private let circleSize: CGFloat = 92
    private let slideThreshold: CGFloat = 200

    var body: some View {
        GeometryReader { geometry in
            let progress = min(max(dragOffset / slideThreshold, 0), 1)

            ZStack(alignment: .leading) {
                backgroundCapsuleView()
                deactivateTextView(progress: progress)
                draggableCircleView(geometry: geometry, progress: progress)
            }
        }
        .frame(height: 100)
    }

    private func backgroundCapsuleView() -> some View {
        Capsule()
            .fill(Color.g11)
    }

    private func deactivateTextView(progress: CGFloat) -> some View {
        HStack {
            Spacer()
            Text("밀어서 중단")
                .fontStyle(.num1)
                .foregroundColor(interpolateColor(from: Color.g7, to: Color.g10, progress: progress))
                .offset(x: 24)
            Spacer()
        }
    }

    private func draggableCircleView(geometry: GeometryProxy, progress: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(interpolateColor(from: Color.yellow1, to: Color.yellow2, progress: progress))
                .frame(width: circleSize, height: circleSize)

            RoundedRectangle(cornerRadius: 2)
                .frame(width: 22, height: 22)
                .foregroundStyle(Color.g12)
        }
        .offset(x: dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    handleDragChanged(value: value, geometry: geometry)
                }
                .onEnded { value in
                    handleDragEnded(value: value, geometry: geometry)
                }
        )
        .padding(.vertical, 4)
        .padding(.leading, 4)
    }

    private func handleDragChanged(value: DragGesture.Value, geometry: GeometryProxy) {
        let translation = value.translation.width
        let maxOffset = geometry.size.width - (circleSize + 8)

        if translation >= 0 {
            dragOffset = min(translation, maxOffset)
        }
    }

    private func handleDragEnded(value: DragGesture.Value, geometry: GeometryProxy) {
        if dragOffset >= slideThreshold {
            withAnimation(.spring(response: 0.2)) {
                dragOffset = geometry.size.width - (circleSize + 8)
                isCompleted = true
            }

            // 의도적 딜레이
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                action()
            }
            
        } else {
            withAnimation(.spring(response: 0.2)) {
                dragOffset = 0
            }
        }
    }

    private func interpolateColor(from: Color, to: Color, progress: CGFloat) -> Color {
        let fromComponents = UIColor(from).cgColor.components ?? [0, 0, 0, 1]
        let toComponents = UIColor(to).cgColor.components ?? [0, 0, 0, 1]

        let r = fromComponents[0] + (toComponents[0] - fromComponents[0]) * progress
        let g = fromComponents[1] + (toComponents[1] - fromComponents[1]) * progress
        let b = fromComponents[2] + (toComponents[2] - fromComponents[2]) * progress
        let a = fromComponents[3] + (toComponents[3] - fromComponents[3]) * progress

        return Color(red: r, green: g, blue: b, opacity: a)
    }
}
