//
//  PresetErrorHandleable.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/28/25.
//

import Foundation

protocol PresetErrorHandleable: AnyObject {
    var error: PresetError? { get set }
    func handleError(_ error: Error)
}

extension PresetErrorHandleable {
    func handleError(_ error: Error) {
        if let presetServiceError = error as? PresetManagerError {
            self.error = PresetError.from(presetServiceError: presetServiceError)
        } else if let ccapiError = error as? CCAPIError {
            self.error = PresetError.from(ccapiError: ccapiError)
        } else if let presetError = error as? PresetError {
            self.error = presetError
        } else {
            self.error = .unknown
        }
    }
}
