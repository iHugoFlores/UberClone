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

class ViewController: UIViewController {
    
    private var locationManager: CLLocationManager
    
    let regionInMeters: Double = 10_00
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "Pick location"
        label.backgroundColor = .green
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
    
    func setUpMap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onMapTapped(gestureRecognizer:)))
        mapView.addGestureRecognizer(tapGesture)
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
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
        guard let location = locationManager.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    @objc func onMapTapped(gestureRecognizer: UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: mapView)
        let coordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        
        let wayAnnotation = MKPointAnnotation()
        wayAnnotation.coordinate = coordinates
        wayAnnotation.title = "waypoint"
        mapView.addAnnotation(wayAnnotation)
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
