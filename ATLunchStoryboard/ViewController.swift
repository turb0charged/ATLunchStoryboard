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

    private var apiKey: String {
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

    override func viewDidLoad() {
        super.viewDidLoad()
            // Do any additional setup after loading the view.
        self.navigationItem.title = "AT Lunch"
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()

        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.right.left.bottom.equalToSuperview()
        }

        setupMapView()
    }

    func setupMapView() {
        guard let manager = locationManager, manager.authorizationStatus == .authorizedWhenInUse ||
                manager.authorizationStatus == .authorizedAlways else {
                    return
                }
        if let userLocationCoordinate = manager.location?.coordinate {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let userLocationRegion = MKCoordinateRegion(center: userLocationCoordinate, span: span)
            mapView.setRegion(userLocationRegion, animated: true)
        } else {
            mapView.setCenter(manager.location?.coordinate ?? mapView.userLocation.coordinate,
                              animated: true)
        }
        let placesURLString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?keyword=restaurants&location=\(manager.location?.coordinate.latitude.description ?? "")%2C\(manager.location?.coordinate.longitude.description ?? "")&radius=1500&type=restaurant&key=\(apiKey)"
        print(placesURLString)
        if let placesURL = URL(string: placesURLString) {
            let request = URLRequest(url: placesURL)
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let data = data else {
                    print("data is empty \(error?.localizedDescription ?? "")")
                    return
                }
                let jsonString = String(data: data, encoding: .utf8)
                print(jsonString)
                do {
                    let nearbyQueryResult = try JSONDecoder().decode(NearbyQueryResult.self, from: data)
                        //                    if let nearbyResults = nearbyQueryResult {
                    self?.placeResultPins(nearbyResults: nearbyQueryResult)
                        //                    }
                } catch let error as NSError {
                    print("decode error \(error.localizedDescription)")
                    print(String(describing: error))
                }
            }.resume()
        }
    }

    func placeResultPins(nearbyResults: NearbyQueryResult) {
        var restaurants: [Restaurant] = []
        nearbyResults.results.forEach { result in
            let newRestaurant = Restaurant(name: result.name, coordinate: CLLocationCoordinate2D(latitude: result.geometry.location.lat, longitude: result.geometry.location.lng), info: result.businessStatus)
            restaurants.append(newRestaurant)
        }

        if restaurants.count > 0 {
            mapView.addAnnotations(restaurants)
        }
    }

        // MARK: - CLLocationManagerDelegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            case .authorizedWhenInUse,.authorizedAlways:
                print("you got it, dude")
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

