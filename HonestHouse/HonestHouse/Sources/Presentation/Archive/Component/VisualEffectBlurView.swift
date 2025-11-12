//
//  VisualEffectBlurView.swift
//  HonestHouse
//
//  Created by 이현주 on 11/12/25.
//

import Foundation
import SwiftUI

struct VisualEffectBlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        DispatchQueue.main.async {
            if let backdropLayer = uiView.layer.sublayers?.first {
                backdropLayer.filters = []
            }
        }
    }
}
