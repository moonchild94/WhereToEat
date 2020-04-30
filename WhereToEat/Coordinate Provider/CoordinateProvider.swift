//
//  CoordinateProvider.swift
//  WhereToEat
//
//  Created by Daria Kalmykova on 29.04.2020.
//  Copyright © 2020 Daria Kalmykova. All rights reserved.
//

import Foundation

struct Coordinate {
    let latitude: Double
    let longitude: Double
}

protocol CoordinateProviderDelegate: AnyObject {
    func coordinateProvider(_ coordinateProvider: CoordinateProvider, didUpdateCoordinate coordinate: Coordinate)
}

protocol CoordinateProvider: AnyObject {
    var delegate: CoordinateProviderDelegate? { get set }

    func saveState()
    
    func restoreState()
    
    func startUpdatingCoordinate()
    
    func stopUpdateCoordinate()
}
