//
//  CachedGridCellImage.swift
//  HonestHouse
//
//  Created by 이현주 on 11/1/25.
//

import SwiftUI
import Kingfisher

/// 그리드, 그룹 대표 이미지 (GridCell)
struct CachedGridCellImageView: View {
    let url: String
    let originalURL: String
    
    @State private var shouldUseFallback = false
    
    var body: some View {
        Color.g10
            .frame(maxWidth: .infinity)
            .aspectRatio(3/2, contentMode: .fit)
            .overlay(
                Group {
                    if shouldUseFallback {
                        fallbackImageView()
                    } else {
                        displayImageView()
                    }
                }
            )
            .clipped()
    }
    
    private func displayImageView() -> some View {
        KFImage(URL(string: url))
            .placeholder {
                Color.clear
            }
            .retry(maxCount: 2, interval: .seconds(1))
            .onFailure { _ in
                shouldUseFallback = true
            }
            .cacheOriginalImage()  // 디스크+메모리 캐싱
            .fade(duration: 0.2)
            .resizable()
            .scaledToFit()
            .scaleEffect(1.12)
    }
    
    private func fallbackImageView() -> some View {
        KFImage(URL(string: originalURL))
            .placeholder {
                Color.clear
            }
            .retry(maxCount: 2, interval: .seconds(1))
            .cacheOriginalImage()
            .fade(duration: 0.2)
            .resizable()
            .scaledToFit()
    }
}
