//
//  CircularWheelViewModel.swift
//  HonestHouse
//
//  Created by Subeen on 11/9/25.
//

import SwiftUI

@Observable
final class CircularWheelViewModel {
    @ObservationIgnored @Binding var isDimmed: Bool
    
    var isCircleVisible: Bool = false
    var circleSize: CGFloat = 100
    var buttonCenter: CGPoint = .zero
    var isDragging: Bool = false
    var currentAngle: Double = 100.0  // thumb의 현재 각도 (-60 ~ 60 범위)
    var settingType: WheelSettingType
    
    let minCircleSize: CGFloat = 120
    let maxCircleSize: CGFloat = 370
    
    init(settingType: WheelSettingType, isDimmed: Binding<Bool>) {
        self.settingType = settingType
        self._isDimmed = isDimmed
    }
   
    
    func toggleCircle() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if isDragging {
                return
            }
            
            if isCircleVisible {
                isCircleVisible = false
                isDimmed = false
            } else {
                isCircleVisible = true
                circleSize = minCircleSize
                isDimmed = true
            }
        }
    }
    
    func startDragging() {
        isDragging = true
        isDimmed = true
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isCircleVisible = true
            circleSize = minCircleSize
        }
    }
    
    func updateDragWithAngle(_ translation: CGSize) -> Int {
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
        
        // 4. 범위로 제한
        angleInDegrees = max(settingType.minAngle, min(settingType.maxAngle, angleInDegrees))
        
        circleSize = mappedSize
        currentAngle = angleInDegrees
        
        // 5. 각도를 인덱스로 변환하여 반환
        return indexFromAngle(angleInDegrees)
    }
    
    // 각도를 인덱스로 변환하는 함수
    private func indexFromAngle(_ angle: Double) -> Int {
        // 각도를 0.0~1.0 범위로 정규화
        let normalized = (angle - settingType.minAngle) / settingType.angleRange
        
        // 정규화된 값을 range 범위로 변환
        let range = settingType.range
        var value = range.lowerBound + Int(normalized * Double(range.upperBound - range.lowerBound))
        
        // step 단위로 스냅
        let step = settingType.step
        value = Int(round(Double(value) / Double(step))) * step
        
        // 최종 범위 제한
        return min(max(value, range.lowerBound), range.upperBound)
    }
    
    func endDragging() {
        isDragging = false
        isDimmed = false

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
