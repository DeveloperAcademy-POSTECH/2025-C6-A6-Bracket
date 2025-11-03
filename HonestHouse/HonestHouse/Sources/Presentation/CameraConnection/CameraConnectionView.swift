import SwiftUI

struct CameraConnectionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var container: DIContainer
    @EnvironmentObject var cameraConnectionManager: CameraConnectionManager
    
    var body: some View {
        VStack {
            connectionStatusView()
            
            if let errorMessage = cameraConnectionManager.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            }
            
            cameraConnectButton()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Dismiss") {
                    dismiss()
                }
            }
        }
    }
    
    private func connectionStatusView() -> some View {
        switch cameraConnectionManager.connectionState {
        case .disconnected:
            Text("Disconnected")
                .foregroundColor(.gray)
        case .connecting:
            Text("Disconnected")
                .foregroundColor(.gray)
        case .connected:
            Text("Connected")
                .foregroundColor(.green)
        case .failed(let error):
            Text("Connection Failed: \(error)")
                .foregroundColor(.red)
        }
    }
    
    private func cameraConnectButton() -> some View {
        Button {
            cameraConnectionManager.connectCamera(ipAddress: BaseURLConstants.cameraIP)
        } label: {
            Text("Connect to Camera")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(cameraConnectionManager.connectionState == .connecting ? Color.gray : Color.blue)
                .cornerRadius(10)
        }
        .padding()
        .disabled(cameraConnectionManager.connectionState == .connecting)
    }
}

#Preview {
    CameraConnectionView()
        .environmentObject(CameraConnectionManager())
}
