//
//  PickerScrollTargetBehavior.swift
//  HonestHouse
//
//  Created by Subeen on 11/4/25.
//

import SwiftUI

struct PickerScrollTargetBehavior: ScrollTargetBehavior {
    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        target.rect.origin = .init(x: 0, y: 0)
    }
}


import SwiftUI

struct CenterSnapScrollTargetBehavior: ScrollTargetBehavior {
    let itemWidth: CGFloat
    let spacing: CGFloat
    
    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        // 컨테이너(ScrollView)의 너비
        let containerWidth = context.containerSize.width
        
        // 화면 중앙 위치
        let centerOffset = containerWidth / 2
        
        // 현재 스크롤 위치에서 중앙에 오는 아이템 찾기
        // 스크롤 위치 + 화면 중앙 = 실제 보이는 중앙 위치
        let visibleCenterX = target.rect.origin.x + centerOffset
        
        // 아이템 전체 너비 (아이템 너비 + 간격)
        let totalItemWidth = itemWidth + spacing
        
        // 중앙에 가장 가까운 아이템 인덱스 계산
        // 아이템 중앙 위치를 기준으로 계산
        let itemIndex = round((visibleCenterX - itemWidth / 2) / totalItemWidth)
        
        // 인덱스 범위 제한 (음수 방지)
        let clampedIndex = max(0, itemIndex)
        
        // 해당 아이템이 중앙에 오도록 하는 스크롤 위치 계산
        // 아이템의 시작 위치 + 아이템 너비의 절반 - 화면 중앙
        let snappedX = (clampedIndex * totalItemWidth) + (itemWidth / 2) - centerOffset
        
        // 최소 스크롤 위치는 0
        target.rect.origin.x = max(0, snappedX)
    }
}


import SwiftUI

struct CenterSnapScrollTargetBehavior2: ScrollTargetBehavior {
    let itemWidth: CGFloat
    let spacing: CGFloat
    
    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        // 1. 화면(컨테이너)의 중앙 위치
        let halfWidth = context.containerSize.width / 2
        
        // 2. 아이템 전체 너비 (아이템 + 간격)
        let totalItemWidth = itemWidth + spacing
        
        // 3. 현재 보이는 영역의 중앙점 (가로 스크롤이므로 midX 사용)
        let targetMidX = target.rect.midX
        
        // 4. 가장 가까운 아이템 인덱스 찾기
        let targetIndex = round(targetMidX / totalItemWidth)
        
        // 5. 해당 아이템의 중심 X 위치 계산
        let itemCenterX = targetIndex * totalItemWidth + (itemWidth / 2)
        
        // 6. 아이템을 화면 중앙에 놓기 위한 스크롤 오프셋
        let finalOffset = itemCenterX - halfWidth
        
        // 7. 최종 위치 설정 (음수 방지)
        target.rect.origin.x = max(0, finalOffset)
    }
}
