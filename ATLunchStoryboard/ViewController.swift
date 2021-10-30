//
//  ViewController.swift
//  ATLunchStoryboard
//
//  Created by Hector Castillo on 10/30/21.
//

import UIKit
import CoreLocation
import MapKit
import SnapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager?

    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        return mapView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()

        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.top.right.left.bottom.equalToSuperview()
        }

    }

    // MARK: - CLLocationManagerDelegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            case .authorizedWhenInUse,.authorizedAlways:
                print("you got it, dude")
                print(locationManager?.location)
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
            case .denied, .restricted:
                print("not gonna work, bud")
                manager.requestWhenInUseAuthorization()
                //graceful way to tell user they can't use the app?
            default:
                print("something new happened without apple telling us")
        }
    }
}

