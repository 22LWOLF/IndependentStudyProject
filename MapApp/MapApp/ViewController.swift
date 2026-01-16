//
//  ViewController.swift
//  MapApp
//
//  Created by Wolf,Luke D on 1/16/26.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    //need to display a map of a designated size and a designated Longitude and Latitude.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //EX Cords Kansas City
        let cordinates = CLLocationCoordinate2D(latitude: 39.0522, longitude: -94.0553)
        let region = MKCoordinateRegion(center: cordinates, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true)
        
    }


}

