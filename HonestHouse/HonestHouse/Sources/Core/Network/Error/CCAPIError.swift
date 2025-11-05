//
//  CCAPIError.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

import Foundation

enum CCAPIError: Error {
    case invalidURL
    case invalidResponse
    case noWWWAuthenticateHeader
    case authHeaderGenerationFailed
    case authenticationFailed(Int)
    case unexpectedStatusCode(Int)
    case notAuthenticated
    case maxRetriesExceeded
    case decodingFailed(String)
    case deviceUnavailable(String)
    case urlNotFound
    case badRequest(String)
    case httpError(Int)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid HTTP response"
        case .noWWWAuthenticateHeader:
            return "No WWW-Authenticate header found"
        case .authHeaderGenerationFailed:
            return "Failed to generate auth header"
        case .authenticationFailed(let code):
            return "Authentication failed with status code: \(code)"
        case .unexpectedStatusCode(let code):
            return "Unexpected status code: \(code)"
        case .notAuthenticated:
            return "Not authenticated. Call authenticate() first"
        case .maxRetriesExceeded:
            return "Maximum authentication retries exceeded"
        case .decodingFailed(let message):
            return "JSON decoding failed: \(message)"
        case .deviceUnavailable(let message):
            return "Device unavailable: \(message)"
        case .urlNotFound:
            return "URL not found"
        case .badRequest(let message):
            return "Bad request: \(message)"
        case .httpError(let code):
            return "HTTP error: \(code)"
        }
    }
}
