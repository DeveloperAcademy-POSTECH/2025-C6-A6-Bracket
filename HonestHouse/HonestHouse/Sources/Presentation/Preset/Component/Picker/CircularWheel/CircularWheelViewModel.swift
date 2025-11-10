//
//  CircularWheelViewModel.swift
//  HonestHouse
//
//  Created by Subeen on 11/9/25.
//

import SwiftUI

@Observable
final class CircularWheelViewModel {
    var isCircleVisible: Bool = false
    var circleSize: CGFloat = 100
    var buttonCenter: CGPoint = .zero
    var isDragging: Bool = false
    
    let minCircleSize: CGFloat = 120
    let maxCircleSize: CGFloat = 370
    
    func toggleCircle() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if isDragging {
                // 드래그 중이면 토글하지 않음
                return
            }
            
            if isCircleVisible {
                // 원이 보이는 상태면 숨기기
                isCircleVisible = false
            } else {
                // 원이 안 보이면 표시하고 기본 크기로 설정
                isCircleVisible = true
                circleSize = minCircleSize
            }
        }
    }
    
    func startDragging() {
        isDragging = true
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isCircleVisible = true
            circleSize = minCircleSize
        }
    }
    
    func updateDragDistance(_ translation: CGSize) {
        // 드래그 거리 계산 (피타고라스 정리)
        let distance = sqrt(pow(translation.width, 2) + pow(translation.height, 2))
        
        // 거리를 원 크기(직경)로 매핑
        let mappedSize = min(max(minCircleSize + distance * 2, minCircleSize), maxCircleSize)
        
        withAnimation(.default) {
            circleSize = mappedSize
        }
    }
    
    func endDragging() {
        isDragging = false
        // 드래그 종료 시 현재 크기 유지
        withAnimation {
            circleSize = minCircleSize
        }
        
        toggleCircle()
    }
    
    func updateButtonCenter(_ center: CGPoint) {
        buttonCenter = center
    }
}
