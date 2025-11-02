//
//  ProgressiveDisplayImage.swift
//  HonestHouse
//
//  Created by 이현주 on 11/1/25.
//

import SwiftUI
import Kingfisher

/// DetailView용 이미지 (Thumbnail 먼저 표시 → Display 로딩 → Display 실패 시 원본)
struct ProgressiveDisplayImage: View {
    let thumbnailURL: String
    let displayURL: String
    let originalURL: String  // Display 실패 시 fallback

    @State private var shouldUseFallback = false

    var body: some View {
        Group {
            if shouldUseFallback {
                // Display 실패 시 원본 사용
                KFImage(URL(string: originalURL))
                    .placeholder {
                        KFImage(URL(string: thumbnailURL))
                            .cacheMemoryOnly()
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    .retry(maxCount: 2, interval: .seconds(2))
                    .cacheOriginalImage()
                    .resizable()
                    .fade(duration: 0.3)
                    .aspectRatio(contentMode: .fit)
            } else {
                // Display 먼저 시도
                KFImage(URL(string: displayURL))
                    .placeholder {
                        KFImage(URL(string: thumbnailURL))
                            .cacheMemoryOnly()
                            .resizable()
                            .aspectRatio(contentMode: .fit)
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
        }
    }
}
