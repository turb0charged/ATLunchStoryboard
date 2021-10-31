//
//  Restaurant.swift
//  ATLunchStoryboard
//
//  Created by Hector Castillo on 10/31/21.
//

import UIKit
import MapKit

class Restaurant: NSObject, MKAnnotation {
    var name: String
    var coordinate: CLLocationCoordinate2D
    var info: String

    init(name: String, coordinate: CLLocationCoordinate2D, info: String) {
        self.name = name
        self.coordinate = coordinate
        self.info = info
    }
}
