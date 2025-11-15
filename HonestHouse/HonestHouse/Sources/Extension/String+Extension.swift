//
//  String+Extension.swift
//  HonestHouse
//
//  Created by Subeen on 11/16/25.
//

extension String {
    /// 조리개값(f8.0) 에서 숫자만 추출한 문자열
    var apertureNumericValue: String {
        self.replacingOccurrences(of: "f", with: "", options: .caseInsensitive)
            .trimmingCharacters(in: .whitespaces)
    }
}
