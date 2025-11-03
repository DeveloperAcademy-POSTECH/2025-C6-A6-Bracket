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
    let thumbnailURL: String
    let displayURL: String
    let originalURL: String  // Display 실패 시 fallback
    let onImageLoaded: (() -> Void)?  // 이미지 로딩 완료 콜백

    @State private var shouldUseFallback = false

    var body: some View {
        Group {
            if shouldUseFallback {
                // Display 실패 시 원본 사용
                originalImageView(url: originalURL)
            } else {
                // Display 먼저 시도
                displayImageView(url: displayURL)
            }
        }
    }
    
    private func displayImageView(url: String) -> some View {
        KFImage(URL(string: url))
            .placeholder {
                thumbnailImageView(url: thumbnailURL)
            }
            .onSuccess { _ in
                onImageLoaded?()
            }
            .onFailure { error in
                print("[Display] Failed: \(displayURL) - \(error.localizedDescription)")
                print("[Fallback] Using original: \(originalURL)")
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
                thumbnailImageView(url: thumbnailURL)
            }
            .onSuccess { _ in
                onImageLoaded?()
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
                Color.g10
                    .frame(maxWidth: .infinity)
                    .aspectRatio(3/2, contentMode: .fit)
            }
            .cacheMemoryOnly()
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}
