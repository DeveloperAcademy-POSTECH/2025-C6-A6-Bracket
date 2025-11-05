//
//  Logger+Extension.swift
//  HonestHouse
//
//  Created by Rama on 11/5/25.
//

import Foundation
import OSLog

extension Logger {
    static func debug(_ message: String, category: LogCategory = .general, file: String = #file, line: Int = #line, function: String = #function) {
        log(.debug, category: category, message: message, file: file, line: line, function: function)
    }
    
    static func info(_ message: String, category: LogCategory = .general, file: String = #file, line: Int = #line, function: String = #function) {
        log(.info, category: category, message: message, file: file, line: line, function: function)
    }
    
    static func warning(_ message: String, category: LogCategory = .general, file: String = #file, line: Int = #line, function: String = #function) {
        log(.warning, category: category, message: message, file: file, line: line, function: function)
    }
    
    static func error(_ message: String, category: LogCategory = .general, includeStackTrace: Bool = true, file: String = #file, line: Int = #line, function: String = #function) {
        log(.error, category: category, message: message, includeStackTrace: includeStackTrace, file: file, line: line, function: function)
    }
    
    static func fatal(_ message: String, category: LogCategory = .general, file: String = #file, line: Int = #line, function: String = #function) {
        log(.fatal, category: category, message: message, includeStackTrace: true, file: file, line: line, function: function)
    }
}
