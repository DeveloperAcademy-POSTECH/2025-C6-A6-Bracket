//
//  FontStyle.swift
//  HonestHouse
//
//  Created by 이현주 on 11/13/25.
//

import SwiftUI

struct FontStyle {
    let font: Font
    let fontName: String
    let size: CGFloat
    let lineHeight: CGFloat
    
    private var uiFont: UIFont {
        if fontName == "System" {
            return .systemFont(ofSize: size)
        }
        return UIFont(name: fontName, size: size) ?? .systemFont(ofSize: size)
    }
    
    var lineSpacing: CGFloat {
        max(0, lineHeight - uiFont.lineHeight)
    }
    
    var verticalPadding: CGFloat {
        lineSpacing / 2
    }
}

extension FontStyle {
    // Headline
    static let headlineS = FontStyle(font: .custom("Pretendard-Bold", size: 28), fontName: "Pretendard-Bold", size: 28, lineHeight: 28 * 1.4)
    
    // Title
    static let title1 = FontStyle(font: .custom("Pretendard-Bold", size: 24), fontName: "Pretendard-Bold", size: 24, lineHeight: 24 * 1.4)
    static let title2 = FontStyle(font: .custom("Pretendard-Bold", size: 20), fontName: "Pretendard-Bold", size: 20, lineHeight: 20 * 1.4)
    static let title3 = FontStyle(font: .custom("Pretendard-Bold", size: 18), fontName: "Pretendard-Bold", size: 18, lineHeight: 18 * 1.4)
    
    // Label
    static let labelL = FontStyle(font: .custom("Pretendard-Bold", size: 16), fontName: "Pretendard-Bold",  size: 16, lineHeight: 16 * 1.4)
    static let labelM = FontStyle(font: .custom("Pretendard-Bold", size: 14), fontName: "Pretendard-Bold", size: 14, lineHeight: 14 * 1.4)
    
    // Body
    static let body1 = FontStyle(font: .custom("Pretendard-SemiBold", size: 16), fontName: "Pretendard-SemiBold", size: 16, lineHeight: 16 * 1.4)
    static let body2 = FontStyle(font: .custom("Pretendard-SemiBold", size: 14), fontName: "Pretendard-SemiBold", size: 14, lineHeight: 14 * 1.4)
    
    // Caption
    static let captionL = FontStyle(font: .custom("Pretendard-Regular", size: 16), fontName: "Pretendard-Regular", size: 16, lineHeight: 16 * 1.4)
    static let captionM = FontStyle(font: .custom("Pretendard-Regular", size: 14), fontName: "Pretendard-Regular", size: 14, lineHeight: 14 * 1.4)
    
    // Numeric (SF Mono)
    static let num1 = FontStyle(font: .custom("SFMono-Semibold", size: 20), fontName: "SFMono-Semibold", size: 20, lineHeight: 20 * 1.5)
    static let num2 = FontStyle(font: .custom("SFMono-Semibold", size: 18), fontName: "SFMono-Semibold", size: 18, lineHeight: 18 * 1.5)
    static let num3 = FontStyle(font: .custom("SFMono-Semibold", size: 16), fontName: "SFMono-Semibold", size: 16, lineHeight: 16 * 1.5)
    static let num4 = FontStyle(font: .custom("SFMono-Medium", size: 16), fontName: "SFMono-Medium", size: 16, lineHeight: 16 * 1.5)
    static let num5 = FontStyle(font: .custom("SFMono-Semibold", size: 14), fontName: "SFMono-Semibold", size: 14, lineHeight: 14 * 1.5)
    static let num6 = FontStyle(font: .custom("SFMono-Medium", size: 14), fontName: "SFMono-Medium", size: 14, lineHeight: 14 * 1.5)
    static let num7 = FontStyle(font: .custom("SFMono-Semibold", size: 12), fontName: "SFMono-Semibold", size: 12, lineHeight: 12 * 1.3)
}

