//
//  ConnectionNavigationBar.swift
//  HonestHouse
//
//  Created by Rama on 11/18/25.
//

import SwiftUI

struct ConnectionNavigationBar: View {
    @Environment(\.dismiss) var dismiss
    
    let title: String
    
    var body: some View {
            ZStack {
                Text("\(title)")
                    .fontStyle(.num4)
                    .foregroundColor(.g0)
                
                HStack(alignment: .center) {
                    Button {
                        dismiss()
                    } label: {
                        Image(.closeIcon)
                            .resizable()
                            .frame(width: 36, height: 36)
                    }
                    
                    Spacer()
                }
            }
            .frame(height: 36)
            .background(Color.clear)
    }
}

