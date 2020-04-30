//
//  ManagedObjectInitializable.swift
//  WhereToEat
//
//  Created by Daria Kalmykova on 29.04.2020.
//  Copyright © 2020 Daria Kalmykova. All rights reserved.
//

import CoreData

protocol ManagedObjectInitializable {
    associatedtype Entity: NSManagedObject
    init?(managedObject: Entity)
}
