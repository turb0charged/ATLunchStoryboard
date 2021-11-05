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

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate {

    private var locationManager: CLLocationManager?

    private let containerView: UIView = {
        let view = UIView()
        return view
    }()

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

    private var restaurants: [Restaurant] = []

    override func viewDidLoad() {
        super.viewDidLoad()
            // Do any additional setup after loading the view.
        self.navigationItem.title = "AT Lunch"
        view.backgroundColor = .white
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()

        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }

        containerView.addSubview(mapView)
        mapView.delegate = self
        mapView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.right.left.bottom.equalToSuperview()
        }

        containerView.addSubview(tableViewButton)
        tableViewButton.snp.makeConstraints { make in
            make.bottom.equalTo(mapView.snp.bottom).inset(52)
            make.centerX.equalTo(mapView.snp.centerX)
            make.height.equalTo(46)
            make.width.equalTo(mapView.snp.width).dividedBy(5)
        }

        tableViewButton.addTarget(self, action: #selector(tappedTableViewButton), for: .touchUpInside)

        let searchTextField: UISearchTextField = UISearchTextField(frame: CGRect(x: 0, y: 0, width: (self.navigationController?.navigationBar.frame.size.width)!, height: 21.0))
        searchTextField.delegate = self
        navigationItem.titleView = searchTextField

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
        let placesURLString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?keyword=restaurants&location=\(manager.location?.coordinate.latitude.description ?? "")%2C\(manager.location?.coordinate.longitude.description ?? "")&radius=1500&type=restaurant&key=\(GooglePlacesConstants.apiKey)"

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
        show(ResultsTableViewController(restaurants: restaurants), sender: self)
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

        let button = UIButton(type: .detailDisclosure)
        annotationView?.rightCalloutAccessoryView = button

        return annotationView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        show(RestaurantDetailViewController(restaurant: view.annotation as! Restaurant), sender: self)
    }

        // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let url = URL(string: GooglePlacesConstants.BaseURL + GooglePlacesConstants.Paths.TextSearch), let searchTerm = textField.text {
            let locationQuery = URLQueryItem(name: "location", value: "\(locationManager?.location?.coordinate.latitude),\(locationManager?.location?.coordinate.longitude)")
            let textQuery = URLQueryItem(name: "query", value: searchTerm)
            let keyQuery = URLQueryItem(name: "key", value: GooglePlacesConstants.apiKey)
            if let finalizedURL = url.appending([locationQuery,textQuery,keyQuery]){
                let request = URLRequest(url: finalizedURL)
                URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                    guard let data = data, let strongSelf = self else {
                        print("data is empty \(error?.localizedDescription ?? "")")
                        return
                    }
                    let jsonString = String(data: data, encoding: .utf8)
                    do {
                        let nearbyQueryResult = try JSONDecoder().decode(NearbyQueryResult.self, from: data)
                        DispatchQueue.main.async {
                            strongSelf.mapView.removeAnnotations(strongSelf.restaurants)
                            strongSelf.restaurants = []
                            strongSelf.placeResultPins(nearbyResults: nearbyQueryResult)
                        }
                    } catch let error as NSError {
                        print("decode error \(error.localizedDescription)")
                        print(String(describing: error))
                    }
                }.resume()
            }
        }
        textField.resignFirstResponder()
        return true
    }
}

