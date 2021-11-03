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

    init(title: String, coordinate: CLLocationCoordinate2D, info: String, rating: Double, userRatingsTotal: Int) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
        self.rating = rating
        self.userRatingsTotal = userRatingsTotal
    }
}
