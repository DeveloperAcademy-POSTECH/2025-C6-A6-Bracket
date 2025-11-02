import SwiftUI

struct CameraConnectionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var container: DIContainer
    
    var body: some View {
        VStack {
            connectionStatusView()
            
            if let errorMessage = container.managers.cameraConnectionManager.errorMessage {
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
        switch container.managers.cameraConnectionManager.connectionState {
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
            container.managers.cameraConnectionManager.connectCamera(ipAddress: BaseURLConstants.cameraIP)
        } label: {
            Text("Connect to Camera")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(container.managers.cameraConnectionManager.connectionState == .connecting ? Color.gray : Color.blue)
                .cornerRadius(10)
        }
        .padding()
        .disabled(container.managers.cameraConnectionManager.connectionState == .connecting)
    }
}

#Preview {
    CameraConnectionView()
        .environmentObject(CameraConnectionManager())
}
