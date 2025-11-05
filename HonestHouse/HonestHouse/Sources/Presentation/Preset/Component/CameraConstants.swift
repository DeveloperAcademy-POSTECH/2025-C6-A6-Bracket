//
//  CameraConstants.swift
//  HonestHouse
//
//  Created by Subeen on 11/5/25.
//

import Foundation

struct CameraConstants {
    static let isoValues: [Int] = [100, 200, 400, 640, 800, 1000, 1600, 2000, 2500, 3200, 4000, 5000, 6400, 8000, 10000, 12800, 16000]
    
    static let apertureValues: [Double] = [1.2, 1.4, 1.6, 1.8, 2.0, 2.8, 4.0, 5.6, 8.0, 11.0, 16.0]
    
    static let shutterSpeedValues: [Double] = [
        1/8000, 1/6400, 1/5000, 1/4000, 1/3200, 1/2500, 1/2000, 1/1600,
        1/1250, 1/1000, 1/800, 1/640, 1/500, 1/400, 1/320, 1/250,
        1/200, 1/160, 1/125, 1/100, 1/80, 1/60, 1/50, 1/40,
        1/30, 1/25, 1/20, 1/15, 1/13, 1/10, 1/8, 1/6,
        1/5, 1/4, 0.3, 0.4, 0.5, 0.6, 0.8, 1, 1.3, 1.6, 2, 2.5, 3.2, 4, 5, 6, 8, 10, 13, 15, 20, 25, 30
    ]
    
    static let filterValues: [String] = ["Normal", "High Contrast", "Noise Reduction", "High Dynamic Range", "Black and White"]
    
    static let tintValues: [Int] = [-8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8]
    
    static let exposureCompensationRange: ClosedRange<Double> = -3.0...3.0
    static let exposureCompensationStep: Double = 0.3
    
    static let colorTemperatureRange: ClosedRange<Int> = 2000...10000
    static let colorTemperatureStep: Int = 100
}
