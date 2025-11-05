//
//  PresetError.swift
//  HonestHouse
//
//  Created by Rama on 11/5/25.
//

import Foundation

// TODO: PresetError이 ViewModel 정의 Error와 중복, 수정 필요
enum PresetManagerError: LocalizedError {
    case presetNotFound(UUID)
    case saveFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .presetNotFound(let id):
            return "Preset not found: \(id.uuidString)"
        case .saveFailed(let error):
            return "Failed to save context: \(error.localizedDescription)"
        }
    }
}
