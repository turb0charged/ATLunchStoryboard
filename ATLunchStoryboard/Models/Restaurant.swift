//
//  Restaurant.swift
//  ATLunchStoryboard
//
//  Created by Hector Castillo on 10/31/21.
//

import UIKit
import MapKit

class Restaurant: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String
    var rating: Double
    var userRatingsTotal: Int
    var priceLevel: Int?
    var photoReference: String?
    var priceLevelString: String {
        return String(repeating: "$", count: priceLevel ?? 0)
    }

    init(title: String, coordinate: CLLocationCoordinate2D, info: String, rating: Double, userRatingsTotal: Int, priceLevel: Int? = nil, photoReference: String? = nil) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
        self.rating = rating
        self.userRatingsTotal = userRatingsTotal
        self.priceLevel = priceLevel
        self.photoReference = photoReference
    }
}
