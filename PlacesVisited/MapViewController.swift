//
//  CustomTabBarController2.swift
//  PlacesVisited
//
//  Created by Guillermo Diaz on 6/6/17.
//  Copyright © 2017 Guillermo Diaz. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    let mapView: MKMapView = {
        let mv = MKMapView()
        return mv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        view.addSubview(mapView)
        
        mapView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    func handleTabButtonPress() {
        
    }
    
    func handleMiddleButtonClick() {
        print(123)
    }
}
