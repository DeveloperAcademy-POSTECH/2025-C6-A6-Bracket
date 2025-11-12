//
//  EventMonitorParser.swift
//  HonestHouse
//
//  Created by BoMin Lee on 11/11/25.
//

import Foundation

actor EventMonitorParser {
    private var buffer = Data()

    func appendChunk(_ chunk: Data) {
        buffer.append(chunk)
    }

    func extractEvents() -> [CameraStatus.EventMonitorResponse] {
        var events: [CameraStatus.EventMonitorResponse] = []

        while let event = parseNextEvent() {
            events.append(event)
        }

        if events.isEmpty && buffer.count > 0 {
            Logger.debug("Waiting for more data (buffer: \(buffer.count) bytes)", category: .eventMonitor)
        }

        return events
    }

    func reset() {
        buffer.removeAll()
    }

    private func parseNextEvent() -> CameraStatus.EventMonitorResponse? {
        // localBuffer로 복사해서 안전하게 읽기
        let localBuffer = Data(self.buffer)

        Logger.debug("parseNextEvent: buffer size = \(localBuffer.count) bytes", category: .eventMonitor)

        // 최소 헤더 크기 확인
        guard localBuffer.count >= 9 else {
            Logger.debug("Buffer too small (< 9 bytes), waiting for more data", category: .eventMonitor)
            return nil
        }

        // Start Byte 검증 (0xFF 0x00)
        Logger.debug("Checking Start Byte: [0]=0x\(String(format: "%02X", localBuffer[0])) [1]=0x\(String(format: "%02X", localBuffer[1]))", category: .eventMonitor)
        guard localBuffer[0] == 0xFF && localBuffer[1] == 0x00 else {
            Logger.warning("Invalid Start Byte", category: .eventMonitor)
            // 0xFF를 찾아서 그 위치부터 재시도
            if let startIndex = localBuffer.firstIndex(where: { $0 == 0xFF }) {
                Logger.debug("Found 0xFF at index \(startIndex), skipping \(startIndex) bytes", category: .eventMonitor)
                self.buffer.removeFirst(startIndex)
            } else {
                Logger.debug("No 0xFF found, clearing entire buffer", category: .eventMonitor)
                self.buffer.removeAll()
            }
            return nil
        }
        Logger.debug("Start Byte OK", category: .eventMonitor)

        // Data Type 검증 (0x02 = Event Data)
        Logger.debug("Checking Data Type: [2]=0x\(String(format: "%02X", localBuffer[2]))", category: .eventMonitor)
        guard localBuffer[2] == 0x02 else {
            Logger.warning("Invalid Data Type (expected 0x02)", category: .eventMonitor)
            self.buffer.removeFirst(3)
            return nil
        }
        Logger.debug("Data Type OK (Event Data)", category: .eventMonitor)

        // Data Size 읽기 (Big-endian 4 bytes)
        let dataSize = UInt32(localBuffer[3]) << 24 |
                      UInt32(localBuffer[4]) << 16 |
                      UInt32(localBuffer[5]) << 8 |
                      UInt32(localBuffer[6])

        Logger.debug("Data Size = \(dataSize) bytes", category: .eventMonitor)

        // 전체 프레임 크기 계산
        let totalSize = 7 + Int(dataSize) + 2
        Logger.debug("Total frame size = \(totalSize) bytes (header:7 + data:\(dataSize) + end:2)", category: .eventMonitor)

        // 전체 데이터가 버퍼에 있는지 확인
        guard localBuffer.count >= totalSize else {
            Logger.debug("Buffer too small (need \(totalSize), have \(localBuffer.count)), waiting for more data", category: .eventMonitor)
            return nil
        }

        // End Byte 검증 (0xFF 0xFF)
        let endByteIndex = 7 + Int(dataSize)

        Logger.debug("Checking End Byte at index \(endByteIndex): [0x\(String(format: "%02X", localBuffer[endByteIndex]))] [0x\(String(format: "%02X", localBuffer[endByteIndex + 1]))]", category: .eventMonitor)

        // 명시적 범위 체크
        guard endByteIndex + 1 < localBuffer.count,
              localBuffer[endByteIndex] == 0xFF && localBuffer[endByteIndex + 1] == 0xFF else {
            Logger.warning("Invalid End Byte (expected 0xFF 0xFF)", category: .eventMonitor)
            self.buffer.removeFirst(7)
            return nil
        }
        Logger.debug("End Byte OK", category: .eventMonitor)

        // JSON 데이터 추출
        let jsonData = localBuffer.subdata(in: 7..<(7 + Int(dataSize)))
        Logger.debug("Extracting event data: \(jsonData.count) bytes", category: .eventMonitor)

        // 처리한 데이터 제거 (self.buffer만 수정)
        self.buffer.removeFirst(totalSize)
        Logger.debug("Removed \(totalSize) bytes from buffer, remaining: \(self.buffer.count) bytes", category: .eventMonitor)

        // JSON 디코딩
        do {
            let decoder = JSONDecoder()
            let event = try decoder.decode(CameraStatus.EventMonitorResponse.self, from: jsonData)
            Logger.debug("Event decoded successfully", category: .eventMonitor)
            return event
        } catch {
            Logger.error("EventMonitor JSON decode error: \(error)", category: .eventMonitor)
            return nil
        }
    }
}
