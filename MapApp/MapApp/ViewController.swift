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
            
            mapView.removeOverlays(mapView.overlays)
            
            //testing to see if coords and annotations are being removed.
            print("removed previous 2 coords + annotations + old route")
            
        }
        
        //TEST TO SEE IF WORKS JUST PRINT FOR NOW
        print("Tapped at: \(coordinate.latitude), \(coordinate.longitude)")
        
        // store the coordinates in my array
        selectedCoordinates.append(coordinate)
        
        //alters the title of the coordinate depending if it is the 1st or 2nd annotation
        let label = (selectedCoordinates.count == 1) ? "Start" : "Stop"
        //adds annotation to the map with the coensiding name
        addAnnotation(at: coordinate, title: label)
        
        //will generate a route inbetween the 2 points automatically
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
    //taking 2 points (starting and ending) coordinates (lat/long)
    func generateRoute(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) {
        // Clear existing overlays before drawing a new route
        mapView.removeOverlays(mapView.overlays)

        //Routing doesn't work based off of coordinates it needs Map Item's. So this wraps the 1st and 2nd points in a MKMapItem (they are still coordinates but they are puttin on a disguise to become Map Item's)
        //address is nil because we aren't giving a specific street address just a location
        let source = MKMapItem(location: CLLocation(latitude: start.latitude, longitude: start.longitude), address: nil)
        let destination = MKMapItem(location: CLLocation(latitude: end.latitude, longitude: end.longitude), address: nil)


        //This is creating a directions request which in simple terms is saying "Apple give me directoins from here to here"
        //First part is creating an empty request object (getting the form to fill out
        let request = MKDirections.Request()
        //this is filling out the form to say start at the map item named "source"
        request.source = source
        //This is filling out the form to say ending at the map item named "destination"
        request.destination = destination
        //This is just what type of route it will make
        request.transportType = .walking

        //Create a directions calculator object and give it the form.
        //This is the thing that is talking to apple servers to get the info.
        let directions = MKDirections(request: request)
        
        //Go calculate route and when your done/or if something breaks, run this code
        //This is ansynchronous so that the app doesn't freeze up while waiting for directions
        directions.calculate { [weak self] response, error in
                // if an error happens (no internet, middle of the ocean, etc.) it will cause an error and allow them to retry.
                if let error = error {
                    print("Error calculating route: \(error.localizedDescription)")
                    return
                }
                //Apple might multiple route options this is saying grab the first or if there are none then stop.
                //Currently this is just taking the fastest route can change to "scenic" and other stuff as well.
                guard let route = response?.routes.first else { return }
                //This is the part where the routes polyline is being pasted over the top of the map.
                self?.mapView.addOverlay(route.polyline)
            }
        }

    // MKMapViewDelegate method to render the route polyline
    //The return type MKOverlayRenderer is giving back an object that knows how to draw the overlay
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        //Check if this overlay is specifically a polyline or something else (there are differnt types like circles or polygon's) and just to draw it with default settings.
        //The purpose of this is in the future I might need to have other overlays like circles and this ensures that it doesn't interact with those only polylines.
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        //create the polyline drawer object (making the artist)
        let renderer = MKPolylineRenderer(polyline: polyline)
        //what color the artist should use to draw
        renderer.strokeColor = .systemBlue
        //how thick the pen should be when he draws
        renderer.lineWidth = 5
        //gives the configured drawer back to the map. (gives the picture the artist drew back to the map that requested it)
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
    
}

