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

class ViewController: UIViewController {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "Pick location"
        label.backgroundColor = .green
        return label
    }()
    
    let mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUpLayout()
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
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.bottom.equalTo(view.layoutMarginsGuide)
        }
    }
}
