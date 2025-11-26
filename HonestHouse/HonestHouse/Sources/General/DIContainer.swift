//
//  DIContainer.swift
//  HonestHouse
//
//  Created by Subeen on 10/22/25.
//

import Foundation

class DIContainer: ObservableObject {
    var services: ServiceType
    var managers: ManagersType
    var navigationRouter: NavigationRoutable & ObservableObjectSettable
    var presetStateObserver: PresetStateObserver
    
    init(
        services: ServiceType,
        managers: ManagersType,
        navigationRouter: NavigationRoutable & ObservableObjectSettable = NavigationRouter(),
        presetStateObserver: PresetStateObserver = PresetStateObserver()
    ) {
        self.services = services
        self.managers = managers
        self.presetStateObserver = presetStateObserver
        
        self.navigationRouter = navigationRouter
        self.navigationRouter.setObjectWillChange(objectWillChange)
    }
}

extension DIContainer {
    static var stub: DIContainer {
        .init(services: StubServices(), managers: StubManagers(), navigationRouter: StubNavigationRouter())
    }
}
