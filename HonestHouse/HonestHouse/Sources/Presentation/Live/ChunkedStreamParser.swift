//
//  ChunkedStreamParser.swift
//  HonestHouse
//
//  Created by Subeen on 10/27/25.
//

import UIKit

actor ChunkedStreamParser {
    private var buffer = Data()
    private let streamType: ScrollType

    init(streamType: ScrollType) {
        self.streamType = streamType
    }

    func appendChunk(_ chunk: Data) {
        buffer.append(chunk)
    }

    func extractFrames() -> [ParsedFrame] {
        var frames: [ParsedFrame] = []

        while let frame = parseNextFrame(type: .scroll) {
            frames.append(frame)
        }

        if frames.isEmpty && buffer.count > 0 {
            Logger.debug("Waiting for more data (buffer: \(buffer.count) bytes)", category: .network)
        }

        return frames
    }

    /// 버퍼 리셋
    func reset() {
        buffer.removeAll()
    }

    private func parseNextFrame(type: ScrollType) -> ParsedFrame? {
        switch type {
        case .scroll:
            return parseScrollFrame()
        case .scrollDetail:
            return parseScrollDetailFrame()
        }
    }

    private func parseScrollFrame() -> ParsedFrame? {
        let localBuffer = Data(self.buffer)
        
        guard let soiRange = localBuffer.range(of: Data([0xFF, 0xD8])) else {
            return nil
        }
        
        let searchEoiStartIndex = soiRange.upperBound
        guard let eoiRange = localBuffer.range(of: Data([0xFF, 0xD9]), in: searchEoiStartIndex..<localBuffer.count) else {
            return nil
        }
        
        let jpegData = localBuffer.subdata(in: soiRange.lowerBound..<eoiRange.upperBound)
        
        let frame = ParsedFrame(
            type: .image,
            data: jpegData,
            timestamp: Date()
        )
        
        let bytesToRemove = eoiRange.upperBound
        self.buffer.removeFirst(bytesToRemove)
        
        return frame
    }

    private func parseScrollDetailFrame() -> ParsedFrame? {
        return nil
    }
}
