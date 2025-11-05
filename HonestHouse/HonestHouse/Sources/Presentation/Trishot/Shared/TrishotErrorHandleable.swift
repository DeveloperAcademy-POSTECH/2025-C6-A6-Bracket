//
//  TrishotErrorHandleable.swift
//  HonestHouse
//
//  Created by BoMin Lee on 11/4/25.
//

import Foundation

protocol TrishotErrorHandleable: AnyObject {
    var error: TrishotError? { get set }
    func handleError(_ error: Error)
}

extension TrishotErrorHandleable {
    func handleError(_ error: Error) {
        if let trishotError = error as? TrishotError {
            self.error = trishotError
        } else if let presetManagerError = error as? PresetManagerError {
            self.error = .presetLoadFailed
        } else if let ccapiError = error as? CCAPIError {
            self.error = TrishotError.from(ccapiError: ccapiError)
        } else {
            self.error = .unknown(error)
        }
    }
}
