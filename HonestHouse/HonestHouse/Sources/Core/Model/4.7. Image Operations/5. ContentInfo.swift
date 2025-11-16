//
//  5. ContentInfo.swift
//  HonestHouse
//
//  Created by 이현주 on 11/11/25.
//

import Foundation

struct ContentInfo {
    var dateInfo: Date?
    
    init(dateInfo: String?) {
        if let dateString = dateInfo {
            self.dateInfo = DateFormatter.apiDateFormatter.date(from: dateString)
            // 타임존 포함
            if let date = DateFormatter.apiDateFormatter.date(from: dateString) {
                self.dateInfo = date
            }
            // 타임존 없음
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
