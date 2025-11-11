//
//  5. ContentInfo.swift
//  HonestHouse
//
//  Created by 이현주 on 11/11/25.
//

import Foundation

struct ContentInfo {
    let dateInfo: Date?
    
    init(dateInfo: String?) {
        // String을 Date로 변환
        if let dateString = dateInfo {
            self.dateInfo = DateFormatter.apiDateFormatter.date(from: dateString)
        } else {
            self.dateInfo = nil
        }
    }
}
