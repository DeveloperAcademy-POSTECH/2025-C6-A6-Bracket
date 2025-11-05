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
}
