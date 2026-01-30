//
//  ViewController.swift
//  MapApp
//
//  Created by Wolf,Luke D on 1/16/26.
//

import UIKit
import MapKit
import CoreLocation

// MARK: - RouteAnnotation
class RouteAnnotation: MKPointAnnotation {
    // 0 for Start, 1 for Stop
    var index: Int = 0
}

// MARK: - StyledPolyline
class StyledPolyline: MKPolyline {
    // Switch for if a polyline is forward or backward (default is foward)
    enum Kind { case forward, backward }
    var kind: Kind = .forward
}

class ViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Outlets
    // White box at top of screen for UI
    @IBOutlet weak var headerBox: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var routeInfoLabel: UILabel!
    
    // MARK: - Properties
    private var selectedCoordinates: [CLLocationCoordinate2D] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        // EX Cords Milan MO (1st value + is North - is South, 2nd value + is East - is West)
        let cordinates = CLLocationCoordinate2D(latitude: 40.2022, longitude: -93.1252)
        // Region is the displayed area on launch of the specified coordinates. (This is a 10 kilometers x 10 kilometers)
        let region = MKCoordinateRegion(center: cordinates, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true)
        
        // listening for when the "tap" event happens on the mapView
        // when it detects a tap it calls handleMapTap method
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // round only the bottom corners
        headerBox.layer.cornerRadius = 44
        headerBox.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerBox.layer.masksToBounds = true
    }
    
    // MARK: - User Actions (IBActions)
    @IBAction func showCoordinateEntry(_ sender: Any) {
        showCoordinateEntry()
    }
    
    @IBAction func generateRouteBTN(_ sender: UIButton) {
        guard selectedCoordinates.count == 2 else {
            showInfoAlert(message: "Please place 2 pins")
            return
        }
        // Check which segement is selected
        let selectedIndex = routeTypeSelector.selectedSegmentIndex
        
        switch selectedIndex {
        case 0: // One-way
            generateRoute(from: selectedCoordinates[0], to: selectedCoordinates[1])
        case 1: // Out-and-back
            generateOutAndBackRoute(from: selectedCoordinates[0], to: selectedCoordinates[1])
        case 2: //loop
            //for now just print alert cause I don't got the code
            showInfoAlert(message: "loop route is not implemented yet")
        default:
            break
        }

    }
    
    @IBAction func clearRouteBTN(_ sender: UIButton) {
        selectedCoordinates.removeAll()
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
    }
    
    // User selects the route type
    @IBOutlet weak var routeTypeSelector: UISegmentedControl!
    
    // MARK: - Coordinate Entry UI
    @objc func showCoordinateEntry() {
        // creating the actual alert popup
        let alert = UIAlertController(title: "Enter Coordinates", message: "Enter Latitude and longitude (-90 to 90, -180 to 180)", preferredStyle: .alert)
        
        // adding lat textfield
        alert.addTextField { textField in
            textField.placeholder = "Latitude (-90 to 90)"
            textField.keyboardType = .numbersAndPunctuation
        }
        // adding long textfield
        alert.addTextField { textField in
            textField.placeholder = "Longitude (-180 to 180)"
            textField.keyboardType = .numbersAndPunctuation
        }
        
        // creating the Go action
        // Creating a button + all the code that happens when its pressed in one statement.
        // UIAlertAction is creating a button for the alert
        // title: "Go" is the buttons label
        // style: .default is how it looks (.cancel for bold, .destructive for red.)
        // {action in...} is the code that runs when the button is tapped
        let goAction = UIAlertAction(title: "Go", style: .default) { action in
            // this stuff runs when the user taps Go
            
            // looking at textfields to make sure it is not empty
            guard let latText = alert.textFields?[0].text, !latText.isEmpty else {
                self.showErrorAlert(message: "No latitude entered")
                return
            }
            guard let longText = alert.textFields?[1].text, !longText.isEmpty else {
                self.showErrorAlert(message: "No longitude entered")
                return
            }
            
            // taking string from textfield's and converting to double if it isn't a value then it will give error
            guard let lat = Double(latText) else {
                self.showErrorAlert(message: "Latitude is not a valid number")
                return
            }
            guard let long = Double(longText) else {
                self.showErrorAlert(message: "Longitude is not a valid number")
                return
            }
            
            // checking the now double values to ensure that they fall within range possible for lat and long.
            guard lat >= -90.0, lat <= 90.0 else {
                self.showErrorAlert(message: "Latitude out of range (-90 to 90)")
                return
            }
            guard long >= -180.0, long <= 180.0 else {
                self.showErrorAlert(message: "Longitude out of range (-180 to 180)")
                return
            }
            
            // Use the coordinates: drop a pin and center the map
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            // display area around pin
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
            
            // move to pinned area
            self.mapView.setRegion(region, animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.showInfoAlert(message: "Cancelled location entry")
            // don't need canceling code because when an action is called by default it will dismiss the alert.
        }
        
        alert.addAction(cancelAction)
        alert.addAction(goAction)
        
        // show alert on screen
        present(alert, animated: true)
    }
    
    // MARK: - Gesture Handling
    @objc func handleMapTap(_ gesture: UITapGestureRecognizer) {
        // gets the tap location in the view (screen pixels)
        // EX: tap found at 100 pixels from the top of screen and 300 pixels from right of screen.
        let locationInView = gesture.location(in: mapView)
        
        // convert the taps into coordinates (lat/long)
        // it basicall takes the tap location in pixels and then converts that into the lat/long for the map.
        let coordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
        
        // checks too see if there are already 2 points. if so then delete all the annotations and saved coords.
        if selectedCoordinates.count >= 2 {
            // removes coordinates (lat and long)
            selectedCoordinates.removeAll()
            
            // need to remove any previous annotations on the map
            removeAnnotations()
            
            mapView.removeOverlays(mapView.overlays)
            
            // testing to see if coords and annotations are being removed.
            print("Removed previous 2 pins, annotations, and old route")
        }
        
        // TEST TO SEE IF WORKS JUST PRINT FOR NOW
        print("Tapped Lat: \(coordinate.latitude), Lon: \(coordinate.longitude)")
        
        // store the coordinates in my array
        selectedCoordinates.append(coordinate)
        
        // alters the title of the coordinate depending if it is the 1st or 2nd annotation
        let label = (selectedCoordinates.count == 1) ? "Start" : "Stop"
        // adds annotation to the map with the coensiding name
        addAnnotation(at: coordinate, title: label)
    }
    
    // MARK: - Map Annotation Helpers
    // Remove all annotations from the map
    func removeAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
    }
    
    // Add a single annotation to the map with an optional title
    func addAnnotation(at coordinate: CLLocationCoordinate2D, title: String? = nil) {
        let annotation = RouteAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        if let title = title {
            annotation.index = (title == "Start") ? 0 : 1
        }
        mapView.addAnnotation(annotation)
    }
    
    // MARK: - Alert Helpers
    // Centralized helpers for presenting feedback to the user.
    // Use these instead of print for user-facing messages.
    // This is for giving information to the user EX: "please place 2 pins"
    func showInfoAlert(title: String = "Info", message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    // Specifically for error alerts EX: when using Go To "plese enter a longitude"
    func showErrorAlert(title: String = "Error", message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .destructive))
            self.present(alert, animated: true)
        }
    }
    
    // Specifically for conformations
    func showConfirmationAlert(
        title: String,
        message: String,
        confirmTitle: String = "OK",
        cancelTitle: String = "Cancel",
        onConfirm: @escaping () -> Void
    ) {
        // This is to schedule the conformation alert using the main thread as soon as it finds an opening. Makes sure stuff runs correctly and doesn't cause a crash.
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let confirm = UIAlertAction(title: confirmTitle, style: .default) { _ in onConfirm() }
            let cancel = UIAlertAction(title: cancelTitle, style: .cancel)
            alert.addAction(cancel)
            alert.addAction(confirm)
            self.present(alert, animated: true)
        }
    }
    
    // MARK: - Route Generation Helpers
    
    // Function for converting route data (time, distance, etc.)
    func updateRouteInfoLabel(distance: CLLocationDistance, time: TimeInterval) {
        // Turns distance given (meters) into miles
        let distanceMiles = distance/1609.34
        // Turns time given (seconds) into minutes
        let timeMinutes = time/60.0
        // The format and string that will be displayed with the given info.
        let infoText = String(format: "%.2f miles • ~%.0f min", distanceMiles, timeMinutes)
        // Displays info from before on the routeInfoLabel at top middle of screen.
        routeInfoLabel.text = infoText
    }
    
    // MARK: - Route Generation
    
    // Route type cases
    enum RouteType{
        case oneWay
        case outAndBack
        case loop
    }
    
    
    // For getting poly line coordinates (how the route is specifically laid out.
    func getCoordinates(from polyline: MKPolyline) -> [CLLocationCoordinate2D]{
        // Grabs all the points that make up the polyline
        let points = polyline.points()
        // Counts all the points used in the polyline
        let pointCount = polyline.pointCount
        
        var coordinates: [CLLocationCoordinate2D] = []
        // For points 0 to pointCount-1 store the coords
        for i in 0..<pointCount {
            let point = points[i]
            coordinates.append(point.coordinate)
        }
        return coordinates
    }
    
    // This will be the function called when out-and-back route type is selected and a route is generated.
    func generateOutAndBackRoute(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) {
        mapView.removeOverlays(mapView.overlays)
        
        let source = MKMapItem(location: CLLocation(latitude: start.latitude, longitude: start.longitude), address: nil)
        let destination = MKMapItem(location: CLLocation(latitude: end.latitude, longitude: end.longitude), address: nil)
        
        let request = MKDirections.Request()
        request.source = source
        request.destination = destination
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [weak self] response, error in
            if let error = error {
                self?.showErrorAlert(message: "Error calculating route: \(error.localizedDescription)")
                return
            }
            
            guard let route = response?.routes.first else { return }
            
            // DOUBLED for out-and-back
            let totalDistance = route.distance * 2
            let totalTime = route.expectedTravelTime * 2
            self?.updateRouteInfoLabel(distance: totalDistance, time: totalTime)
            
            // Add forward route
            self?.mapView.addOverlay(route.polyline)
            
            // Get coordinates and reverse them
            let forwardCoords = self?.getCoordinates(from: route.polyline)
            let backwardCoords = forwardCoords?.reversed()
            
            // Create backward polyline with custom style marker
            if let backwardCoords = backwardCoords {
                let backwardArray = Array(backwardCoords)
                let backwardPolyline = StyledPolyline(coordinates: backwardArray, count: backwardArray.count)
                backwardPolyline.kind = .backward
                self?.mapView.addOverlay(backwardPolyline)
            }
        }
    }
    
    // MARK: - Loop Helper Functions
    
    func generateRandomCoordinate(around center: CLLocationCoordinate2D, radius: Double) -> CLLocationCoordinate2D {
        // Purpose: Generate a random coordinate within a radius of a center point (potentially within a set angle)
        //Inputs:
            // center: CLLocationCoordinate2D (starting point)
                // Eventually defualt will be user location
            // radius: Double (max distance in meters)
        
        // Output:
            // CLLocationCoordinate2D (random point)
        
        // Algo:
            // Generate random angle: 0 to 360 degrees (maybe change to set at bottom for more info) convert to radians
            // Generate random distance: 0.5 * radius to radius
            // Convert angle + distance to latitude/longitude offset
            // Apply offset to center coordinate
            // Return new coord.
        
        // Reference:
            //Earth radius ≈ 6371000 meters
            //Latitude offset = (distance * cos(angle)) / (Earth radius * π/180)
            //Longitude offset = (distance * sin(angle)) / (Earth radius * π/180 * cos(centerLat))
        return CLLocationCoordinate2D()
    }
    
    
    
    // This will be the function called when loop route type is selected and route is generated.
    // WIP
    func loopRoute () {
        /* Pseduocode:
        // Setup:
            // Calculate radius from desired distance: r = distance/(2pi)
                // for now that value will just be inserted in code
            // Generate N random waypoints around the start
                // this will also just be in code
        // Waypoint Generation:
            // Generate a semi-random angle within guide lines for cardnial direction choosen (further detail at bottom)
            // Generate a random distance from 0.5r to r
            // Calculate the coordinate using trig
            // Maybe validate that points aren't too close to other points.
        // Route segement generation:
            // Generate a route: Start (defualt should be user location when that is implemented) -> Waypoint 1
            // Wait for completion
            // Generate route: Waypoint 1 -> Waypoint 2
            // Wait again
            // Generate route: Waypoint 2 -> start
            // Wait again
            // This amount will change depending on the amount of points the user wants.
        // Validation:
            // Sum all segment distances (if user put in time instead of distance convert sum into distance)
            // Check if total is within +10% of target
                // Subject to change since this needs like real world testing
            // If not, retry with new waypoints.
            // Only allow for up to X retries
                // Same as target forgiveness will need to be tested to get a proper #.
            //Display:
                // Add all route segements as overlays
                // use different colors for each segement
                    // Mostly for testing but can also be used later for setting tempos (walk, jog, run)
                // Update info label with total distance and estimated time
        // Issues/Challenges:
            // Need asych route generation (sequential chaining)
            // Random waypoints may land in unreachable locations (middle of a forest, water, etc.)
            // Need retry logic for failed route segments
                // Note this is different then retrying the ENTIRE route just a specific segement.
            // Distance accuracy depends on waypoint placement.'
         */
            
    }
    
    // Generate a route between two coordinates and draw it on the map
    // taking 2 points (starting and ending) coordinates (lat/long)
    func generateRoute(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) {
        // Clear existing overlays before drawing a new route
        mapView.removeOverlays(mapView.overlays)
        
        // Routing doesn't work based off of coordinates it needs Map Item's. So this wraps the 1st and 2nd points in a MKMapItem (they are still coordinates but they are puttin on a disguise to become Map Item's)
        // address is nil because we aren't giving a specific street address just a location
        let source = MKMapItem(location: CLLocation(latitude: start.latitude, longitude: start.longitude), address: nil)
        let destination = MKMapItem(location: CLLocation(latitude: end.latitude, longitude: end.longitude), address: nil)
        
        // This is creating a directions request which in simple terms is saying "Apple give me directoins from here to here"
        // First part is creating an empty request object (getting the form to fill out
        let request = MKDirections.Request()
        // this is filling out the form to say start at the map item named "source"
        request.source = source
        // This is filling out the form to say ending at the map item named "destination"
        request.destination = destination
        // This is just what type of route it will make
        request.transportType = .walking
        
        // Create a directions calculator object and give it the form.
        // This is the thing that is talking to apple servers to get the info.
        let directions = MKDirections(request: request)
        
        // Go calculate route and when your done/or if something breaks, run this code
        // This is ansynchronous so that the app doesn't freeze up while waiting for directions
        directions.calculate { [weak self] response, error in
            // if an error happens (no internet, middle of the ocean, etc.) it will cause an error and allow them to retry.
            if let error = error {
                self?.showErrorAlert(message: "Error calculating route: \(error.localizedDescription)")
                return
            }
            // Apple might multiple route options this is saying grab the first or if there are none then stop.
            // Currently this is just taking the fastest route can change to "scenic" and other stuff as well.
            guard let route = response?.routes.first else { return }
            
            self?.updateRouteInfoLabel(distance: route.distance, time: route.expectedTravelTime)
            // This is the part where the routes polyline is being pasted over the top of the map.
            self?.mapView.addOverlay(route.polyline)
            
            self?.getCoordinates(from: route.polyline)
            
        }
    }
    
    // MARK: - MKMapViewDelegate
    // MKMapViewDelegate method to render the route polyline
    // The return type MKOverlayRenderer is giving back an object that knows how to draw the overlay
    // as? means try to convert this syledPolyline but it might fail.
    // if let means that if that conversion worked then do this code.
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let styled = overlay as? StyledPolyline {
            let renderer = MKPolylineRenderer(polyline: styled)
            switch styled.kind {
            case .forward:
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 5
            case .backward:
                renderer.strokeColor = .systemRed
                renderer.lineWidth = 3
                renderer.lineDashPattern = [2,5]
            }
            return renderer
        }

        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 5
            return renderer
        }

        return MKOverlayRenderer(overlay: overlay)
    }
    
    // MARK: - MKMapViewDelegate (Annotation Views)
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't customize user location annotation
        if annotation is MKUserLocation { return nil }
        
        let identifier = "PinAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        // "settings" for the markers
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            // This line is to enable dragging around
            annotationView?.isDraggable = true
            // If pin is tapped it will display the title of the pin
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        //makes grabbable area bigger
        annotationView?.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        return annotationView
    }
    
    // For when pins are being dragged around
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        // This is watching for when dragging has stopped or ended (meaning it is done being moved).
        if newState == .ending || newState == .canceling {
            view.dragState = .none
            // When stopped moving this grabs the new coordinates and sets that new position to its new coords.
            guard let movedAnnotation = view.annotation as? RouteAnnotation else { return }
            let newCoordinate = movedAnnotation.coordinate
            
            // Update selectedCoordinates based on annotation index
            // This is to ensure that even when a start or stop pin is being moved around that the new coordinates are assigned to the correct pin.
            // For example I have start and stop. I move start pin around, and then let go. This ensures, even thought start was first pin placed, that start is the one getting assigned the coordinates and not the latest placed pin.
            if movedAnnotation.index == 0 {
                if selectedCoordinates.count >= 1 { selectedCoordinates[0] = newCoordinate }
                else { selectedCoordinates.append(newCoordinate) }
            } else if movedAnnotation.index == 1 {
                if selectedCoordinates.count >= 2 { selectedCoordinates[1] = newCoordinate }
                else if selectedCoordinates.count == 1 { selectedCoordinates.append(newCoordinate) }
                else {
                    // If somehow stop moved before start exists, insert placeholders
                    selectedCoordinates = [newCoordinate]
                }
            }
            
            // Automatically regenerate route if we have both points
            // Potentially remove this, not sure yet
            if selectedCoordinates.count == 2 {
                // Check which segement is selected
                let selectedIndex = routeTypeSelector.selectedSegmentIndex
                
                switch selectedIndex {
                case 0: // One-way
                    generateRoute(from: selectedCoordinates[0], to: selectedCoordinates[1])
                case 1: // Out-and-back
                    generateOutAndBackRoute(from: selectedCoordinates[0], to: selectedCoordinates[1])
                case 2: //loop
                    //for now just print alert cause I don't got the code
                    showInfoAlert(message: "loop route is not implemented yet")
                default:
                    break
                }
            }
        }
    }
}

// MARK: - Ideas / Notes
/*
 Possible solution for making loops is do same logic as out and back but use alternate route type like scenic or those other types, but I also need to keep in mind how i'm going to randomly generate a route with multiple points.
 For battery usage use kcLLocationAccuracyBestForNaviagation and also set appropriate distance filters to make sure that the GPS isn't having to update every 1 inch you move. Use locationManager.activityType = .fitness this optimizes phone for fitness and stuff. Ensure that location updates are paused when the user is not moving (stops unnessarcy work)
 Instead of having a button to start a route have it to where the user holds down with like a shaking then like realse feeling. (ssshhhhhhhwwwwwwwwooop). This clears up UI and also gives a cool little gimic feeling. Probably still have a cancel route button though.
 For random loop generation let the user select a cardinal direction to head in (4 90 degree angles). EX: North would be from 315 degrees - 45 degrees. East would be from 45 to 135. Etc.
 Progress traker for route
 Warnings for user to swtich speeds.
 
 
 Pseduo code thoughts:
 different ways for random routes:
 given the inputted time/distance make a route then measure it to see if it falls within the bounds if not make another route, rinse and repeat.
 Pros: simple to implement take a random lat and long within blank distance from the user make a point then make a route.
 Cons: Could be super intensive because it could take theoretically millions of tries, could drain phone super fast.
 
 Okay talked with chatGPT it gave me a solution to try:
 take the users time or distance (if they choose time then convet that to distance using their personal values. Then do formula of r = distance/(2pi) to get an approximate radius around your starting position. Then generate x random points within that radius then add the distance together then see if that value is within a certain range of the user given distance/converted time. After X times of generation keep the best attempt (even if it is still slightly outside the "required" value).
 Cont. on random route generation stuff:
 if/when a user is making a route and a point ends up in a location that is not possible to reach (middle of a lake, field, etc.) instead of scrapping the entire route go back a step and remake the new pin.
 EX: A -> B works, B -> C (lake), B -> C2 (good), C2 -> A
 Also implement a system for maximum tries for legs and entire route generation. (so if B -> C doesn't work after 5 tries then scrap the entire route similar to route retry's as mentioned above). Also for retrying a point I can move it a couple hundred meters in a couple directions to see if something lands close enought to a road.
 
 
 
 
 Issues:
 If the user uses "Go To" button before making a route you cannot generate a route after that. SOLVED
 Need to have a way to place pins then generate a route, not just autocompleteing when 2 pins are placed. SOLVED
 Switch print statements too UIAlertController that way you don't need a console open. SOLVED
Make dragging pins eaiser. Can be difficult to grab them and also doesn't feel "nice" or smooth if feels kinda clunky. Specifically it can be hard to grab them. Sometimes you think you grab a pin but instead it just starts a new route. SOLVED
        Possible solution: Make UI area for pin bigger.
Also after moving a pin/pins instead of auto generating a route only make the route after the generate route button is clicked. Meaning 2 pins no route drag around a pin place it still no route. Generate route, then select a pin to drag and then drop the route is automatically generated. Almost like a toggle that when swithced off doesn't allow for routes to be made, then once the switch is flipped then it will automatically make routes. SOLVED
Have location finder have - symbol for negative coords. SOLVED
When using out and back (currently just automatic after generating route with button) if you drag a pin it doesn't display the B->A line (pretty simple fix I think). SOLVED
 
 
 Questions for Claude:
 
    In your pseduocode for loop generation you provided me, in the Waypoint generation section why does it matter to ensure that one point isn't too close to another point? I already added some stuff like instead of completely random the user CAN select a cardinal direction to skew towards but a random route is a random route. Wanted to know your reasoning for that.
 
*/



