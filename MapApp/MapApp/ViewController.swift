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
    
    private var selectedCoordinates: [CLLocationCoordinate2D] = []
    private var currentRoute : MKRoute?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        //EX Cords Milan MO (1st value + is North - is South, 2nd value + is East - is West)
        let cordinates = CLLocationCoordinate2D(latitude: 40.2022, longitude: -93.1252)
        //Region is the displayed area on launch of the specified coordinates. (This is a 10 kilometers x 10 kilometers)
        let region = MKCoordinateRegion(center: cordinates, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
        mapView.addGestureRecognizer(tap)
        
        
    }
    
    @objc private func handleMapTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let point = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        selectedCoordinates.append(coordinate)
        
        //if route already exists and the user taps again this resets it for a new route
        if currentRoute != nil || selectedCoordinates.count > 2{
            resetRouteAnnotations()
        }
        
        //drop a pin
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = selectedCoordinates.count == 1 ? "Start" : "End"
        mapView.addAnnotation(annotation)
        
        //if you have 2 points request a route
        if selectedCoordinates.count == 2{
            requestRoute(from: selectedCoordinates[0], to: selectedCoordinates[1])
        }
        
        private func resetRouteAnnotations(){
            //This will clear the current state of the map and will add the new overlays/annotations
            //set selectedCoordinates[0] = nothing then populate it with the new tap information
            //then reset selectedCoordinates[1] to nothing
            
            //clear in-memory state
            selectedCoordinates.removeAll()
            currentRoute = nil
            
            //remove any existing route lines
            mapView.removeOverlays(mapView.overlays)
            
            //remove pins, but keep the user location if available
            let pinsToRemove = mapView.annotations.filter { !($0 is MKUserLocation) }
            mapView.removeAnnotations(pinsToRemove)
            
        }
        private func requestRoute(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D){
            // This will build the directions request bewteen the 2 points and draw them
        }

    

    }
}

