//
//  MockCoordinateProvider.swift
//  WhereToEat
//
//  Created by Daria Kalmykova on 29.04.2020.
//  Copyright © 2020 Daria Kalmykova. All rights reserved.
//

import Foundation
import UIKit

class MockCoordinateProvider: CoordinateProvider {
    private enum Constants {
        static let timeKey = "time"
    }
    
    private let coordinates: [Coordinate]
    private let userDefaults: UserDefaults
    
    private let period: TimeInterval
    
    private var timer: Timer?
    
    private var _index = 0
    
    private var index: Int {
        get {
            return _index
        }
        
        set {
            _index = newValue % coordinates.count
        }
    }
    
    /* This hack is necessary when timer is nearly to fire.
     In this case it happens that timer fires before applicationWillEnterForeground calls. */
    private var pause = false
    
    weak var delegate: CoordinateProviderDelegate?
    
    init(coordinates: [Coordinate], userDefaults: UserDefaults, period: TimeInterval) {
        self.coordinates = coordinates
        self.userDefaults = userDefaults
        self.period = period
    }
    
    func startUpdatingCoordinate() {
        guard timer == nil else {
            NSLog("Timer has already started!")
            return
        }
        
        pause = false
        onUpdateCoordinate()
                        
        timer = Timer.scheduledTimer(withTimeInterval: period, repeats: true) { [weak self] _ in
            guard let self = self, !self.pause else { return }
            
            self.index += 1
            NSLog("Coordinate index with timer update: \(self.index)")
            
            self.onUpdateCoordinate()
        }
        
        NSLog("Coordinate index timer started!")
    }
    
    func stopUpdateCoordinate() {
        timer?.invalidate()
        timer = nil
    }
    
    func saveState() {
        guard timer != nil else { return }

        userDefaults.set(Date().timeIntervalSince1970, forKey: Constants.timeKey)
        pause = true
    }
    
    func restoreState() {
        guard let timer = timer else { return }

        let lastActiveTime = userDefaults.double(forKey: Constants.timeKey)
        let timeDiff = Int((Date().timeIntervalSince1970 - lastActiveTime).rounded())
        
        let oldIndex = index
        
        let indexDiff = timeDiff / Int(period)
        index += indexDiff
        NSLog("Coordinate index with background diff: \(index)")
                
        var newFireDate = timer.fireDate.addingTimeInterval(-TimeInterval(timeDiff % Int(period)))
        if newFireDate.timeIntervalSinceNow < 0 {
            index += 1
            NSLog("Coordinate index with accumulation in background: \(index)")
            newFireDate.addTimeInterval(period)
        }
        
        timer.fireDate = newFireDate
        
        if index != oldIndex {
            onUpdateCoordinate()
        }
                
        pause = false
    }
    
    @objc private func onUpdateCoordinate() {
        NSLog("Update for coordinate index: \(index)")
        delegate?.coordinateProvider(self, didUpdateCoordinate: coordinates[index])
    }
}
