//
//  PictureStyleType.swift
//  HonestHouse
//
//  Created by BoMin Lee on 10/28/25.
//

enum PictureStyleType: String, Codable, CaseIterable {
    
    case auto = "자동"
    case standard = "표준"
    case portrait = "인물"
    case landscape = "풍경"
    case finedetail = "상세"
    case neutral = "뉴트럴"
    case faithful = "충실설정"
    case monochrome = "모노크롬"
    
    var apiValue: String {
        switch self {
        case .auto: return "auto"
        case .standard: return "standard"
        case .portrait: return "portrait"
        case .landscape: return "landscape"
        case .finedetail: return "finedetail"
        case .neutral: return "neutral"
        case .faithful: return "faithful"
        case .monochrome: return "monochrome"
        }
    }

    var displayValue: String {
        return rawValue
    }
}
