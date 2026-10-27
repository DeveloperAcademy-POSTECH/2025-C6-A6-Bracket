//
//  PTPIPConnection.swift
//  HonestHouse
//
//  PTP/IP 전송 계층: 명령/이벤트 TCP 연결 2개, 초기 핸드셰이크, 트랜잭션
//

import Foundation
import Network

enum PTPIPError: LocalizedError, Equatable {
    case connectionFailed(String)
    case closed
    case timeout
    case rejected(UInt32)
    case unexpectedPacket(UInt32)
    case response(opcode: UInt16, code: UInt16)

    var errorDescription: String? {
        switch self {
        case .connectionFailed(let reason): return "PTP/IP connection failed: \(reason)"
        case .closed: return "PTP/IP connection closed by camera"
        case .timeout: return "PTP/IP timeout"
        case .rejected(let reason): return String(format: "Camera rejected PTP/IP connection (InitFail 0x%X). Confirm pairing on the camera.", reason)
        case .unexpectedPacket(let type): return "Unexpected PTP/IP packet type \(type)"
        case .response(let opcode, let code): return String(format: "PTP operation 0x%04X failed with 0x%04X", opcode, code)
        }
    }
}

/// open() 상태 플래그. channel의 직렬 큐에서만 접근
private final class OpenState: @unchecked Sendable {
    var resumed = false
    var timedOut = false
}

private final class TCPChannel: @unchecked Sendable {
    private let connection: NWConnection
    private let queue: DispatchQueue

    init(host: String, port: UInt16, label: String) {
        let tcp = NWProtocolTCP.Options()
        tcp.noDelay = true
        tcp.connectionTimeout = 10
        connection = NWConnection(host: NWEndpoint.Host(host), port: NWEndpoint.Port(rawValue: port)!,
                                  using: NWParameters(tls: nil, tcp: tcp))
        queue = DispatchQueue(label: "ptpip.\(label)")
    }

    /// 로컬 네트워크 권한 팝업 동안 .waiting에 머물 수 있어, 실패 대신 timeout으로 처리
    func open(timeout: TimeInterval = 10) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let state = OpenState()
            connection.stateUpdateHandler = { newState in
                guard !state.resumed else { return }
                switch newState {
                case .ready:
                    state.resumed = true
                    continuation.resume()
                case .failed(let error):
                    state.resumed = true
                    continuation.resume(throwing: PTPIPError.connectionFailed(error.localizedDescription))
                case .cancelled:
                    state.resumed = true
                    continuation.resume(throwing: state.timedOut ? PTPIPError.timeout : PTPIPError.closed)
                default:
                    break
                }
            }
            connection.start(queue: queue)
            queue.asyncAfter(deadline: .now() + timeout) { [connection] in
                guard !state.resumed else { return }
                state.timedOut = true
                connection.cancel()
            }
        }
    }

    func send(_ data: Data) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            connection.send(content: data, completion: .contentProcessed { error in
                if let error {
                    continuation.resume(throwing: PTPIPError.connectionFailed(error.localizedDescription))
                } else {
                    continuation.resume()
                }
            })
        }
    }

    func receive(exactly length: Int) async throws -> Data {
        guard length > 0 else { return Data() }
        return try await withCheckedThrowingContinuation { continuation in
            connection.receive(minimumIncompleteLength: length, maximumLength: length) { data, _, isComplete, error in
                if let error {
                    continuation.resume(throwing: PTPIPError.connectionFailed(error.localizedDescription))
                } else if let data, data.count == length {
                    continuation.resume(returning: data)
                } else if isComplete {
                    continuation.resume(throwing: PTPIPError.closed)
                } else {
                    continuation.resume(throwing: PTPIPError.closed)
                }
            }
        }
    }

    func receivePacket() async throws -> (type: UInt32, payload: Data) {
        let header = try await receive(exactly: PTPIPPacket.headerSize)
        guard let length = header.readLE(UInt32.self, at: 0), let type = header.readLE(UInt32.self, at: 4),
              length >= UInt32(PTPIPPacket.headerSize) else {
            throw PTPIPError.unexpectedPacket(0)
        }
        let payload = try await receive(exactly: Int(length) - PTPIPPacket.headerSize)
        return (type, payload)
    }

    func close() {
        connection.cancel()
    }
}

actor PTPIPConnection {
    static let defaultPort: UInt16 = 15740

    let host: String
    let port: UInt16
    private let guid: Data
    private let name: String
    private var command: TCPChannel?
    private var event: TCPChannel?
    private var transactionID: UInt32 = 0
    private var isBusy = false
    private var waiters: [CheckedContinuation<Void, Never>] = []

    private(set) var cameraName = ""

    init(host: String, port: UInt16 = PTPIPConnection.defaultPort, guid: Data, name: String) {
        self.host = host
        self.port = port
        self.guid = guid
        self.name = name
    }

    func connect() async throws {
        let command = TCPChannel(host: host, port: port, label: "command")
        try await command.open()
        try await command.send(PTPIPPacket.initCommandRequest(guid: guid, name: name))
        let (type, payload) = try await command.receivePacket()
        if type == PTPIPPacketType.initFail.rawValue {
            command.close()
            throw PTPIPError.rejected(payload.readLE(UInt32.self, at: 0) ?? 0)
        }
        guard type == PTPIPPacketType.initCommandAck.rawValue,
              let connectionNumber = payload.readLE(UInt32.self, at: 0) else {
            command.close()
            throw PTPIPError.unexpectedPacket(type)
        }
        cameraName = PTPIPPacket.decodeName(payload.count > 20 ? payload.subdata(in: (payload.startIndex + 20)..<payload.endIndex) : Data())

        let event = TCPChannel(host: host, port: port, label: "event")
        try await event.open()
        try await event.send(PTPIPPacket.initEventRequest(connectionNumber: connectionNumber))
        let (eventType, _) = try await event.receivePacket()
        guard eventType == PTPIPPacketType.initEventAck.rawValue else {
            command.close()
            event.close()
            throw PTPIPError.unexpectedPacket(eventType)
        }
        self.command = command
        self.event = event
    }

    /// 이벤트 채널에서 패킷 하나를 읽음. Probe 요청에는 응답하고 이벤트 코드만 돌려줌
    func readEvent() async throws -> UInt16? {
        guard let event else { throw PTPIPError.closed }
        let (type, payload) = try await event.receivePacket()
        if type == PTPIPPacketType.probeRequest.rawValue {
            try await event.send(PTPIPPacket.make(.probeResponse))
            return nil
        }
        guard type == PTPIPPacketType.event.rawValue else { return nil }
        return payload.readLE(UInt16.self, at: 0)
    }

    func close() {
        command?.close()
        event?.close()
        command = nil
        event = nil
    }

    /// actor는 await 지점에서 재진입하므로, 명령 채널의 요청/응답이 섞이지 않게 트랜잭션을 직렬화
    private func acquire() async {
        if !isBusy {
            isBusy = true
            return
        }
        await withCheckedContinuation { waiters.append($0) }
    }

    private func release() {
        if waiters.isEmpty {
            isBusy = false
        } else {
            waiters.removeFirst().resume()
        }
    }

    /// PTP 명령 하나를 실행. 응답 코드가 OK가 아니면 check가 true일 때 throw
    @discardableResult
    func transaction(_ opcode: UInt16, _ params: [UInt32] = [], dataOut: Data? = nil,
                     check: Bool = true, transactionID overrideID: UInt32? = nil) async throws -> PTPResponse {
        await acquire()
        defer { release() }
        guard let command else { throw PTPIPError.closed }
        let tid: UInt32
        if let overrideID {
            tid = overrideID
        } else {
            transactionID = transactionID &+ 1
            if transactionID == 0 { transactionID = 1 }
            tid = transactionID
        }

        try await command.send(PTPIPPacket.operationRequest(opcode: opcode, transactionID: tid, params: params, hasDataOut: dataOut != nil))
        if let dataOut {
            try await command.send(PTPIPPacket.dataOut(transactionID: tid, data: dataOut))
        }

        var data = Data()
        while true {
            let (type, payload) = try await command.receivePacket()
            switch PTPIPPacketType(rawValue: type) {
            case .startData:
                continue
            case .data, .endData:
                if payload.count > 4 { data.append(payload.subdata(in: (payload.startIndex + 4)..<payload.endIndex)) }
            case .probeRequest:
                try await command.send(PTPIPPacket.make(.probeResponse))
            case .operationResponse:
                guard var response = PTPIPPacket.parseResponse(payload) else { throw PTPIPError.unexpectedPacket(type) }
                response.data = data
                if check && response.code != PTPCode.ok {
                    throw PTPIPError.response(opcode: opcode, code: response.code)
                }
                return response
            default:
                throw PTPIPError.unexpectedPacket(type)
            }
        }
    }
}
