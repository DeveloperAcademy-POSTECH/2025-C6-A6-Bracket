//
//  DateFormatter.swift
//  HonestHouse
//
//  Created by Rama on 11/5/25.
//

import Foundation

extension DateFormatter {
    static func logTimestamp(_ date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: date)
    }
    
    /// API lastmodifieddate 파싱용: "Wed, 04 Jul 2018 12:34:56 GMT"
    static let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        return formatter
    }()

    /// API lastmodifieddate 파싱용 (타임존 없는 버전): "Tue, 11 Nov 2025 21:02:28"
    static let apiDateFormatterWithoutTimezone: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        return formatter
    }()
    
    /// 날짜 키 생성용: "yyyy-MM-dd"
    static let dateKeyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        return formatter
    }()
    
    /// 섹션 헤더 표시용: "2025. 11. 11"
    static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy. M. d"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        return formatter
    }()
    
    /// 상세 시간 표시용: "11월 11일 오후 11:11"
    static let detailDateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 a h:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(abbreviation: "GMT")
//        formatter.timeZone = TimeZone.current  // 로컬 시간대
        formatter.amSymbol = "오전"
        formatter.pmSymbol = "오후"
        return formatter
    }()
}
