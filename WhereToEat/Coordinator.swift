//
//  Coordinator.swift
//  WhereToEat
//
//  Created by Daria Kalmykova on 30.04.2020.
//  Copyright © 2020 Daria Kalmykova. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Coordinator {
    private enum Constants {
        static let dbName = "Model"
        
        static let apiUrl = "https://restaurant-api.wolt.fi/v3/venues"
        
        static let coordinates = [Coordinate(latitude: 60.170187, longitude: 24.930599),
                                  Coordinate(latitude: 60.169418, longitude: 24.931618),
                                  Coordinate(latitude: 60.169818, longitude: 24.932906),
                                  Coordinate(latitude: 60.170005, longitude: 24.935105),
                                  Coordinate(latitude: 60.169108, longitude: 24.936210),
                                  Coordinate(latitude: 60.168355, longitude: 24.934869),
                                  Coordinate(latitude: 60.167560, longitude: 24.932562),
                                  Coordinate(latitude: 60.168254, longitude: 24.931532),
                                  Coordinate(latitude: 60.169012, longitude: 24.930341),
                                  Coordinate(latitude: 60.170085, longitude: 24.929569)]
    }
    
    private let coordinateProvider: CoordinateProvider = MockCoordinateProvider(coordinates: Constants.coordinates,
                                                                                userDefaults: UserDefaults.standard,
                                                                                period: 1000)
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Constants.dbName)
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return container
    }()
    
    private lazy var presenter: VenuesListPresenter = {
        let venueService = VenueNetworkService(baseUrl: Constants.apiUrl)
        let favoriteVenueRepository = FavoriteVenueRepository(persistentContainer: persistentContainer)
        
        return VenuesListPresenter(coordinateProvider: coordinateProvider,
                                   venueService: venueService,
                                   favoriteVenueRepository: favoriteVenueRepository)
    }()
    
    func show(on window: UIWindow) {
        let viewController = VenuesListViewController()
        presenter.renderer = viewController
        presenter.start()
        
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
    
    func saveState() {
        coordinateProvider.saveState()
    }
    
    func restoreState() {
        coordinateProvider.restoreState()
    }
}
