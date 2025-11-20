import SwiftUI

struct CameraConnectionView: View {
    @EnvironmentObject var container: DIContainer
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.g12.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ConnectionNavigationBar(title: "카메라 연결")
                        .padding(.horizontal, 16)
                        .padding(.top, 26)
                    
                    Spacer().frame(height: 48)
                    
                    connectImageView()
                    
                    Spacer().frame(height: 53)
                    
                    VStack(spacing: 16) {
                        connectButtonView(type: .ip)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func connectImageView() -> some View {
        Image(.connectionCamera)
            .resizable()
            .scaledToFit()
            .frame(width: 264, height: 176)
    }
    
    private func connectButtonView(type: ConnectionType) -> some View {
        NavigationLink {
            if type == .bluetooth {
                BluetoothConnectionGuideView()
            } else {
                IPConnectionGuideView()
            }
        } label: {
            HStack(spacing: 4) {
                type.buttonImage
                    .resizable()
                    .frame(width: 24, height: 24)
                
                Text("\(type.title)")
                    .fontStyle(.num3)
                    .foregroundStyle(Color.g12)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(Color.g0)
            .cornerRadius(50)
        }
        .padding(.horizontal)
    }
}
