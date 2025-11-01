//
//  ErrorHandleable.swift
//  HonestHouse
//
//  Created by 이현주 on 10/27/25.
//

import Foundation

@MainActor
protocol ArchiveErrorHandleable: AnyObject {
    associatedtype Success: Equatable
    associatedtype Failure: Error & Equatable

    var state: ArchiveState<Success, Failure> { get set }
    func handleError(_ error: Error)
}

extension ArchiveErrorHandleable {
    func handleError(_ error: Error) {
        // 기본 동작: Failure 타입의 `init(error:)`를 강제 구현하지 않아도 되게끔
        if let mappedError = error as? Failure {
            state = .failure(mappedError)
        } else {
            print("Unmapped error:", error.localizedDescription)
        }
    }
}
