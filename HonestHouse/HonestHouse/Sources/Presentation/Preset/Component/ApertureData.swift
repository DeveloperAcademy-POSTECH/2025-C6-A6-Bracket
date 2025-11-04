//
//  ApertureData.swift
//  HonestHouse
//
//  Created by Subeen on 11/4/25.
//

import Foundation
import SwiftUI

// MARK: - Aperture Data Model
// 커스텀 휠 피커를 만들기 위해 임의로 작성한 파일입니다.
// 카메라로부터 조정가능값 배열을 받으면 해당 파일은 삭제할 예정.
struct ApertureData {
    // 표준 조리개 값 배열 (f/1.0 ~ f/22)
    static let standardApertures: [String] = [
        "f1.0",
        "f1.1",
        "f1.2",
        "f1.4",
        "f1.6",
        "f1.8",
        "f2.0",
        "f2.2",
        "f2.5",
        "f2.8",  // 기본값으로 사용
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
    
    // 디스플레이 설정
    var numberOfDisplays: CGFloat = 7  // 화면에 보이는 아이템 개수
    var spacing: CGFloat = 22          // 아이템 간 간격
    var itemSize: CGSize = .init(width: 40, height: 24)  // 각 아이템 크기
    
    // 기본 선택값
    static let defaultAperture: String = "f2.8"
}
