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
    static let persistenceController = PersistenceController.shared
    
    @StateObject var container: DIContainer = .init(services: Services(), managers: Managers(viewContext: persistenceController.viewContext))
    
    var body: some Scene {
        WindowGroup {
            MainView(vm: MainViewModel(container: container))
                .environmentObject(container)
                .environment(\.managedObjectContext, Self.persistenceController.viewContext)
                .environmentObject(CameraConnectionManager.shared)
                .preferredColorScheme(.dark)
        }
    }
}
