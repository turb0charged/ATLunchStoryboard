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

class ViewController: UIViewController, CLLocationManagerDelegate, UISearchResultsUpdating, MKMapViewDelegate {

    private var locationManager: CLLocationManager?

    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        return mapView
    }()

    private let tableViewButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
        button.setTitle("List", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
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
        view.backgroundColor = .white
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()

        view.addSubview(mapView)
        mapView.delegate = self
        mapView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.right.left.bottom.equalToSuperview()
        }

        mapView.addSubview(tableViewButton)
        tableViewButton.snp.makeConstraints { make in
            make.bottom.equalTo(mapView.snp.bottom).inset(52)
            make.centerX.equalTo(mapView.snp.centerX)
            make.height.equalTo(46)
            make.width.equalTo(mapView.snp.width).dividedBy(5)
        }

        tableViewButton.addTarget(self, action: #selector(tappedTableViewButton), for: .touchUpInside)

        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Type something here to search"
        navigationItem.searchController = search

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

        if let placesURL = URL(string: placesURLString) {
            let request = URLRequest(url: placesURL)
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let data = data else {
                    print("data is empty \(error?.localizedDescription ?? "")")
                    return
                }
                let jsonString = String(data: data, encoding: .utf8)
                do {
                    let nearbyQueryResult = try JSONDecoder().decode(NearbyQueryResult.self, from: data)
                    DispatchQueue.main.async {
                        self?.placeResultPins(nearbyResults: nearbyQueryResult)
                    }
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
            let newRestaurant = Restaurant(title: result.name,
                                           coordinate: CLLocationCoordinate2D(latitude: result.geometry.location.lat, longitude: result.geometry.location.lng),
                                           info: result.businessStatus,
                                           rating: result.rating,
                                           userRatingsTotal: result.userRatingsTotal,
                                           priceLevel: result.priceLevel,
                                           photoReference: result.photos?.first?.photoReference)
            restaurants.append(newRestaurant)
        }

        if restaurants.count > 0 {
            mapView.addAnnotations(restaurants)
        }
    }

        // MARK: - Actions
    @objc func tappedTableViewButton() {
        print("got to list view")
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

        // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is Restaurant else {
            return nil
        }
        let identifier = "Restaurant"


        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.clusteringIdentifier = identifier
        } else {
            annotationView?.annotation = annotation
        }

        annotationView?.canShowCallout = true
        let detailView = RestaurantCalloutView(annotation: annotation)
        detailView.snp.makeConstraints { make in
            make.width.equalTo(UIScreen.main.bounds.width * 0.70)
            make.height.equalTo(UIScreen.main.bounds.height * 0.10)
        }
        annotationView?.detailCalloutAccessoryView = detailView
//        let leftAccesoryView = UIImageView(image: UIImage(systemName: "fork.knife.circle.fill")!)
//        annotationView?.leftCalloutAccessoryView = leftAccesoryView

        return annotationView
    }

        // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        print(text)
    }
}

