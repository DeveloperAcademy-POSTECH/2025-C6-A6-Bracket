import SwiftUI

struct CameraConnectionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var container: DIContainer
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.g12.ignoresSafeArea()
                
                VStack(spacing: 78) {
                    connectImageView()
                    connectButtonView(type: .ip)
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("카메라 연결")
                            .fontStyle(.num4)
                            .foregroundColor(.g0)
                    }
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(.closeIcon)
                                .resizable()
                                .frame(width: 36, height: 36)
                        }
                    }
                }
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
    
    private func connectButtonView(type: ConnectionType) -> some View {
        NavigationLink {
            ConnectionGuideView(type: type)
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

//#Preview {
//    CameraConnectionView()
//        .environmentObject(CameraConnectionManager())
//}
