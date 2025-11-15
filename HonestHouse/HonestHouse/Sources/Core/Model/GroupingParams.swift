//
//  GroupingParams.swift
//  HonestHouse
//
//  Created by 이현주 on 11/15/25.
//

import Foundation

struct GroupingParams {
    // visual 가중치 (0~1). 높을수록 시각적 유사도 중시
    let alpha: Float
    // 시간 감쇠 표준편차(초). 작을수록 시간 차이에 민감
    let timeSigma: TimeInterval
    // 시간 패널티 상한(0~1)
    let maxTimePenalty: Float
    
    static let `default` = GroupingParams(
        alpha: 0.7,
        timeSigma: 10 * 60,  // 10분
        maxTimePenalty: 0.9
    )
}
