//
//  VenueResponse.swift
//  WhereToEat
//
//  Created by Daria Kalmykova on 29.04.2020.
//  Copyright © 2020 Daria Kalmykova. All rights reserved.
//

import Foundation

struct VenueResponse: Response {
    let results: [VenueDto]
    let status: String
}

/* Mapping:
- id -> $oid Unique id of the venue
- name -> [0] -> value Name of the venue
- short_description -> [0] -> value Description of the venue
- listimage Image URL for the venue */
struct VenueDto: Decodable {
    let id: String
    let name: String
    let shortDescription: String
    let imageUrl: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(ItemId.self, forKey: .id).id
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
        shortDescription = try container.decode([Localazable].self, forKey: .shortDescription).firstEnglishValue() ?? ""
        name = try container.decode([Localazable].self, forKey: .name).firstEnglishValue() ?? ""
    }

     private enum CodingKeys: String, CodingKey {
        case id = "itemid"
        case name
        case shortDescription = "short_description"
        case imageUrl = "listimage"
    }
}

private struct ItemId: Decodable {
    let id: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "$oid"
    }
}

private struct Localazable: Decodable {
    let lang: String
    let value: String
}

private extension Array where Element == Localazable {
    func firstEnglishValue() -> String? {
        return first { $0.lang == "en" }?.value.trimmingCharacters(in: .whitespaces)
    }
}
