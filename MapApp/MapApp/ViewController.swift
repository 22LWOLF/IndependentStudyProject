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
    
    // Identify which leg this polyline represents for styling
    var legIndex: Int = 0
    enum Mode { case fastest, scenic }
    var mode: Mode = .fastest
}

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {
    
    // MARK: - Outlets
    // White box at top of screen for UI
    @IBOutlet weak var headerBox: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var routeInfoLabel: UILabel!
    
    // MARK: - Properties
    private var selectedCoordinates: [CLLocationCoordinate2D] = []
    private var pinsLocked: Bool = false
    private var isGeneratingRoute: Bool = false
    
    // Temporary toggle until UI selector is wired up
    private var useScenicRouting: Bool = false
    
    // For getting user location
    private var locationManager: CLLocationManager!
    private var userLocation: CLLocationCoordinate2D?
    private var hasAlreadyCentered: Bool = false
    
    // Distance input field in the slide panel
    private var distanceTextField: UITextField?
    
    // actual panel
    var slidePanel: UIView!
    
    // tracks if the panel is open or closed
    var isPanelOpen = false
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        
        func setupSlidePanel(){
            // grab phones width and height
            let screenWidth = view.bounds.width
            let screenHeight = view.bounds.height
            
            // create the panel
            // CGRect is all the specs of the shape. Pos (X, Y) dimensions (W, H)
            slidePanel = UIView(frame: CGRect(
                x: screenWidth,     // staring off screen to the right
                y: 165,             // how far away from top
                width: 184,         // how wide
                height: screenHeight - 450  // leaves room top and bottom
            ))
            
            slidePanel.backgroundColor = .white
            
            // add it to the screen
            view.addSubview(slidePanel)
            
            // adds the scrollable screen into the sliding panel
            let scrollView = UIScrollView(frame: CGRect(
                x: 0,       // starts at left edge
                y: 0,       // starts at top of edge
                width: slidePanel.frame.width,
                height: slidePanel.frame.height
            ))
            scrollView.backgroundColor = .clear
            slidePanel.addSubview(scrollView)
            
            // ContentView actually allows for scrolling
            let contentView = UIView(frame: CGRect(
                x: 0,
                y: 0,
                width: slidePanel.frame.width,
                height: 500
            ))
            contentView.backgroundColor = .clear
            scrollView.addSubview(contentView)
            
            scrollView.contentSize = CGSize(
                width: slidePanel.frame.width,
                height: 500         // must match the content view val
                )
            setupPanelContent(in: contentView)
        }
        
        setupSlidePanel()
        
    
        
        pinsLocked = (pinLockSelector.selectedSegmentIndex == 1) // 1 = locked
        
        // Set up for location tracking
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyReduced
        locationManager.requestWhenInUseAuthorization( )
        locationManager.startUpdatingLocation()
        
        // Show user on map]
        mapView.showsUserLocation = true
        
        // listening for when the "tap" event happens on the mapView
        // when it detects a tap it calls handleMapTap method
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
        
        // Optional: read user-entered miles
        if let miles = currentUserInputMiles() {
            // Example of computing a radius using the entered miles
            let windingFactor = 1.5
            let _ = (miles * 1609.34) / (2 * .pi * windingFactor)
            // Use this value where appropriate in your generation logic
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // round only the bottom corners
        headerBox.layer.cornerRadius = 44
        headerBox.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerBox.layer.masksToBounds = true
    }
    
    func setupPanelContent(in container: UIView){
        let padding: CGFloat = 12       // Space from edges
        let fieldWidth = container.frame.width - (padding * 2)
        
        // distance label
        let distanceLabel = UILabel(frame: CGRect(
            x: padding,
            y: 20,
            width: fieldWidth,
            height: 20
        ))
        distanceLabel.text = "Distance (miles)"
        distanceLabel.font = .systemFont(ofSize: 14)
        container.addSubview(distanceLabel)
        
        // Text field
        let field = UITextField(frame: CGRect(
            x: padding,
            y: 48,
            width: fieldWidth,
            height: 36
        ))
        field.placeholder = "e.g. 3.1"
        field.borderStyle = .roundedRect
        field.keyboardType = .decimalPad
        
        // Add toolbar with Done button to dismiss keyboard
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.dismissKeyboard))
        toolbar.items = [flexible, doneButton]
        field.inputAccessoryView = toolbar
        
        field.delegate = self
        
        container.addSubview(field)
        
        self.distanceTextField = field
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func currentUserInputMiles() -> Double? {
        guard let text = distanceTextField?.text, !text.isEmpty else { return nil }
        return Double(text)
    }
    
    // MARK: - User Actions (IBActions)
    @IBAction func showCoordinateEntry(_ sender: Any) {
        showCoordinateEntry()
    }
    
    
    @IBAction func tempGenerateRandomPointsBTN(_ sender: UIButton) {
        let center = CLLocationCoordinate2D(latitude: 40.2022, longitude: -93.1252)
        let coord = generateRandomCoordinate(around: center, radius: 1000)
        print("Temp random point: \(coord.latitude), \(coord.longitude)")
        addAnnotation(at: coord, title: "Temp")
    }
    
    @IBAction func generateRouteBTN(_ sender: UIButton) {
        // Optional: read user-entered miles
        if let miles = currentUserInputMiles() {
            // Example of computing a radius using the entered miles
            let windingFactor = 1.5
            let _ = (miles * 1609.34) / (2 * .pi * windingFactor)
            // Use this value where appropriate in your generation logic
        }

        let selectedIndex = routeTypeSelector.selectedSegmentIndex
        let maxPins = requiredPinCount(for: selectedIndex)

        // Validate pin count for the selected route type
        if selectedIndex == 2 {
            // Loop: require at least 3 points (scalable)
            guard selectedCoordinates.count >= 3 else {
                showInfoAlert(message: "Please place at least 3 pins for a loop")
                return
            }
        } else {
            // One-way / Out-and-back: require exactly 2
            guard selectedCoordinates.count == maxPins else {
                showInfoAlert(message: "Please place 2 pins")
                return
            }
        }

        // Check which segement is selected
        
        switch selectedIndex {
        case 0: // One-way
            generateRoute(from: selectedCoordinates[0], to: selectedCoordinates[1])
        case 1: // Out-and-back
            generateOutAndBackRoute(from: selectedCoordinates[0], to: selectedCoordinates[1])
        case 2: //loop
            generateLoopRoute(points: selectedCoordinates)
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
    
    // User selects if they want pins locked or unlocked
    @IBOutlet weak var pinLockSelector: UISegmentedControl!
    
    
    @IBAction func pinLockChanged(_ sender: UISegmentedControl) {
        pinsLocked = (sender.selectedSegmentIndex == 1)
        if pinsLocked {
            showInfoAlert(message: "Pin placement is now locked")
        } else {
            showInfoAlert(message: "Pin placement is now unlocked")
        }
    }
    
    
    @IBAction func routeGenerationTypeSelector(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            useScenicRouting = false
            showInfoAlert(message: "Routing mode: Fastest")
        case 1:
            useScenicRouting = true
            showInfoAlert(message: "Routing mode: Scenic")
        default:
            break
        }
    }
    
    @IBAction func routeSettingsBTNTapped(_ sender: UIButton) {
        
        if isPanelOpen {
            closePanel()
        } else {
            openPanel()
        }
    }
    
    func openPanel() {
        let screenWidth = view.bounds.width
        
        UIView.animate(withDuration: 0.3) {
            self.slidePanel.frame.origin.x = screenWidth - 184
        }
        isPanelOpen = true
        
    }
    
    func closePanel() {
        let screenWidth = self.view.bounds.width
        
        UIView.animate(withDuration: 0.3) {
            self.slidePanel.frame.origin.x = screenWidth
        }
        isPanelOpen = false
    }
    
    
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
            
            var safeLat = lat
            var needsPoleWarning = false

            // Clamp latitude to just inside valid range to avoid MapKit pole issues
            if safeLat <= -90.0 {
                safeLat = -89.9999
                needsPoleWarning = true
            } else if safeLat >= 90.0 {
                safeLat = 89.9999
                needsPoleWarning = true
            }

            // Validate original inputs are within allowed ranges
            guard lat >= -90.0, lat <= 90.0 else {
                self.showErrorAlert(message: "Latitude out of range (-90 to 90)")
                return
            }
            guard long >= -180.0, long <= 180.0 else {
                self.showErrorAlert(message: "Longitude out of range (-180 to 180)")
                return
            }

            // Inform user if we had to clamp latitude at the poles
            if needsPoleWarning {
                self.showInfoAlert(title: "Adjusted Latitude", message: "Latitude at the exact pole is not supported. Adjusted to \(String(format: "%.4f", safeLat)).")
            }

            // Use the clamped coordinates to avoid crashes
            let coordinate = CLLocationCoordinate2D(latitude: safeLat, longitude: long)

            // Define a reasonable region around the coordinate
//            let region = MKCoordinateRegion(
//                center: coordinate,
//                latitudinalMeters: 10000,
//                longitudinalMeters: 10000
//            )
//
//            self.mapView.setRegion(region, animated: true)
            self.safelyCenterMap(on: coordinate, distance: 10000)

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
    
    
    
    // MARK: - Map Centering Helper
    private func safelyCenterMap(on coordinate: CLLocationCoordinate2D, distance: CLLocationDistance = 10000) {
        // Use camera-based centering to avoid invalid longitude spans near the poles
        let camera = MKMapCamera(lookingAtCenter: coordinate,
                                 fromDistance: max(100, distance),
                                 pitch: 0,
                                 heading: 0)
        mapView.setCamera(camera, animated: true)
    }
    
    // MARK: - Pin Count Helper
    private func requiredPinCount(for selectedIndex: Int) -> Int {
        // 0 = one-way (2 pins), 1 = out-and-back (2 pins), 2 = loop (3 pins)
        return (selectedIndex == 2) ? 3 : 2
    }
    
    // MARK: - Gesture Handling
    @objc func handleMapTap(_ gesture: UITapGestureRecognizer) {
        
        // Respect pin lock
        if pinsLocked {
            return
        }
        
        // gets the tap location in the view (screen pixels)
        // EX: tap found at 100 pixels from the top of screen and 300 pixels from right of screen.
        let locationInView = gesture.location(in: mapView)
        
        // convert the taps into coordinates (lat/long)
        // it basicall takes the tap location in pixels and then converts that into the lat/long for the map.
        let coordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
        
        // Sets the amount of max pins = to the route type
        let selectedIndex = routeTypeSelector.selectedSegmentIndex
        let maxPins = requiredPinCount(for: selectedIndex)
        
        
        // checks too see if there are already 2 points. if so then delete all the annotations and saved coords.
        if selectedIndex != 2 { // not loop
            if selectedCoordinates.count >= maxPins {
                showInfoAlert(message: "You already have \(maxPins) pins for this route type. Tap Cancel to reset.")
                return
            }
        }
        
        // TEST TO SEE IF WORKS JUST PRINT FOR NOW
        print("Tapped Lat: \(coordinate.latitude), Lon: \(coordinate.longitude)")
        
        // store the coordinates in my array
        selectedCoordinates.append(coordinate)
        
        // alters the title of the coordinate depending if it is the 1st or 2nd annotation
        let label: String
        if selectedCoordinates.count == 1 {
            label = "Start"
        } else if selectedIndex == 2 { // loop mode, 3rd pin is C
            label = String(UnicodeScalar(64 + selectedCoordinates.count)!)
        } else {
            label = "Stop"
        }
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
            annotation.index = max(0, selectedCoordinates.count - 1)
        }
        mapView.addAnnotation(annotation)
    }
    
    // MARK: - Alert Helpers
    // Centralized helpers for presenting feedback to the user.
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
        guard !isGeneratingRoute else { return }
        isGeneratingRoute = true
        
        mapView.removeOverlays(mapView.overlays)
        
        let source = MKMapItem(location: CLLocation(latitude: start.latitude, longitude: start.longitude), address: nil)
        let destination = MKMapItem(location: CLLocation(latitude: end.latitude, longitude: end.longitude), address: nil)
        
        let request = MKDirections.Request()
        request.source = source
        request.destination = destination
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [weak self] response, error in
            defer { self?.isGeneratingRoute = false }
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
    
    // MARK: - Routing Helpers
    private func requestWalkingRoutes(from start: CLLocationCoordinate2D,
                                      to end: CLLocationCoordinate2D,
                                      requestAlternates: Bool,
                                      completion: @escaping (Result<[MKRoute], Error>) -> Void) {
        let source = MKMapItem(location: CLLocation(latitude: start.latitude, longitude: start.longitude), address: nil)
        let destination = MKMapItem(location: CLLocation(latitude: end.latitude, longitude: end.longitude), address: nil)

        let request = MKDirections.Request()
        request.source = source
        request.destination = destination
        request.transportType = .walking
        request.requestsAlternateRoutes = requestAlternates

        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let routes = response?.routes, !routes.isEmpty else {
                completion(.failure(NSError(domain: "Route", code: -1, userInfo: [NSLocalizedDescriptionKey: "No route found."])) )
                return
            }
            completion(.success(routes))
        }
    }

    // Convenience wrapper that returns the single fastest route (existing behavior)
    private func requestWalkingRoute(from start: CLLocationCoordinate2D,
                                    to end: CLLocationCoordinate2D,
                                    completion: @escaping (Result<MKRoute, Error>) -> Void) {
        requestWalkingRoutes(from: start, to: end, requestAlternates: false) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let routes):
                // Choose the route with minimal expected travel time
                guard let fastest = routes.min(by: { $0.expectedTravelTime < $1.expectedTravelTime }) else {
                    completion(.failure(NSError(domain: "Route", code: -2, userInfo: [NSLocalizedDescriptionKey: "No route found."])) )
                    return
                }
                completion(.success(fastest))
            }
        }
    }

    // Simple scenic selector: prefer a longer route within a tolerance; break ties by lower avg speed
    private func pickScenicRoute(from routes: [MKRoute]) -> MKRoute {
        // Establish a baseline fastest route to set tolerances
        guard let fastest = routes.min(by: { $0.expectedTravelTime < $1.expectedTravelTime }) else {
            return routes[0]
        }

        let fastestDistance = fastest.distance

        // Score routes: prefer distance up to 1.3x of fastest, then prefer higher distance and lower avg speeda
        struct ScoredRoute { let route: MKRoute; let score: Double }

        let scored = routes.map { route -> ScoredRoute in
            let distance = route.distance
            let time = max(route.expectedTravelTime, 1.0)
            let avgSpeedProxy = distance / time // higher = faster; scenic prefers lower

            // Distance factor: favor routes longer than fastest but penalize if too long (> 1.3x)
            // The higher the withinCap is the more "loose" the grading will get
            let lengthRatio = distance / max(fastestDistance, 1.0)
            let withinCap = min(lengthRatio, 2.0)
            let lengthScore = withinCap // up to 1.8

            // Speed factor: invert avg speed so slower (more meandering) is better
            let speedScore = 1.0 / avgSpeedProxy

            // Combine with weights; tweak as desired
            let combined = (lengthScore * 0.9) + (speedScore * 0.1)
            return ScoredRoute(route: route, score: combined)
        }

        // Prefer highest score but ensure we stay within 1.3x distance cap; if none, fall back to fastest
        let capped = scored
            .filter { $0.route.distance <= fastestDistance * 2.0 }
            .sorted { $0.score > $1.score }

        return capped.first?.route ?? fastest
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
        
        let randomAngleDegrees = Double.random(in: 0...360)
        
        let randomAngleRadians = randomAngleDegrees * (.pi / 180)
        
        
        let randomDistance = Double.random(in: (0.35 * radius)...radius)
        
        let earthRadius = 6371000.0
        let latOffset = (randomDistance * cos(randomAngleRadians)) / earthRadius
        
        let centerLatRadians = center.latitude * (.pi / 180)
        let longOffset = (randomDistance * sin(randomAngleRadians)) / (earthRadius * cos(centerLatRadians))
        
        let latOffsetDegrees = latOffset * (180 / .pi)
        let lonOffsetDegrees = longOffset * (180 / .pi)
        
        let newLatitude = center.latitude + latOffsetDegrees
        let newLongitude = center.longitude + lonOffsetDegrees
        
        return CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude)

    }
    
    // Dispatcher: chooses fastest vs scenic for all legs based on `useScenicRouting`.
    func generateLoopRoute(points: [CLLocationCoordinate2D]) {
        if useScenicRouting {
            generateLoopRouteScenic(points: points)
        } else {
            generateLoopRouteFastest(points: points)
        }
    }

    // MARK: - Loop: Fastest everywhere
    private func generateLoopRouteFastest(points: [CLLocationCoordinate2D]) {
        guard points.count >= 3 else { showInfoAlert(message: "Need at least 3 points for a loop"); return }
        guard !isGeneratingRoute else { return }
        isGeneratingRoute = true

        mapView.removeOverlays(mapView.overlays)

        var totalDistance: CLLocationDistance = 0
        var totalTime: TimeInterval = 0

        func finish() {
            DispatchQueue.main.async { [weak self] in
                self?.isGeneratingRoute = false
            }
        }

        // Build legs: (0->1), (1->2), ..., (n-1->0)
        let n = points.count

        func routeLeg(at index: Int) {
            if index >= n { // done
                finish()
                return
            }
            let start = points[index]
            let end = points[(index + 1) % n]

            requestWalkingRoute(from: start, to: end) { [weak self] (result: Result<MKRoute, Error>) in
                switch result {
                case .failure(let error):
                    self?.showErrorAlert(message: "Leg \(index + 1) failed: \(error.localizedDescription)")
                    finish()
                case .success(let route):
                    DispatchQueue.main.async {
                        // Style each leg with a different color via legIndex
                        let coords = self?.getCoordinates(from: route.polyline) ?? []
                        let styled = StyledPolyline(coordinates: coords, count: coords.count)
                        styled.legIndex = index
                        styled.mode = .fastest
                        self?.mapView.addOverlay(styled)
                    }
                    totalDistance += route.distance
                    totalTime += route.expectedTravelTime
                    if index == n - 1 {
                        DispatchQueue.main.async { [weak self] in
                            self?.updateRouteInfoLabel(distance: totalDistance, time: totalTime)
                        }
                        finish()
                    } else {
                        routeLeg(at: index + 1)
                    }
                }
            }
        }

        routeLeg(at: 0)
    }

    // MARK: - Loop: Scenic everywhere
    private func generateLoopRouteScenic(points: [CLLocationCoordinate2D]) {
        guard points.count >= 3 else { showInfoAlert(message: "Need at least 3 points for a loop"); return }
        guard !isGeneratingRoute else { return }
        isGeneratingRoute = true

        mapView.removeOverlays(mapView.overlays)

        var totalDistance: CLLocationDistance = 0
        var totalTime: TimeInterval = 0

        func finish() {
            DispatchQueue.main.async { [weak self] in
                self?.isGeneratingRoute = false
            }
        }

        let n = points.count

        func routeLeg(at index: Int) {
            if index >= n { // done
                finish()
                return
            }
            let start = points[index]
            let end = points[(index + 1) % n]

            requestWalkingRoutes(from: start, to: end, requestAlternates: true) { [weak self] (result: Result<[MKRoute], Error>) in
                switch result {
                case .failure(let error):
                    self?.showErrorAlert(message: "Leg \(index + 1) failed: \(error.localizedDescription)")
                    finish()
                case .success(let routes):
                    let scenic = self?.pickScenicRoute(from: routes) ?? routes[0]
                    DispatchQueue.main.async {
                        let coords = self?.getCoordinates(from: scenic.polyline) ?? []
                        let styled = StyledPolyline(coordinates: coords, count: coords.count)
                        styled.legIndex = index
                        styled.mode = .scenic
                        self?.mapView.addOverlay(styled)
                    }
                    totalDistance += scenic.distance
                    totalTime += scenic.expectedTravelTime
                    if index == n - 1 {
                        DispatchQueue.main.async { [weak self] in
                            self?.updateRouteInfoLabel(distance: totalDistance, time: totalTime)
                        }
                        finish()
                    } else {
                        routeLeg(at: index + 1)
                    }
                }
            }
        }

        routeLeg(at: 0)
    }
    
    // Generate a route between two coordinates and draw it on the map
    // taking 2 points (starting and ending) coordinates (lat/long)
    func generateRoute(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) {
        guard !isGeneratingRoute else { return }
        isGeneratingRoute = true
        
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
            defer { self?.isGeneratingRoute = false }
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
            // Cycle colors by leg index for visibility
            let colors: [UIColor] = [.systemBlue, .systemGreen, .systemOrange, .systemPurple, .systemRed, .systemTeal, .systemPink, .brown]
            let color = colors[styled.legIndex % colors.count]
            renderer.strokeColor = color
            renderer.lineWidth = (styled.mode == .scenic) ? 6 : 5
            if styled.kind == .backward { // retain backward styling if used elsewhere
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
        annotationView?.frame = CGRect(x: 0, y: 0, width: 75, height: 75)
        return annotationView
    }
    
    // For when pins are being dragged around
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        // This is watching for when dragging has stopped or ended (meaning it is done being moved).
        if newState == .ending || newState == .canceling {
            view.dragState = .none
            guard let movedAnnotation = view.annotation as? RouteAnnotation else { return }
            let newCoordinate = movedAnnotation.coordinate
            
            // Update ANY index, not just 0 or 1
            if movedAnnotation.index < selectedCoordinates.count {
                selectedCoordinates[movedAnnotation.index] = newCoordinate
            }
            
            // Update selectedCoordinates based on annotation index
            // This is to ensure that even when a start or stop pin is being moved around that the new coordinates are assigned to the correct pin.
            // For example I have start and stop. I move start pin around, and then let go. This ensures, even thought start was first pin placed, that start is the one getting assigned the coordinates and not the latest placed pin.
            
            // Automatically regenerate route if we have the required number of points and no generation is in progress
            let selectedIndex = routeTypeSelector.selectedSegmentIndex
            let needed = requiredPinCount(for: selectedIndex)
            guard selectedCoordinates.count == needed else { return }
            guard !isGeneratingRoute else { return }

            switch selectedIndex {
            case 0: // One-way
                generateRoute(from: selectedCoordinates[0], to: selectedCoordinates[1])
            case 1: // Out-and-back
                generateOutAndBackRoute(from: selectedCoordinates[0], to: selectedCoordinates[1])
            case 2: // loop
                generateLoopRoute(points: selectedCoordinates)
            default:
                break
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // get most recent location
        guard let location = locations.last else { return }

        // save it for later
        userLocation = location.coordinate

        // Center map only the first time we get a location
        if !hasAlreadyCentered {
            print("Centering map on: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            safelyCenterMap(on: location.coordinate, distance: 10000)
            hasAlreadyCentered = true
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // handle permission change
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            showInfoAlert(message: "Using default location")
        default:
            break
        }
    }
}
    


// MARK: - Ideas / Notes
/*
 
 U.I. Thoughts:
    For swipey up tab at the bottom not sure if I want it to be like a segue or just something that is smaller.
    Would like the progress bar for the route to only appear once a route is made.
    For all route user set specs I would like a button that opens a "tab" where they can set information (distance/time, percentage of the route they would like to be walk/jog/running, if they want the route to be randomly generated (if not then grey out the options related to it), etc.)
    For the tab that is opened for the user route specs I don't want it to be an alert I want it to be stream lined and smooth, and something that you can close/get rid of quickly. I am almost thinking of being able to pop it out from the side and then flicking it back into the side (like a segue but coming from the left or right of the screen)
    I want to learn how to make all my stuff feel "professional" currently everything looks and feels "loose" or like just not good.
    I also think that currently and in the near future I'm going to have to many buttons for all the stuff I want so IDK how to fix that, but it is something I want to write down.
    Potential object for the swipey up tab "Bottom Sheet / Detent Panel"
 
 
 
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
When messing with UI stuff I found 2 problems:
    1. The screen sizes and not having automatic adjustments for phone model launching means that stuff is not consistent between phone sizes.
    2. The 2 different "types" of phone models Hill and Island. Hill (12 pro max) have the area around the camera come down from the top and is connected to the edge of the phone. Island (17 pro) has the area around the camera floating so screen runs inbetween it and the edge of the screen. I believe that the Hill models set there safety area/screen to the bottom (spot closest to the home "button") as the their edge, where as the Island models set the saftey area/screen to the actual edge of the screen. This is speculation but that is what I got out of it after messing around with it.
 
    Thoughts on my issues I have found out when messing with the apps UI elements and constraints. (At bottom of view controller). I know that it isn't a priority at this second but I wanted to get at least some of the concrete parts of the app situated (settings and Go To buttons, label for distance and time, Go and Cancel buttons). Currently my UI looks good for the iPhone 17 Pro. I'd like to have it at least look decent on everything after like the 13 (most common currently).
 
    Answer: I'll probably use the 13 as a base when making it and kinda just hope it looks meh on other models (13 since its most common rn)

    Thoughts:
        So the points do spread themselves out correctly, but I know mathmatically it needs to be .5 * radius for the minimum point for the distance but it seems idk like to far. I don't rememeber if this was one of the numbers that we can tweak without throwing the math of much or not but I think maybe more like 1/6 of the radius min would be better.
        I also haven't implemented in the cardinal direction picker but I think it'll be pretty simple. (will proabably need some weird/unique looking UI for it to look good.
        I also think that for my UI issue I will just build it around how the iPhone 13 since its the most commonly used right now and then just kinda hope that it is usuable on the other models.
 
*/

