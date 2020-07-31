//
//  ViewController.swift
//  UberClone
//
//  Created by Hugo Flores Perez on 7/27/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import UIKit
import MapKit
import SnapKit
import CoreLocation

struct LocationData {
    let streetNumber: String
    let streetName: String
}

class ViewController: UIViewController {
    
    private let locationManager: CLLocationManager
    private let geoCoder = CLGeocoder()
    private let destinationMarker = MKPointAnnotation()
    
    let regionInMeters: Double = 1_000
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "Pick location"
        return label
    }()
    
    private let startingLocationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "From:"
        return label
    }()
    
    private let destinationLocationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "To:"
        return label
    }()
    
    private let mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    init() {
        locationManager = CLLocationManager()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUpLayout()
        checkLocationServices()
    }
    
    func setUpLayout() {
        setUpTitle()
        setUpLocationLabels()
        setUpMap()
    }
    
    func setUpTitle() {
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.layoutMarginsGuide)
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
        }
    }
    
    func setUpLocationLabels() {
        view.addSubview(startingLocationLabel)
        view.addSubview(destinationLocationLabel)
        startingLocationLabel.snp.makeConstraints { make in
            make.leading.equalTo(view)
            make.top.equalTo(titleLabel.snp.bottom)
            make.trailing.equalTo(view.snp.centerX)
        }
        destinationLocationLabel.snp.makeConstraints { make in
            make.leading.equalTo(startingLocationLabel.snp.trailing)
            make.top.equalTo(titleLabel.snp.bottom)
            make.trailing.equalTo(view)
        }
    }
    
    func setUpMap() {
        mapView.addAnnotation(destinationMarker)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onMapTapped(gestureRecognizer:)))
        mapView.addGestureRecognizer(tapGesture)
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.top.equalTo(startingLocationLabel.snp.bottom)
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.bottom.equalTo(view.layoutMarginsGuide)
        }
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setUpLocationManager()
            checkLocationAuthorization()
        } else {
            // Show alert inidcating user that location is needed
        }
    }
    
    func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            //locationManager.startUpdatingLocation()
            break
        case .denied:
            // Show alert instructing user how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
        case .restricted:
            // Show alert displaying restricted status
            break
        default:
            // Default for additional cases
            break
        }
    }
    
    func centerViewOnUserLocation() {
        guard let location = locationManager.location else { return }
        let coordinates = location.coordinate
        let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
        getGeocodeLication(for: location) { (locationData) in
            DispatchQueue.main.async { [weak self] in
                self?.startingLocationLabel.text = "From: \(locationData.streetNumber) \(locationData.streetName)"
            }
        }
    }
    
    func getGeocodeLication(for coordinates: CLLocation, handler: @escaping (LocationData) -> Void) {
        geoCoder.reverseGeocodeLocation(coordinates) { (placemarks, error) in
            if let error = error {
                // Show error alert
                return
            }
            
            guard let placemark = placemarks?.first else {
                // Alert for no placemarks returned?
                return
            }
            
            let streetNumber = placemark.subThoroughfare ?? ""
            let streenName = placemark.thoroughfare ?? ""
            let locationData = LocationData(streetNumber: streetNumber, streetName: streenName)
            handler(locationData)
        }
    }
    
    @objc func onMapTapped(gestureRecognizer: UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: mapView)
        let coordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        destinationMarker.coordinate = coordinates
        getGeocodeLication(for: location) { (locationData) in
            DispatchQueue.main.async { [weak self] in
                self?.destinationLocationLabel.text = "To: \(locationData.streetNumber) \(locationData.streetName)"
            }
        }
        
//        let wayAnnotation = MKPointAnnotation()
//        wayAnnotation.coordinate = coordinates
//        mapView.addAnnotation(wayAnnotation)
    }
    
    
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }
        let center = CLLocationCoordinate2D(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude)
        let regon = MKCoordinateRegion(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(regon, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}
