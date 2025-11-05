//
//  ParsedFrame.swift
//  HonestHouse
//
//  Created by Rama on 10/28/25.
//

import UIKit

struct ParsedFrame {
    let type: DataType
    let data: Data
    let timestamp: Date
    
    var image: UIImage? {
        guard type == .image else { return nil }
        return UIImage(data: data)
    }
    
    var info: LiveViewInfo? {
        guard type == .info else { return nil }
        return try? JSONDecoder().decode(LiveViewInfo.self, from: data)
    }
}
