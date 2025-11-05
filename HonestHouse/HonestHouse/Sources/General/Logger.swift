//
//  Logger.swift
//  HonestHouse
//
//  Created by Rama on 11/5/25.
//

import Foundation
import OSLog

enum LogLevel {
    case debug
    case info
    case warning
    case error
    case fatal
    
    var osLogType: OSLogType {
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .warning: return .default
        case .error: return .error
        case .fatal: return .fault
        }
    }
}

enum LogCategory: String {
    case network = "Network"
    case imageCache = "ImageCache"
    case prefetch = "Prefetch"
    case connection = "Connection"
    case ui = "UI"
    case viewModel = "ViewModel"
    case general = "General"
    
    var osLog: OSLog {
        OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.app.honestHouse", category: self.rawValue)
    }
}

struct Logger {
    static func log(
        _ level: LogLevel,
        category: LogCategory = .general,
        message: String,
        includeStackTrace: Bool = false,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) {
        let fileName = (file as NSString).lastPathComponent
        let timestamp = DateFormatter.logTimestamp()
        
        var logMessage = "[\(timestamp)] \(message) [\(fileName):\(line) \(function)]"
        
        // 에러/fatal은 자동으로 스택 트레이스 포함
        let shouldIncludeStackTrace = includeStackTrace || level == .error || level == .fatal
        if shouldIncludeStackTrace {
            logMessage += "\n" + Thread.callStackSymbols.joined(separator: "\n")
        }
        
        os_log("%{public}@", log: category.osLog, type: level.osLogType, logMessage)
    }
}



