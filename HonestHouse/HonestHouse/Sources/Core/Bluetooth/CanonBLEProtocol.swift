//
//  CanonBLEProtocol.swift
//  HonestHouse
//
//  캐논 카메라 BLE 프로토콜 상수와 파서.
//  Canon Camera Connect 분석 결과 기준 (rea-cannon-camera-connect/docs/protocol.md)
//

import CoreBluetooth
import Foundation

enum CanonBLE {
    static func uuid(_ short: UInt32) -> CBUUID {
        CBUUID(string: String(format: "%08X-0000-1000-0000-D8492FFFA821", short))
    }

    static let companyID: UInt16 = 0x01A9

    static let sessionService = uuid(0x0001_0000)
    static let pairing = uuid(0x0001_0006)
    static let command = uuid(0x0001_000A)
    static let capability = uuid(0x0001_000B)

    static let wifiService = uuid(0x0002_0000)
    static let wifiCommand = uuid(0x0002_0002)
    static let wifiStatus = uuid(0x0002_0003)
    static let wifiSSID = uuid(0x0002_0004)
    static let wifiPassword = uuid(0x0002_0006)

    static let remoteService = uuid(0x0003_0000)
    static let remoteMode = uuid(0x0003_0010)
    static let shoot = uuid(0x0003_0030)

    enum Command {
        static let success: UInt8 = 0x01
        static let appUUID: UInt8 = 0x03
        static let nickname: UInt8 = 0x04
        static let deviceType: UInt8 = 0x05
        static let deviceTypeSmartphone: UInt8 = 0x02
    }

    enum PairingReply {
        static let request: UInt8 = 0x01
        static let accepted: UInt8 = 0x02
    }

    enum WiFiCommand {
        static let start = Data([0x01])
        static let stop = Data([0x02])
        static let responseMarker: UInt8 = 0x10
        static let tlvIPAddress: UInt8 = 0x10
        static let tlvBSSID: UInt8 = 0x02
    }

    enum Remote {
        static let modeRec = Data([0x02])
        static let afReleaseOn = Data([0x00, 0x01])
        static let afReleaseOff = Data([0x00, 0x02])
    }
}

struct CanonAdvertisement: Equatable {
    let productID: UInt16
    let rememberedUUID: Data?

    /// 카메라가 기억하는 기기 UUID가 없거나 0이면 아직 페어링되지 않은 상태
    var isPairingMode: Bool {
        guard let rememberedUUID else { return true }
        return rememberedUUID.allSatisfy { $0 == 0 }
    }

    /// CoreBluetooth의 manufacturer data는 앞 2바이트가 company ID
    init?(manufacturerData: Data) {
        guard manufacturerData.count >= 5,
              manufacturerData.readLE(UInt16.self, at: 0) == CanonBLE.companyID,
              manufacturerData[manufacturerData.startIndex + 2] == 0x01,
              let productID = manufacturerData.readLE(UInt16.self, at: 3) else { return nil }
        self.productID = productID
        let body = manufacturerData.dropFirst(2)
        if body.count >= 19 {
            rememberedUUID = Data(body.dropFirst(3).prefix(16).reversed())
        } else if body.count >= 5 {
            rememberedUUID = Data(body.dropFirst(3).prefix(2).reversed())
        } else {
            rememberedUUID = nil
        }
    }
}

struct CameraWiFiInfo: Equatable {
    var ssid: String?
    var password: String?
    var ipAddress: String?
    var bssid: String?
}

enum CanonBLEParser {
    /// 00020002 notify의 'WAP CP Response' (0x10, ?, [type, length, value]...)
    static func wifiResponse(_ data: Data) -> [UInt8: Data] {
        guard let first = data.first, first == CanonBLE.WiFiCommand.responseMarker else { return [:] }
        var result: [UInt8: Data] = [:]
        var index = data.startIndex + 2
        while index + 2 <= data.endIndex {
            let type = data[index]
            let length = Int(data[index + 1])
            let valueEnd = min(index + 2 + length, data.endIndex)
            result[type] = data.subdata(in: (index + 2)..<valueEnd)
            index += 2 + length
        }
        return result
    }

    static func apply(_ tlv: [UInt8: Data], to info: inout CameraWiFiInfo) {
        if let ip = tlv[CanonBLE.WiFiCommand.tlvIPAddress], ip.count == 4 {
            info.ipAddress = ip.map(String.init).joined(separator: ".")
        }
        if let bssid = tlv[CanonBLE.WiFiCommand.tlvBSSID], bssid.count == 6 {
            info.bssid = bssid.map { String(format: "%02x", $0) }.joined(separator: ":")
        }
    }

    static func string(_ data: Data) -> String {
        String(decoding: data.prefix { $0 != 0 }, as: UTF8.self)
    }

    static func pairingRequest(nickname: String) -> Data {
        Data([CanonBLE.PairingReply.request]) + ascii(nickname)
    }

    /// Camera Connect와 같이 UUID를 바이트 역순(LE)으로 등록
    static func registrationCommands(appUUID: UUID, nickname: String) -> [Data] {
        [
            Data([CanonBLE.Command.appUUID]) + Data(appUUID.bytes.reversed()),
            Data([CanonBLE.Command.nickname]) + ascii(nickname),
            Data([CanonBLE.Command.deviceType, CanonBLE.Command.deviceTypeSmartphone])
        ]
    }

    static func ascii(_ text: String) -> Data {
        Data(text.unicodeScalars.map { $0.isASCII ? UInt8($0.value) : 0x3F })
    }
}

extension UUID {
    /// 빅엔디안 16바이트 (PTP/IP GUID 형식)
    var bytes: Data {
        withUnsafeBytes(of: uuid) { Data($0) }
    }
}

/// BLE 등록과 PTP/IP GUID에 함께 쓰는 앱 고유 UUID
enum CameraIdentity {
    private static let appUUIDKey = "canonAppUUID"
    private static let peripheralKey = "canonLastPeripheralID"
    static let nickname = "Bracket"

    static var appUUID: UUID {
        if let stored = UserDefaults.standard.string(forKey: appUUIDKey), let uuid = UUID(uuidString: stored) {
            return uuid
        }
        let uuid = UUID()
        UserDefaults.standard.set(uuid.uuidString, forKey: appUUIDKey)
        return uuid
    }

    static var lastPeripheralID: UUID? {
        get { UserDefaults.standard.string(forKey: peripheralKey).flatMap(UUID.init(uuidString:)) }
        set { UserDefaults.standard.set(newValue?.uuidString, forKey: peripheralKey) }
    }
}
