//
//  CustomWheelPicker.swift
//  HonestHouse
//
//  Created by Subeen on 11/4/25.
//

import SwiftUI

struct LinearWheelPicker<SelectionValue, Content>: View where SelectionValue: Hashable & Sendable, Content: View {
    @State private var scrollPosition: ScrollPosition = .init(idType: SelectionValue.self)
    @State private var lastHapticItem: SelectionValue?
    
    @Binding private var selection: SelectionValue
    
    private var items: [SelectionValue]
    private var content: (SelectionValue) -> Content
    
    private let config: Config
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    
    init(
        items: [SelectionValue],
        selection: Binding<SelectionValue>,
        config: Config,
        @ViewBuilder content: @escaping (SelectionValue) -> Content
    ) {
        self.items = items
        self.content = content
        self.config = config
        _selection = selection
    }
    

    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: config.spacing) {
                    ForEach(Array(items.enumerated()), id: \.element) { index, item in
                        content(item)
                            .frame(width: config.itemSize.width, height: config.itemSize.height)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                // 탭한 아이템을 중앙으로 이동
                                withAnimation(.smooth(duration: 0.3)) {
                                    scrollPosition.scrollTo(id: item)
                                    selection = item
                                    
                                    // 탭 시 햅틱 피드백
                                    hapticFeedback.impactOccurred()
                                }
                            }
                    }
                }
                .frame(height: 52)
                .background(Color.g12)
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition($scrollPosition, anchor: .center)
            .contentMargins(.horizontal, max((size.width - config.itemSize.width) / 2, 0))
            .onAppear {
                // 초기 위치 설정
                hapticFeedback.prepare()
                scrollPosition.scrollTo(id: selection)
            }
            .onChange(of: scrollPosition) { oldValue, newValue in
                Task { @MainActor in
                    if let newSelection = newValue.viewID(type: SelectionValue.self) {
                        // 새로운 아이템 선택 시
                        if selection != newSelection {
                            selection = newSelection
                            
                            // 햅틱 피드백 (중복 방지)
                            if lastHapticItem != newSelection {
                                hapticFeedback.impactOccurred()
                                lastHapticItem = newSelection
                            }
                        }
                    }
                }
            }
            .onChange(of: selection) { _, newValue in
                // 외부에서 selection 변경 시 스크롤 위치 동기화
                if scrollPosition.viewID(type: SelectionValue.self) != newValue {
                    withAnimation(.smooth(duration: 0.3)) {
                        scrollPosition.scrollTo(id: newValue)
                    }
                }
            }
        }
    }
}

extension View {
    func disableBounces() -> some View {
        modifier(DisableBouncesModifier())
    }
}

struct DisableBouncesModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                UIScrollView.appearance().bounces = false
            }
            .onDisappear {
                UIScrollView.appearance().bounces = true
            }
    }
}
