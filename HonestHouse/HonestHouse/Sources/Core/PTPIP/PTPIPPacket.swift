//
//  PTPIPPacket.swift
//  HonestHouse
//
//  PTP/IP (CIPA DC-005) 패킷 빌드/파싱과 캐논 데이터셋 파서.
//  캐논 Camera Connect 분석 결과 기준 (rea-cannon-camera-connect/docs/protocol.md)
//

import Foundation

enum PTPIPPacketType: UInt32 {
    case initCommandRequest = 1
    case initCommandAck = 2
    case initEventRequest = 3
    case initEventAck = 4
    case initFail = 5
    case operationRequest = 6
    case operationResponse = 7
    case event = 8
    case startData = 9
    case data = 10
    case cancel = 11
    case endData = 12
    case probeRequest = 13
    case probeResponse = 14
}

enum PTPCode {
    static let ok: UInt16 = 0x2001
    static let deviceBusy: UInt16 = 0x2019
    static let canonEVFNotReady: UInt16 = 0xA102

    static let getDeviceInfo: UInt16 = 0x1001
    static let openSession: UInt16 = 0x1002
    static let closeSession: UInt16 = 0x1003

    static let canonRemoteRelease: UInt16 = 0x910F
    static let canonSetDevicePropValueEx: UInt16 = 0x9110
    static let canonSetRemoteMode: UInt16 = 0x9114
    static let canonSetEventMode: UInt16 = 0x9115
    static let canonGetEvent: UInt16 = 0x9116
    static let canonRemoteReleaseOn: UInt16 = 0x9128
    static let canonRemoteReleaseOff: UInt16 = 0x9129
    static let canonGetViewFinderData: UInt16 = 0x9153
    static let canonKeepAlive: UInt16 = 0x902F

    static let propEVFOutputDevice: UInt32 = 0xD1B0

    static let remoteModeWiFi: UInt32 = 0x15
    static let remoteModeDefault: UInt32 = 0x11
    static let eventModePTPIP: UInt32 = 2
    static let sessionID: UInt32 = 0x41

    static let releaseHalfFull: UInt32 = 3

    static let eventObjectAdded: UInt32 = 0xC181
    static let eventObjectAdded64: UInt32 = 0xC1A7
    static let eventMore: UInt32 = 0xFFFF_FFFF
    static let evfJPEGRecordTypes: Set<UInt32> = [0x01, 0x0B, 0x17]
}

struct PTPResponse {
    let code: UInt16
    let transactionID: UInt32
    let params: [UInt32]
    var data: Data = Data()
}

struct PTPDeviceInfo {
    let operations: Set<UInt16>
    let manufacturer: String
    let model: String
    let version: String
    let serial: String
}

struct PTPObjectInfo: Equatable {
    let handle: UInt32
    let storageID: UInt32
    let format: UInt16
    let size: UInt64
    let filename: String
}

// MARK: - Little-endian helpers

extension Data {
    mutating func appendLE<T: FixedWidthInteger>(_ value: T) {
        Swift.withUnsafeBytes(of: value.littleEndian) { append(contentsOf: $0) }
    }

    func readLE<T: FixedWidthInteger>(_ type: T.Type, at offset: Int) -> T? {
        let size = MemoryLayout<T>.size
        guard offset >= 0, offset + size <= count else { return nil }
        var value: T = 0
        for i in 0..<size {
            value |= T(self[startIndex + offset + i]) << (8 * i)
        }
        return value
    }
}

// MARK: - Packet building

enum PTPIPPacket {
    static let headerSize = 8

    static func make(_ type: PTPIPPacketType, payload: Data = Data()) -> Data {
        var data = Data()
        data.appendLE(UInt32(headerSize + payload.count))
        data.appendLE(type.rawValue)
        data.append(payload)
        return data
    }

    /// UTF-16LE + NUL 종료 문자열 (PTP/IP 이름 인코딩). Camera Connect처럼 ASCII 밖의 문자는 '?'로 치환
    static func encodeName(_ name: String) -> Data {
        var data = Data()
        for scalar in name.unicodeScalars {
            data.appendLE(UInt16(scalar.value < 0x80 ? scalar.value : 0x3F))
        }
        data.appendLE(UInt16(0))
        return data
    }

    static func decodeName(_ data: Data) -> String {
        var units: [UInt16] = []
        var offset = 0
        while let unit = data.readLE(UInt16.self, at: offset), unit != 0 {
            units.append(unit)
            offset += 2
        }
        return String(decoding: units, as: UTF16.self)
    }

    static func initCommandRequest(guid: Data, name: String) -> Data {
        var payload = guid
        payload.append(encodeName(name))
        payload.appendLE(UInt32(0x0001_0000))
        return make(.initCommandRequest, payload: payload)
    }

    static func initEventRequest(connectionNumber: UInt32) -> Data {
        var payload = Data()
        payload.appendLE(connectionNumber)
        return make(.initEventRequest, payload: payload)
    }

    static func operationRequest(opcode: UInt16, transactionID: UInt32, params: [UInt32], hasDataOut: Bool) -> Data {
        var payload = Data()
        payload.appendLE(UInt32(hasDataOut ? 2 : 1))
        payload.appendLE(opcode)
        payload.appendLE(transactionID)
        params.forEach { payload.appendLE($0) }
        return make(.operationRequest, payload: payload)
    }

    static func dataOut(transactionID: UInt32, data: Data) -> Data {
        var start = Data()
        start.appendLE(transactionID)
        start.appendLE(UInt64(data.count))
        var end = Data()
        end.appendLE(transactionID)
        end.append(data)
        return make(.startData, payload: start) + make(.endData, payload: end)
    }

    static func parseResponse(_ payload: Data) -> PTPResponse? {
        guard let code = payload.readLE(UInt16.self, at: 0),
              let tid = payload.readLE(UInt32.self, at: 2) else { return nil }
        let params = stride(from: 6, to: payload.count - 3, by: 4).compactMap { payload.readLE(UInt32.self, at: $0) }
        return PTPResponse(code: code, transactionID: tid, params: params)
    }
}

// MARK: - Dataset parsing

enum PTPDataset {
    static func string(_ data: Data, at offset: inout Int) -> String {
        guard offset < data.count else { return "" }
        let length = Int(data[data.startIndex + offset])
        offset += 1
        guard length > 0 else { return "" }
        var units: [UInt16] = []
        for i in 0..<length {
            if let unit = data.readLE(UInt16.self, at: offset + i * 2), unit != 0 { units.append(unit) }
        }
        offset += length * 2
        return String(decoding: units, as: UTF16.self)
    }

    static func u16Array(_ data: Data, at offset: inout Int) -> [UInt16] {
        guard let count = data.readLE(UInt32.self, at: offset) else { return [] }
        offset += 4
        let values = (0..<Int(count)).compactMap { data.readLE(UInt16.self, at: offset + $0 * 2) }
        offset += Int(count) * 2
        return values
    }

    static func deviceInfo(_ data: Data) -> PTPDeviceInfo {
        var offset = 8
        _ = string(data, at: &offset)
        offset += 2
        let operations = u16Array(data, at: &offset)
        _ = u16Array(data, at: &offset)
        _ = u16Array(data, at: &offset)
        _ = u16Array(data, at: &offset)
        _ = u16Array(data, at: &offset)
        let manufacturer = string(data, at: &offset)
        let model = string(data, at: &offset)
        let version = string(data, at: &offset)
        let serial = string(data, at: &offset)
        return PTPDeviceInfo(operations: Set(operations), manufacturer: manufacturer, model: model, version: version, serial: serial)
    }

    /// GetEvent(0x9116) 응답을 레코드로 분리. 반환값의 more가 true면 다시 호출해야 함
    static func eventRecords(_ data: Data) -> (records: [(type: UInt32, body: Data)], more: Bool) {
        var records: [(UInt32, Data)] = []
        var offset = 0
        while let size = data.readLE(UInt32.self, at: offset), let type = data.readLE(UInt32.self, at: offset + 4) {
            if size < 8 || type == 0 || type == 0xFFFF_FFFE { return (records, false) }
            if type == PTPCode.eventMore { return (records, true) }
            let end = min(offset + Int(size), data.count)
            records.append((type, data.subdata(in: (data.startIndex + offset)..<(data.startIndex + end))))
            offset += Int(size)
        }
        return (records, false)
    }

    static func objectAdded(type: UInt32, record: Data) -> PTPObjectInfo? {
        guard let handle = record.readLE(UInt32.self, at: 8),
              let storage = record.readLE(UInt32.self, at: 12),
              let format = record.readLE(UInt16.self, at: 16) else { return nil }
        let size: UInt64?
        let nameOffset: Int
        switch type {
        case PTPCode.eventObjectAdded:
            size = record.readLE(UInt32.self, at: 0x1C).map(UInt64.init)
            nameOffset = 0x28
        case PTPCode.eventObjectAdded64:
            size = record.readLE(UInt64.self, at: 0x1C)
            nameOffset = 0x2C
        default:
            return nil
        }
        guard let size, nameOffset < record.count else { return nil }
        let nameBytes = record.subdata(in: (record.startIndex + nameOffset)..<record.endIndex).prefix { $0 != 0 }
        return PTPObjectInfo(handle: handle, storageID: storage, format: format, size: size,
                             filename: String(decoding: nameBytes, as: UTF8.self))
    }

    /// GetViewFinderData(0x9153) 응답에서 JPEG 레코드(타입 1/0x0B/0x17)의 offset 8부터 추출
    static func evfJPEG(_ data: Data) -> Data? {
        var offset = 0
        while let size = data.readLE(UInt32.self, at: offset), let type = data.readLE(UInt32.self, at: offset + 4), size >= 8 {
            if PTPCode.evfJPEGRecordTypes.contains(type) {
                let end = min(offset + Int(size), data.count)
                return data.subdata(in: (data.startIndex + offset + 8)..<(data.startIndex + end))
            }
            offset += Int(size)
        }
        return nil
    }
}
