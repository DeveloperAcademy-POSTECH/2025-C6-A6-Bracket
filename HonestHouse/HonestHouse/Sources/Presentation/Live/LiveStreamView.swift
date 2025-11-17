//
//  LiveStreamView.swift
//  CCAPI_test
//
//  Created by Subeen on 10/27/25.
//

import SwiftUI

struct LiveStreamView: View {
    @State var vm: LiveStreamViewModel

    var body: some View {
        VStack(spacing: 20) {
            if let image = vm.currentImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Text("라이브뷰 대기 중")
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 274)
        .task {
            await vm.observeViewLifecycle()
        }
    }
}
