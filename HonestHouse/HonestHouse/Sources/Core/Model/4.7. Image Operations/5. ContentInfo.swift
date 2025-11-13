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
            // 타임존 포함 (예: "Wed, 04 Jul 2018 12:34:56 GMT")
            if let date = DateFormatter.apiDateFormatter.date(from: dateString) {
                self.dateInfo = date
            }
            // 타임존 없음 (예: "Tue, 11 Nov 2025 21:02:28")
            else if let date = DateFormatter.apiDateFormatterWithoutTimezone.date(from: dateString) {
                self.dateInfo = date
            }
            // 파싱 실패
            else {
                self.dateInfo = nil
            }
        } else {
            self.dateInfo = nil
        }
    }
}
