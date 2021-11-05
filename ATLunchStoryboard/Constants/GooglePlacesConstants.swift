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

    static var apiKey: String {
        get {
            guard let filePath = Bundle.main.path(forResource: "keys", ofType: "plist") else {
                fatalError("Couldn't find file 'keys.plist'.")
            }
            let plist = NSDictionary(contentsOfFile: filePath)
            guard let value = plist?.object(forKey: "GOOGLE_PLACES_API_KEY") as? String else {
                fatalError("Couldn't find key 'GOOGLE_PLACES_API_KEY' in 'keys.plist'.")
            }
            return value
        }
    }
}
