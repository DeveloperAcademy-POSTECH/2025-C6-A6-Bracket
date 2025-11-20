//
//  ProgressiveDisplayImage.swift
//  HonestHouse
//
//  Created by 이현주 on 11/1/25.
//

import SwiftUI
import Kingfisher

/// DetailView용 이미지 (Thumbnail 먼저 표시 → Display 로딩 → Display 실패 시 원본)
struct ProgressiveDisplayImageView: View {
    @State private var shouldUseFallback = false
    
    let photo: Photo
    
    var body: some View {
        Group {
            if shouldUseFallback {
                // Display 실패 시 원본 사용
                originalImageView(url: photo.url)
            } else {
                // Display 먼저 시도
                displayImageView(url: photo.displayURL)
            }
        }
    }
    
    private func displayImageView(url: String) -> some View {
        KFImage(URL(string: url))
            .placeholder {
                thumbnailImageView(url: photo.thumbnailURL)
            }
            .onFailure { error in
                print("[Display] Failed: \(photo.displayURL) - \(error.localizedDescription)")
                print("[Fallback] Using original: \(photo.url)")
                shouldUseFallback = true
            }
            .retry(maxCount: 2, interval: .seconds(2))
            .cacheOriginalImage()
            .resizable()
            .fade(duration: 0.3)
            .aspectRatio(contentMode: .fit)
    }
    
    private func originalImageView(url: String) -> some View {
        KFImage(URL(string: url))
            .placeholder {
                thumbnailImageView(url: photo.thumbnailURL)
            }
            .retry(maxCount: 2, interval: .seconds(2))
            .cacheOriginalImage()
            .resizable()
            .fade(duration: 0.3)
            .aspectRatio(contentMode: .fit)
    }
    
    private func thumbnailImageView(url: String) -> some View {
        KFImage(URL(string: url))
            .placeholder {
                Color.g11
                    .frame(maxWidth: .infinity)
                    .aspectRatio(3/2, contentMode: .fit)
            }
            .cacheMemoryOnly()
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}
