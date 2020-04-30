//
//  VenueService.swift
//  WhereToEat
//
//  Created by Daria Kalmykova on 29.04.2020.
//  Copyright © 2020 Daria Kalmykova. All rights reserved.
//

import Foundation

class VenueService: NetworkService {
    func getVenues(for coordinate: Coordinate, completion: @escaping ([VenueDto]?, Error?) -> Void) {
        let params: [String: Any] = ["lat": coordinate.latitude, "lon": coordinate.longitude]
        executeQuery(with: params) { (response: VenueResponse?, error: Error?) in
            completion(response?.results, error)
        }
    }
}
