//
//  ConnectionCompletionView.swift
//  HonestHouse
//
//  Created by Rama on 11/4/25.
//

import SwiftUI

struct ConnectionCompletionView: View {
    
    @EnvironmentObject var cameraConnectionManager: CameraConnectionManager
    
    @Environment(\.dismiss) var dismiss
    
    @State private var cameraName: String = "Canon R6"
    
    var body: some View {
        VStack {
            connectImageView()
                .padding(.top, 75)
                .padding(.bottom, 38)
            
            Text("\(cameraName)")
                .font(.title1)
                .foregroundStyle(Color.g0)
                .padding(.bottom, 14)
            
            Button {
                dismiss()
                cameraConnectionManager.disconnectCamera()
            } label: {
                Text("변경")
                    .font(.captionL)
                    .foregroundStyle(Color.g7)
            }
            
            Spacer()
            
            startButtonView()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("카메라 연결")
                    .font(.num4)
                    .foregroundStyle(Color.g0)
            }
        }
    }
    
    private func connectImageView() -> some View {
        Image("connectImage")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .frame(width: 300, height: 115)
    } 
    
    private func startButtonView() -> some View {
        Button {
            cameraConnectionManager.showConnectionSheet = false
        } label: {
            Text("Start Tri-shot")
                .font(.num3)
                .foregroundStyle(Color.g12)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.g0)
        .cornerRadius(62)
    }
}

#Preview {
    ConnectionCompletionView()
}
