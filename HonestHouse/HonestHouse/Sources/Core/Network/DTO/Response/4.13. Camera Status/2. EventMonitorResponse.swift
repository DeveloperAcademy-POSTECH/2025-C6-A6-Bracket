//
//  EventMonitorResponse.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/29/25.
//

import Foundation

extension CameraStatus {
    /// 4.13.2 Event Monitor
    struct EventMonitorResponse: BaseResponse {
        // MARK: 당장 사용되는 added contents만 추가해두었습니다.
        let addedcontents: [String]?
    }
}

extension CameraStatus.EventMonitorResponse {
    typealias EntityType = EventMonitor

    func toEntity() -> EventMonitor {
        EventMonitor(
           addedContents: addedcontents
        )
    }

    static var stub1: CameraStatus.EventMonitorResponse {
        .init(
            addedcontents: ["test.jpeg"]
        )
    }
}

