//
//  CameraConstants.swift
//  HonestHouse
//
//  Created by Subeen on 11/5/25.
//

import Foundation

struct CameraConstants {
    static let isoValues: [String] = ["auto", "100", "125", "160", "200", "250", "320", "400", "500", "640", "800", "1000", "1250", "1600", "2000", "2500", "3200", "4000", "5000", "6400", "8000", "10000", "12800", "16000", "20000", "25600", "32000"]
    
    static let apertureValues: [String] = ["f4.5", "f5.0", "f5.6", "f6.3", "f7.1", "f8.0", "f9.0", "f10", "f11", "f13", "f14", "f16", "f18", "f20", "f22", "f25"]
    
    static let shutterSpeedValues: [String] = [/*"15\"", "13\"", "10\"", "8\"", "6\"", "5\"", "4\"", "3\"2", "2\"5", "2\"", "1\"6", "1\"3", "1\"", "0\"8", "0\"6", */"0\"5", "0\"4", "0\"3", "1/4", "1/5", "1/6", "1/8", "1/10", "1/13", "1/15", "1/20", "1/25", "1/30", "1/40", "1/50", "1/60", "1/80", "1/100", "1/125", "1/160", "1/200", "1/250", "1/320", "1/400", "1/500", "1/640", "1/800", "1/1000", "1/1250", "1/1600", "1/2000"]
    
    static let pictureStyleValues: [String] = ["auto", "standard", "portrait", "landscape", "finedetail", "neutral", "faithful", "monochrome"]
    
    static let tintMagentaGreenValues: [Int] = [-9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    static let exposureCompensationValues: [String] = ["-3.0", "-2_2/3", "-2_1/3", "-2.0", "-1_2/3", "-1_1/3", "-1.0", "-0_2/3", "-0_1/3", "+0.0", "+0_1/3", "+0_2/3", "+1.0", "+1_1/3", "+1_2/3", "+2.0", "+2_1/3", "+2_2/3", "+3.0"]
    static let colorTemperatureValues: [Int] = [2500, 2600, 2700, 2800, 2900, 3000, 3100, 3200, 3300, 3400, 3500, 3600, 3700, 3800, 3900, 4000, 4100, 4200, 4300, 4400, 4500, 4600, 4700, 4800, 4900, 5000, 5100, 5200, 5300, 5400, 5500, 5600, 5700, 5800, 5900, 6000, 6100, 6200, 6300, 6400, 6500, 6600, 6700, 6800, 6900, 7000, 7100, 7200, 7300, 7400, 7500, 7600, 7700, 7800, 7900, 8000, 8100, 8200, 8300, 8400, 8500, 8600, 8700, 8800, 8900, 9000, 9100, 9200, 9300, 9400, 9500, 9600, 9700, 9800, 9900, 10000]
    
    static let exposureCompensationRange: ClosedRange<Int> = -9...9     // min ~ max
    static let exposureCompensationStep: Int = 1                     // step
    
    static let colorTemperatureRange: ClosedRange<Int> = 2500...10000   // min ~ max
    static let colorTemperatureStep: Int = 100                          // step
}
