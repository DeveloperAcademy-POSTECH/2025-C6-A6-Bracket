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
    var currentAngle: Double = 0.0  // thumb의 현재 각도 (-60 ~ 60 범위)
    
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
    
    func updateDragWithAngle(_ translation: CGSize) {
        // 1. 드래그 거리 계산 (피타고라스 정리)
        let distance = sqrt(pow(translation.width, 2) + pow(translation.height, 2))
        
        // 2. 거리를 원 크기(직경)로 매핑
        let mappedSize = min(max(minCircleSize + distance * 2, minCircleSize), maxCircleSize)
        
        // 3. 드래그 방향을 각도로 변환
        // atan2를 사용하여 translation에서 각도 계산
        let angleInRadians = atan2(translation.height, translation.width)
        var angleInDegrees = angleInRadians * 180 / .pi
        
        // 4. SwiftUI 좌표계 보정 (오른쪽이 0도, 시계방향이 양수)
        // 위쪽을 0도로 만들기 위해 90도 빼기
        angleInDegrees = angleInDegrees - 90
        
        // 5. -60 ~ 60 범위로 제한 (120도 arc)
        angleInDegrees = max(-60, min(60, angleInDegrees))
        
        withAnimation(.default) {
            circleSize = mappedSize
            currentAngle = angleInDegrees
        }
    }
    
    func endDragging() {
        isDragging = false
        // 드래그 종료 시 현재 크기 유지
        withAnimation {
            circleSize = minCircleSize
            currentAngle = 0.0  // 각도도 초기화
        }
        
        toggleCircle()
    }
    
    func updateButtonCenter(_ center: CGPoint) {
        buttonCenter = center
    }
}
