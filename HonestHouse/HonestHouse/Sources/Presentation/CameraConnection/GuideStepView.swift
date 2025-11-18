//
//  GuideStepView.swift
//  HonestHouse
//
//  Created by Rama on 11/18/25.
//

import SwiftUI

struct GuideStepView: View {
    var number: Int
    var description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            Image("guideNumber\(number)")
                .resizable()
                .frame(width: 28, height: 28)
            
            Text(description)
                .fontStyle(.num4)
                .foregroundStyle(Color.g0)
            
            Spacer()
        }
        
        
    }
}
