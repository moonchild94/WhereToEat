//
//  FavoriteVenue.swift
//  WhereToEat
//
//  Created by Daria Kalmykova on 29.04.2020.
//  Copyright © 2020 Daria Kalmykova. All rights reserved.
//

import Foundation

struct FavoriteVenue {
    let id: String
}

extension FavoriteVenue: ManagedObjectInitializable {
    init?(managedObject: FavoriteVenueEntity) {
        guard let id = managedObject.id else { return nil }
        self.id = id
    }
}
