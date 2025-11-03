//
//  Aperturescrollpicker.swift
//  HonestHouse
//
//  Created by Subeen on 11/4/25.
//

import SwiftUI

import SwiftUI

struct ApertureScrollPicker: View {
    // MARK: - Properties
    @State private var selectedIndex: Int = 0
    var apertureData = ApertureData.standardApertures
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    @State private var isLoaded: Bool = false
    
    // MARK: - Body
    var body: some View {
        GeometryReader {
            let size = $0.size
            let horizontalPadding = size.width / 2
            ScrollView(.horizontal) {
                HStack(spacing: 20) {
                    let totalSteps = ApertureData.standardApertures.count
                    ForEach(apertureData.indices, id: \.self) { index in
                        Text(apertureData[index])
                            .font(.num4)
                            .foregroundColor(
                                selectedIndex == index ? .yellow1 : .g0
                            )
                            .onTapGesture {
                                withAnimation {
                                    selectedIndex = index
                                }
                            }
                    }
                }
                .frame(maxHeight: .infinity)
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .safeAreaPadding(.horizontal, horizontalPadding)
 
            .scrollPosition(id: .init(get: {
                let position: Int? = isLoaded ? selectedIndex : nil
                return position
            }, set: { newValue in
                if let newValue = newValue,
                   newValue != selectedIndex {
                    selectedIndex = newValue
                    hapticFeedback.impactOccurred()
                }
            }))
            
        }
        .frame(height: 52)
        .overlay(alignment: .center) {
            VStack(spacing: 36) {
                Rectangle().frame(width: 1, height: 8)
                Rectangle().frame(width: 1, height: 8)
            }
            .foregroundStyle(Color.g0)
        }
        .onAppear {
            if !isLoaded { isLoaded = true }
        }
        .background(Color.g12)
        .overlay {
            gradientOverlay(width: 120)
        }
        .clipShape(RoundedRectangle(cornerRadius: 100))
        .overlay {
            RoundedRectangle(cornerRadius: 100)
                .strokeBorder(Color.g0, lineWidth: 0.5)
        }
    }
    
    
    // MARK: - Gradient Overlay
    private func gradientOverlay(width: CGFloat) -> some View {
        HStack(spacing: 0) {
            // 좌측 그라데이션
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.g12,
                    Color.g12.opacity(0)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 120)
            
            Spacer()
            
            // 우측 그라데이션
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.g12.opacity(0),
                    Color.g12
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 120)
        }
        .allowsHitTesting(false)
    }
}

import Foundation

// MARK: - Aperture Data
struct ApertureData {
    // 일반적인 조리개 값 배열 (f/1.0 ~ f/22)
    // 실제 카메라에서 사용되는 표준 조리개 값
    static let standardApertures: [String] = [
        "f1.0",
        "f1.1",
        "f1.2",
        "f1.4",
        "f1.6",
        "f1.8",  // 인덱스 5
        "f2.0",
        "f2.2",
        "f2.5",
        "f2.8",
        "f3.2",
        "f3.5",
        "f4.0",
        "f4.5",
        "f5.0",
        "f5.6",
        "f6.3",
        "f7.1",
        "f8.0",
        "f9.0",
        "f10",
        "f11",
        "f13",
        "f14",
        "f16",
        "f18",
        "f20",
        "f22"
    ]
}

#Preview {
    ApertureScrollPicker()

}
