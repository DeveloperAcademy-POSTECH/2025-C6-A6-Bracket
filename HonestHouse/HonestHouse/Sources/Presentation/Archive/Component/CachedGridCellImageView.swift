//
//  CachedGridCellImage.swift
//  HonestHouse
//
//  Created by 이현주 on 11/1/25.
//

import SwiftUI
import Kingfisher

/// Thumbnail 이미지만 표시 (그리드, 그룹 대표 이미지 등)
struct CachedGridCellImageView: View {
    let url: String
    
    var body: some View {
        Color.g10
            .frame(maxWidth: .infinity)
            .aspectRatio(3/2, contentMode: .fit)
            .overlay(
                KFImage(URL(string: url))
                    .placeholder {
                        Color.clear
                    }
                    .retry(maxCount: 2, interval: .seconds(1))
                    .cacheMemoryOnly()
                    .fade(duration: 0.2)
                    .resizable()
                    .scaledToFit()  // 컨테이너 안에 맞추기
                    .scaleEffect(1.12)
            )
            .clipped()
    }
}
