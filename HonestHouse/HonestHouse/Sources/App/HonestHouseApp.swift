//
//  HonestHouseApp.swift
//  HonestHouse
//
//  Created by Rama on 10/11/25.
//

import SwiftUI
import SwiftData

@main
struct HonestHouseApp: App {
    let modelContainer: ModelContainer
    
    @State var container: DIContainer
    @StateObject var cameraConnectionManager = CameraConnectionManager()
    @State private var showConnectionSheet = false

    init() {
        do {
            modelContainer = try ModelContainer(for: Preset.self)
            let services = Services(modelContext: modelContainer.mainContext)
            container = DIContainer(services: services, managers: Managers())
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            MainView(vm: MainViewModel(container: container))
                .environmentObject(container)
                .environmentObject(cameraConnectionManager)
                .preferredColorScheme(.dark)
                .onAppear {
                    if !cameraConnectionManager.isConnected {
                        showConnectionSheet = true
                    }
                }
                .onChange(of: cameraConnectionManager.isConnected) { _, isConnected in
                    showConnectionSheet = !isConnected
                }
                .sheet(isPresented: $showConnectionSheet) {
                    CameraConnectionView()
                        .environmentObject(container)
                        .environmentObject(cameraConnectionManager)
                }
        }
        .modelContainer(modelContainer)
    }
}
