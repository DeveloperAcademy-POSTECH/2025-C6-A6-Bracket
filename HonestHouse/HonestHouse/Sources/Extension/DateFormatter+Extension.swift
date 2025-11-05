//
//  DateFormatter.swift
//  HonestHouse
//
//  Created by Rama on 11/5/25.
//

import Foundation

extension DateFormatter {
    static let logFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
}
