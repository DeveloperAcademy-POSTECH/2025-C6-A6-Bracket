//
//  GroupedPhotosSkeletonView.swift
//  HonestHouse
//
//  Created by 이현주 on 11/4/25.
//

import SwiftUI

struct GroupedPhotosSkeletonView: View {
    let columnCount: Int = 2

    var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 9), count: columnCount)
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 9) {
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
            .fill(Color.g11)
            .aspectRatio(3/2, contentMode: .fit)
    }
}

#Preview {
    GroupedPhotosSkeletonView()
}
