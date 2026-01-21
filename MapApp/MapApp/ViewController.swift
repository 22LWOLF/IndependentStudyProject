//
//  ViewController.swift
//  MapApp
//
//  Created by Wolf,Luke D on 1/16/26.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    private var selectedCoordinates: [CLLocationCoordinate2D] = []
    
    @objc func handleMapTap(_ gesture: UITapGestureRecognizer){
        //gets the tap location in the view (screen pixels)
        //EX: tap found at 100 pixels from the top of screen and 300 pixels from right of screen.
        let locationInView = gesture.location(in: mapView)
        
        //convert the taps into coordinates (lat/long)
        //it basicall takes the tap location in pixels and then converts that into the lat/long for the map.
        let coordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
        
        //checks too see if there are already 2 points. if so then delete all the annotations and saved coords.
        if selectedCoordinates.count >= 2{
            //removes coordinates (lat and long)
            selectedCoordinates.removeAll()
            
            //need to remove any previous annotations on the map
            removeAnnotations()
            
            //testing to see if coords and annotations are being removed.
            print("removed previous 2 coords + annotations")
            
        }
        
        //TEST TO SEE IF WORKS JUST PRINT FOR NOW
        print("Tapped at: \(coordinate.latitude), \(coordinate.longitude)")
        
        // store the coordinates in my array
        selectedCoordinates.append(coordinate)
        
        //alters the title of the coordinate depending if it is the 1st or 2nd annotation
        let label = (selectedCoordinates.count == 1) ? "Start" : "Stop"
        //adds annotation to the map with the coensiding name
        addAnnotation(at: coordinate, title: label)

    }
    
    //function for removing all the annotations on the map
    func removeAnnotations(){
        mapView.removeAnnotations(mapView.annotations)
    }
    
    //function for adding a new annotation on the map
    func addAnnotation(at coordinate: CLLocationCoordinate2D, title: String? = nil) {
        //lets thing called "annotation" to be a MKPointAnnotation object.
        let annotation = MKPointAnnotation()
        //allows for annotation to have a coordinate
        annotation.coordinate = coordinate
        //allows for the annotation to have a title
        annotation.title = title
        //adding the annotation to the mapview
        mapView.addAnnotation(annotation)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        //EX Cords Milan MO (1st value + is North - is South, 2nd value + is East - is West)
        let cordinates = CLLocationCoordinate2D(latitude: 40.2022, longitude: -93.1252)
        //Region is the displayed area on launch of the specified coordinates. (This is a 10 kilometers x 10 kilometers)
        let region = MKCoordinateRegion(center: cordinates, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true)
        
        //listening for when the "tap" event happens on the mapView
        //when it detects a tap it calls handleMapTap method
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
    }
    
}



