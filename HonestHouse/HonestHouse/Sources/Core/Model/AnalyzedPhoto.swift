//
//  AnalyzedPhoto.swift
//  HonestHouse
//
//  Created by Rama on 10/24/25.
//

import Vision

struct AnalyzedPhoto {
    let photo: Photo
    let observation: VNFeaturePrintObservation
    let faceObservation: VNFaceObservation?
    
    var hasFace: Bool {
        faceObservation != nil
    }
}
