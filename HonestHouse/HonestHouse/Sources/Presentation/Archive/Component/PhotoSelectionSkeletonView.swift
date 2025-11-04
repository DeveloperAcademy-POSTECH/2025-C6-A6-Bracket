//
//  PhotoSelectionSkeletonView.swift
//  HonestHouse
//
//  Created by 이현주 on 11/4/25.
//

import SwiftUI

struct PhotoSelectionSkeletonView: View {
    let columnCount: Int = 3

    var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 5), count: columnCount)
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(0..<30, id: \.self) { _ in
                    skeletonCell()
                }
            }
            .screenPadding()
        }
        .scrollDisabled(true)
    }

    private func skeletonCell() -> some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.g10)
            .frame(height: 78)
    }
}

#Preview {
    PhotoSelectionSkeletonView()
}
