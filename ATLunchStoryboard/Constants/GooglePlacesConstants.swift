//
//  GooglePlacesConstants.swift
//  ATLunchStoryboard
//
//  Created by Hector Castillo on 11/4/21.
//

import Foundation

struct GooglePlacesConstants {
    static let BaseURL = "https://maps.googleapis.com/maps/api/place"
    struct Paths {
        static let TextSearch = "/textsearch/json"
        static let PlaceDetails = "/details/json"
        static let PlaceFromText = "/placefromtext/json"
        static let NearbySearch = "/nearbysearch/json"
        static let PlacePhoto = "/photo"
    }
}
