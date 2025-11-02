//
//  HonestHouseApp.swift
//  HonestHouse
//
//  Created by Rama on 10/11/25.
//

import SwiftUI
import CoreData

@main
struct HonestHouseApp: App {
    let persistenceController = PersistenceController.shared  // ← 추가
    @State var container: DIContainer
    @StateObject var cameraConnectionManager = CameraConnectionManager()
    @State private var showConnectionSheet = false

    init() {
        let viewContext = persistenceController.viewContext  // ← viewContext 추출
        let services = Services()
        let managers = Managers(viewContext: viewContext)  // ← viewContext 주입
        container = DIContainer(services: services, managers: managers)
    }

    var body: some Scene {
        WindowGroup {
            MainView(vm: MainViewModel(container: container))
                .environmentObject(container)
                .environment(\.managedObjectContext, persistenceController.viewContext)  // ← 추가
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
    }
}
