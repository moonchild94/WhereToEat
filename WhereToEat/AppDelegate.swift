//
//  AppDelegate.swift
//  WhereToEat
//
//  Created by Daria Kalmykova on 29.04.2020.
//  Copyright © 2020 Daria Kalmykova. All rights reserved.
//

import UIKit
import Kingfisher

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    private let coordinator = Coordinator()
        
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ImageCache.default.memoryStorage.config.totalCostLimit = 100 * 1024 * 1024
        
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            coordinator.show(on: window)
        }
                        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        coordinator.saveState()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        coordinator.restoreState()
    }
}

