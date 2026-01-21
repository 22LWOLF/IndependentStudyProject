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
        
        //will generate a route inbetween the 2 points
        if selectedCoordinates.count == 2{
            generateRoute(from: selectedCoordinates[0], to: selectedCoordinates[1])
            
            print("generated a route")
            
        }
    }
    
    // Remove all annotations from the map
    func removeAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
    }

    // Add a single annotation to the map with an optional title
    func addAnnotation(at coordinate: CLLocationCoordinate2D, title: String? = nil) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        mapView.addAnnotation(annotation)
    }

    // Generate a route between two coordinates and draw it on the map
    func generateRoute(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) {
        // Clear existing overlays before drawing a new route
        mapView.removeOverlays(mapView.overlays)

        // Build MKMapItems for routing using coordinate-based placemarks
        let source = MKMapItem(placemark: MKPlacemark(coordinate: start, addressDictionary: nil))
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: end, addressDictionary: nil))

        var request = MKDirections.Request()
        request.source = source
        request.destination = destination
        request.transportType = .walking

        let directions = MKDirections(request: request)
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let response = try await directions.calculate()
                if let route = response.routes.first {
                    self.mapView.addOverlay(route.polyline)
                } else {
                    print("No routes found")
                }
            } catch {
                print("Directions error: \(error.localizedDescription)")
            }
        }
    }

    // MKMapViewDelegate method to render the route polyline
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = .systemBlue
        renderer.lineWidth = 5
        return renderer
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
    
    @IBAction func generateButtonTapped(_ sender: UIButton) {
        guard selectedCoordinates.count == 2 else {
            print("Need exactly two points to generate a route")
            return
        }
        let start = selectedCoordinates[0]
        let end = selectedCoordinates[1]
        generateRoute(from: start, to: end)
    }
    
}

