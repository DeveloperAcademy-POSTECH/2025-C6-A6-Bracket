//
//  CustomSegmentedControl.swift
//  HonestHouse
//
//  Created by Subeen on 11/4/25.
//

import SwiftUI

struct CustomSegmentedControl: View {
    @Binding var selection: MainViewSegmentType
    
    private let height: CGFloat = 44
    private let segments = MainViewSegmentType.allCases
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 배경 캡슐
                Capsule()
                    .stroke(Color.g0, lineWidth: 0.5)
                    .background(Capsule().fill(Color.g12))
                
                // 슬라이드 배경 (애니메이션)
                Capsule()
                    .fill(Color.g0)
                    .frame(width: segmentWidth(geometry: geometry) - 8)
                    .offset(x: selectedSegmentOffset(geometry: geometry))
                    .padding(4)
                    .animation(.spring(response: 0.3), value: selection)
                
                // 세그먼트 버튼들
                HStack(spacing: 0) {
                    ForEach(segments, id: \.self) { segment in
                        Button {
                            selection = segment
                        } label: {
                            Text(segment.displayName)
                                .fontStyle(.num6)
                                .foregroundStyle(selection == segment ? Color.g12 : Color.g0)
                                .frame(maxWidth: .infinity)
                                .frame(height: height)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(NoHighlightButtonStyle())
                    }
                }
            }
        }
        .frame(height: height)
    }
    
    /// 각 세그먼트의 너비 계산
    private func segmentWidth(geometry: GeometryProxy) -> CGFloat {
        geometry.size.width / CGFloat(segments.count)
    }
    
    /// 선택된 세그먼트의 offset 계산
    private func selectedSegmentOffset(geometry: GeometryProxy) -> CGFloat {
        guard let index = segments.firstIndex(of: selection) else { return 0 }
        return CGFloat(index) * segmentWidth(geometry: geometry)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selection: MainViewSegmentType = .preset
        
        var body: some View {
            VStack {
                CustomSegmentedControl(selection: $selection)
                
                Text("Selected: \(selection.displayName)")
                    .foregroundStyle(.white)
            }
            .background(Color.black)
        }
    }
    
    return PreviewWrapper()
}
