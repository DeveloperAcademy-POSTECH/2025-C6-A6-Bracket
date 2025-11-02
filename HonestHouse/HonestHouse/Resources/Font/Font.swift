//
//  Font.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

import SwiftUI

extension Font {
    static let headlineS: Font = .custom("Pretendard-Bold", size: 28)   /// Pretendard Bold 28 140%
 
    static let title1: Font = .custom("Pretendard-Bold", size: 24)      /// Pretendard Bold 24 140%
    static let title2: Font = .custom("Pretendard-Bold", size: 20)      /// Pretendard Bold 20 140%
    static let title3: Font = .custom("Pretendard-Bold", size: 18)      /// Pretendard Bold 18 140%
 
    static let labelL: Font = .custom("Pretendard-Bold", size: 16)      /// Pretendard Bold 16 140%
    static let labelM: Font = .custom("Pretendard-Bold", size: 14)      /// Pretendard Bold 14 140%
 
    static let body1: Font = .custom("Pretendard-SemiBold", size: 16)   /// Pretendard SemiBold 16 140%
    static let body2: Font = .custom("Pretendard-SemiBold", size: 14)   /// Pretendard SemiBold 14 140%
 
    static let captionL: Font = .custom("Pretendard-Regular", size: 16) /// Pretendard Regular 16
    static let captionM: Font = .custom("Pretendard-Regular", size: 14) /// Pretendard Regular 14 140%
 
    static let num1: Font = .custom("SFMono-Semibold", size: 20)         /// SF Mono SemiBold 20  130%
    static let num2: Font = .custom("SFMono-Semibold", size: 18)         /// SF Mono SemiBold 18  130%
    static let num3: Font = .custom("SFMono-Medium", size: 16)           /// SF Mono Medium 16  130%
    static let num4: Font = .custom("SFMono-Medium", size: 14)           /// SF Mono Medium 14  130%
}

/// 폰트가 추가되었는지 확인
func checkFontFile() {
    for fontFamily in UIFont.familyNames {
        for fontName in UIFont.fontNames(forFamilyName: fontFamily) {
            print(fontName)
        }
    }
}

/// 프레임을 폰트 높이에 맞추기
func heightForFontSize(_ size: CGFloat) -> CGFloat {
    let font = UIFont.systemFont(ofSize: size)
    return font.capHeight
}
