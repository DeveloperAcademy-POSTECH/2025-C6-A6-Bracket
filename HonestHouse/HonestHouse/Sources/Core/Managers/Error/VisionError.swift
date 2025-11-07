//
//  VisionError.swift
//  HonestHouse
//
//  Created by Rama on 10/26/25.
//

import Foundation

enum VisionError: LocalizedError {
    case cgImageConversion(url: String)
    case observation(url: String)
    case imageFetching(url: String, underlyingError: Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .cgImageConversion(url: let url):
            return "Error: Failed to convert CGImage for \(url)"
        case .observation(url: let url):
            return "Error: Failed to perform vision observation for \(url)"
        case .imageFetching(url: let url, underlyingError: let underlyingError):
            return "Error: Failed to fetch image from \(url). Underlying error: \(underlyingError)"
        case .unknown:
            return "Error: Unknown error"
        }
    }
}
