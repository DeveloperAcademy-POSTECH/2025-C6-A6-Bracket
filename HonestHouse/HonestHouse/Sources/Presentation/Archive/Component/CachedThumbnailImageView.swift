//
//  CachedThumbnailImage.swift
//  HonestHouse
//
//  Created by 이현주 on 11/1/25.
//

import SwiftUI
import Kingfisher

/// Thumbnail 이미지만 표시 (그리드, 그룹 대표 이미지 등)
struct CachedThumbnailImageView: View {
    let url: String
    
    var body: some View {
        KFImage(URL(string: url))
            .placeholder {
                Color.g9
            }
            .retry(maxCount: 2, interval: .seconds(1))
            .cacheMemoryOnly() // Thumbnail은 메모리만
            .fade(duration: 0.2)
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
}
