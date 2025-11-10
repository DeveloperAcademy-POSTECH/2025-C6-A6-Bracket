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
    var settingType: WheelSettingType
    @ObservationIgnored @Binding var isDimmed: Bool
    
    let minCircleSize: CGFloat = 120
    let maxCircleSize: CGFloat = 370
    
    init(settingType: WheelSettingType, isDimmed: Binding<Bool>) {
        self.settingType = settingType
        self._isDimmed = isDimmed
    }
   
    
    func toggleCircle() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if isDragging {
                // 드래그 중이면 토글하지 않음
                return
            }
            
            if isCircleVisible {
                // 원이 보이는 상태면 숨기기
                isCircleVisible = false
                isDimmed = false  // dim 비활성화
            } else {
                // 원이 안 보이면 표시하고 기본 크기로 설정
                isCircleVisible = true
                circleSize = minCircleSize
                isDimmed = true  // dim 활성화
            }
        }
    }
    
    func startDragging() {
        isDragging = true
        isDimmed = true  // 원이 보이면 dim 활성화
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
        // translation.height: 아래로 = 양수, 위로 = 음수
        // translation.width: 오른쪽 = 양수, 왼쪽 = 음수
        let angleInRadians = atan2(translation.width, -translation.height)  // -height로 방향 반전
        var angleInDegrees = angleInRadians * 180 / .pi
        
        // 4. -70 ~ 70 범위로 제한 (140도 arc)
        angleInDegrees = max(-70, min(70, angleInDegrees))
        
        circleSize = mappedSize
        currentAngle = angleInDegrees
    }
    
    func endDragging() {
        isDragging = false
        isDimmed = false  // dim 비활성화
        // 드래그 종료 시 현재 크기만 초기화, 각도는 유지
        withAnimation {
            circleSize = minCircleSize
            // currentAngle은 유지하여 thumb 위치 저장
        }
        
        toggleCircle()
    }
    
    func updateButtonCenter(_ center: CGPoint) {
        buttonCenter = center
    }
}
