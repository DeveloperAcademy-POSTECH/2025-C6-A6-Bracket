//
//  ImageLoadingError.swift
//  HonestHouse
//
//  Created by Rama on 10/24/25.
//

import Foundation

enum ImageLoadingError: LocalizedError {
    case invalidURL
    case networkError(statusCode: Int)
    case invalidImageData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(statusCode: let statusCode):
            return "Network error with status code: \(statusCode)"
        case .invalidImageData:
            return "Invalid image data"
        }
    }
}
