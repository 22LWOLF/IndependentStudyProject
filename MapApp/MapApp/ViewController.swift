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
    // 0 for Start, 1 for Stop (or index for loops)
    var index: Int = 0
}

// MARK: - StyledPolyline
class StyledPolyline: MKPolyline {
    enum Kind { case forward, backward, walked, remaining }
    var kind: Kind = .forward

    var legIndex: Int = 0
    enum Mode { case fastest, scenic }
    var mode: Mode = .fastest
}

// MARK: - ViewController
class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {

    // MARK: Outlets
    @IBOutlet weak var headerBox: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var routeInfoLabel: UILabel!
    @IBOutlet weak var routeTypeSelector: UISegmentedControl!
    @IBOutlet weak var pinLockSelector: UISegmentedControl!

    // MARK: Properties
    private var selectedCoordinates: [CLLocationCoordinate2D] = []
    private var pinsLocked: Bool = false
    private var isGeneratingRoute: Bool = false

    // User location
    private var locationManager: CLLocationManager!
    private var userLocation: CLLocationCoordinate2D?
    private var hasAlreadyCentered: Bool = false

    // Slide panel
    var slidePanel: UIView!
    var isPanelOpen: Bool = false

    // Inputs/UI helpers
    private var distanceTextField: UITextField?
    private var distanceOrTimeLabel: UILabel?
    private var speedLabel: UILabel = UILabel()
    private var selectedDirectionButton: UIButton?

    // Routing preferences
    private var useScenicRouting: Bool = false
    private var useTimeInput: Bool = false
    private var selectedDirection: String = "random" // "N", "NE", etc.

    // Progress tracking
    private var followUser: Bool = false
    private var currentRouteCoordinates: [CLLocationCoordinate2D] = []
    private var traveledDistance: CLLocationDistance = 0
    private var lastLocationForProgress: CLLocation?
    private var totalRouteDistance: CLLocationDistance = 0
    private var progressView: UIProgressView = UIProgressView(progressViewStyle: .default)

    // Snap-to-route data
    private var routeSegments: [CLLocationCoordinate2D] = []
    private var cumulativeSegmentLengths: [CLLocationDistance] = []

    // Speed categorization thresholds in m/s
    private enum SpeedMode: String { case walking, jogging, running, unknown }

    // Speed learning system
    private var walkSampleCount: Int = 0
    private var jogSampleCount: Int = 0
    private var runSampleCount: Int = 0
    private var avgWalkingSpeed: Double = 1.4
    private var avgJoggingSpeed: Double = 2.7
    private var avgRunningSpeed: Double = 4.0

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupHeaderUI()
        setupSlidePanel()

        pinsLocked = (pinLockSelector.selectedSegmentIndex == 1)

        // Location
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.activityType = .fitness
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        // Map
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none

        // Tap gesture for placing pins
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
        mapView.addGestureRecognizer(tapGesture)

        loadSavedSpeeds()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerBox.layer.cornerRadius = 44
        headerBox.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerBox.layer.masksToBounds = true
    }

    // MARK: UI Setup
    private func setupHeaderUI() {
        // Progress view
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progress = 0
        progressView.progressTintColor = .systemBlue
        progressView.trackTintColor = .systemGray5
        progressView.layer.cornerRadius = 2
        headerBox.addSubview(progressView)
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: headerBox.leadingAnchor, constant: 16),
            progressView.trailingAnchor.constraint(equalTo: headerBox.trailingAnchor, constant: -16),
            progressView.bottomAnchor.constraint(equalTo: headerBox.bottomAnchor, constant: -8),
            progressView.heightAnchor.constraint(equalToConstant: 4)
        ])

        // Speed label
        speedLabel.translatesAutoresizingMaskIntoConstraints = false
        speedLabel.textAlignment = .left
        speedLabel.font = .systemFont(ofSize: 14)
        speedLabel.textColor = .label
        headerBox.addSubview(speedLabel)
        NSLayoutConstraint.activate([
            speedLabel.leadingAnchor.constraint(equalTo: headerBox.leadingAnchor, constant: 16),
            speedLabel.trailingAnchor.constraint(equalTo: headerBox.trailingAnchor, constant: -16),
            speedLabel.bottomAnchor.constraint(equalTo: progressView.topAnchor, constant: -4)
        ])
    }

    private func setupSlidePanel() {
        let screenWidth = view.bounds.width
        let screenHeight = view.bounds.height

        slidePanel = UIView(frame: CGRect(x: screenWidth, y: 165, width: 184, height: screenHeight - 450))
        slidePanel.backgroundColor = .white
        view.addSubview(slidePanel)

        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: slidePanel.frame.width, height: slidePanel.frame.height))
        scrollView.backgroundColor = .clear
        slidePanel.addSubview(scrollView)

        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: slidePanel.frame.width, height: 600))
        contentView.backgroundColor = .clear
        scrollView.addSubview(contentView)
        scrollView.contentSize = CGSize(width: slidePanel.frame.width, height: 600)

        setupPanelContent(in: contentView)
    }

    // MARK: Panel Content
    func setupPanelContent(in container: UIView) {
        let padding: CGFloat = 12
        let fieldWidth = container.frame.width - (padding * 2)

        // Time/distance label
        let timeToggleLabel = UILabel(frame: CGRect(x: padding, y: 150, width: fieldWidth, height: 20))
        timeToggleLabel.text = "Use Time Instead"
        timeToggleLabel.font = .systemFont(ofSize: 13)
        container.addSubview(timeToggleLabel)

        let timeToggle = UISwitch(frame: CGRect(x: padding, y: 175, width: fieldWidth, height: 31))
        timeToggle.addTarget(self, action: #selector(timeToggleChanged(_:)), for: .valueChanged)
        container.addSubview(timeToggle)

        let distanceLabel = UILabel(frame: CGRect(x: padding, y: 20, width: fieldWidth, height: 20))
        distanceLabel.text = "Distance (miles)"
        distanceLabel.font = .systemFont(ofSize: 14)
        container.addSubview(distanceLabel)
        self.distanceOrTimeLabel = distanceLabel

        let field = UITextField(frame: CGRect(x: padding, y: 48, width: fieldWidth, height: 36))
        field.placeholder = "e.g. 3.1"
        field.borderStyle = .roundedRect
        field.keyboardType = .decimalPad

        setupDirectionGrid(in: container, startY: 270)

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.dismissKeyboard))
        toolbar.items = [flexible, doneButton]
        field.inputAccessoryView = toolbar
        field.delegate = self
        let tap = UITapGestureRecognizer(target: field, action: #selector(UITextField.becomeFirstResponder))
        field.addGestureRecognizer(tap)
        field.isUserInteractionEnabled = true
        container.addSubview(field)
        self.distanceTextField = field

        let routingModeControl = UISegmentedControl(items: ["Fastest", "Scenic"])
        routingModeControl.selectedSegmentIndex = self.useScenicRouting ? 1 : 0
        routingModeControl.addTarget(self, action: #selector(self.routeGenerationTypeSelector(_:)), for: .valueChanged)
        routingModeControl.frame = CGRect(x: padding, y: 100, width: fieldWidth, height: 32)
        container.addSubview(routingModeControl)
    }

    private func setupDirectionGrid(in container: UIView, startY: CGFloat) {
        let directions = [["NW", "N", "NE"], ["W", ".", "E"], ["SW", "S", "SE"]]
        let buttonSize: CGFloat = 44
        let gap: CGFloat = 4
        let gridWidth = (buttonSize * 3) + (gap * 2)
        let startX = (container.frame.width - gridWidth) / 2

        for row in 0..<3 {
            for col in 0..<3 {
                let title = directions[row][col]
                let button = UIButton(type: .system)
                button.frame = CGRect(x: startX + CGFloat(col) * (buttonSize + gap), y: startY + CGFloat(row) * (buttonSize + gap), width: buttonSize, height: buttonSize)
                button.setTitle(title, for: .normal)
                button.backgroundColor = .systemIndigo
                button.layer.cornerRadius = 8
                if title == "." {
                    button.backgroundColor = .systemPurple
                    button.isEnabled = false
                }
                button.addTarget(self, action: #selector(directionButtonTapped(_:)), for: .touchUpInside)
                container.addSubview(button)
            }
        }
    }

    // MARK: Panel Open/Close
    func openPanel() {
        let screenWidth = view.bounds.width
        UIView.animate(withDuration: 0.3, animations: {
            self.slidePanel.frame.origin.x = screenWidth - 184
        }) { _ in
            self.distanceTextField?.becomeFirstResponder()
        }
        isPanelOpen = true
    }

    func closePanel() {
        let screenWidth = view.bounds.width
        UIView.animate(withDuration: 0.3) {
            self.slidePanel.frame.origin.x = screenWidth
        }
        isPanelOpen = false
    }

    // MARK: Alerts
    func showInfoAlert(title: String = "Info", message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }

    func showErrorAlert(title: String = "Error", message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .destructive))
            self.present(alert, animated: true)
        }
    }

    func showConfirmationAlert(title: String, message: String, confirmTitle: String = "OK", cancelTitle: String = "Cancel", onConfirm: @escaping () -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let confirm = UIAlertAction(title: confirmTitle, style: .default) { _ in onConfirm() }
            let cancel = UIAlertAction(title: cancelTitle, style: .cancel)
            alert.addAction(cancel)
            alert.addAction(confirm)
            self.present(alert, animated: true)
        }
    }

    // MARK: IBActions
    @IBAction func showCoordinateEntry(_ sender: Any) { showCoordinateEntry() }

    @IBAction func generateRouteBTN(_ sender: UIButton) {
        followUser = true
        if let miles = currentUserInputMiles() {
            let center = userLocation ?? CLLocationCoordinate2D(latitude: 40.2022, longitude: -93.1252)
            let windingFactor = 1.5
            let radius = (miles * 1609.34) / (2 * .pi * windingFactor)
            let endpoint = generateRandomCoordinate(around: center, radius: radius, direction: selectedDirection)
            let selectedIndex = routeTypeSelector.selectedSegmentIndex
            switch selectedIndex {
            case 0: generateRoute(from: center, to: endpoint)
            case 1: generateOutAndBackRoute(from: center, to: endpoint)
            default: showInfoAlert(message: "Use pins for loop routes")
            }
            return
        }

        let selectedIndex = routeTypeSelector.selectedSegmentIndex
        let maxPins = requiredPinCount(for: selectedIndex)
        if selectedIndex == 2 {
            guard selectedCoordinates.count >= 3 else { showInfoAlert(message: "Please place at least 3 pins for a loop"); return }
        } else {
            guard selectedCoordinates.count == maxPins else { showInfoAlert(message: "Please place 2 pins"); return }
        }
        switch selectedIndex {
        case 0:
            guard selectedCoordinates.count >= 2 else { return }
            generateRoute(from: selectedCoordinates[0], to: selectedCoordinates[1])
        case 1:
            guard selectedCoordinates.count >= 2 else { return }
            generateOutAndBackRoute(from: selectedCoordinates[0], to: selectedCoordinates[1])
        case 2:
            guard selectedCoordinates.count >= 3 else { return }
            generateLoopRoute(points: selectedCoordinates)
        default: break
        }
    }

    @IBAction func clearRouteBTN(_ sender: UIButton) {
        followUser = false
        selectedCoordinates.removeAll()
        isGeneratingRoute = false
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })
        resetProgressTracking(totalDistance: 0, routeCoords: [])
        progressView.setProgress(0, animated: false)
    }

    @IBAction func pinLockChanged(_ sender: UISegmentedControl) {
        pinsLocked = (sender.selectedSegmentIndex == 1)
        showInfoAlert(message: pinsLocked ? "Pin placement is now locked" : "Pin placement is now unlocked")
    }

    @IBAction func routeGenerationTypeSelector(_ sender: UISegmentedControl) {
        useScenicRouting = (sender.selectedSegmentIndex == 1)
    }

    @IBAction func routeSettingsBTNTapped(_ sender: UIButton) {
        isPanelOpen ? closePanel() : openPanel()
    }

    // MARK: - @objc Handlers
    @objc private func timeToggleChanged(_ sender: UISwitch) {
        useTimeInput = sender.isOn
        if sender.isOn {
            distanceOrTimeLabel?.text = "Time (min)"
            distanceTextField?.placeholder = "e.g. 30"
        } else {
            distanceOrTimeLabel?.text = "Distance (miles)"
            distanceTextField?.placeholder = "e.g. 3.2"
        }
        distanceTextField?.isHidden = false
        distanceTextField?.text = ""
    }

    @objc private func directionButtonTapped(_ sender: UIButton) {
        guard let direction = sender.title(for: .normal) else { return }
        selectedDirectionButton?.backgroundColor = .systemIndigo
        selectedDirectionButton?.setTitleColor(.systemBlue, for: .normal)
        if selectedDirectionButton == sender {
            selectedDirectionButton = nil
            selectedDirection = "random"
            return
        }
        sender.backgroundColor = .systemBlue
        sender.setTitleColor(.white, for: .normal)
        selectedDirectionButton = sender
        selectedDirection = direction
    }

    @objc func showCoordinateEntry() {
        let alert = UIAlertController(title: "Enter Coordinates", message: "Enter Latitude and longitude (-90 to 90, -180 to 180)", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Latitude (-90 to 90)"; $0.keyboardType = .numbersAndPunctuation }
        alert.addTextField { $0.placeholder = "Longitude (-180 to 180)"; $0.keyboardType = .numbersAndPunctuation }
        let goAction = UIAlertAction(title: "Go", style: .default) { [weak self] _ in
            guard let self = self else { return }
            guard let latText = alert.textFields?[0].text, !latText.isEmpty else { self.showErrorAlert(message: "No latitude entered"); return }
            guard let longText = alert.textFields?[1].text, !longText.isEmpty else { self.showErrorAlert(message: "No longitude entered"); return }
            guard let lat = Double(latText) else { self.showErrorAlert(message: "Latitude is not a valid number"); return }
            guard let long = Double(longText) else { self.showErrorAlert(message: "Longitude is not a valid number"); return }
            var safeLat = lat
            var needsPoleWarning = false
            if safeLat <= -90.0 { safeLat = -89.9999; needsPoleWarning = true }
            else if safeLat >= 90.0 { safeLat = 89.9999; needsPoleWarning = true }
            guard lat >= -90.0, lat <= 90.0 else { self.showErrorAlert(message: "Latitude out of range (-90 to 90)"); return }
            guard long >= -180.0, long <= 180.0 else { self.showErrorAlert(message: "Longitude out of range (-180 to 180)"); return }
            if needsPoleWarning { self.showInfoAlert(title: "Adjusted Latitude", message: "Latitude adjusted to \(String(format: "%.4f", safeLat)).") }
            let coordinate = CLLocationCoordinate2D(latitude: safeLat, longitude: long)
            self.safelyCenterMap(on: coordinate, distance: 10000)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        alert.addAction(goAction)
        present(alert, animated: true)
    }

    @objc func handleMapTap(_ gesture: UITapGestureRecognizer) {
        if pinsLocked { return }
        let locationInView = gesture.location(in: mapView)
        let coordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
        let selectedIndex = routeTypeSelector.selectedSegmentIndex
        let maxPins = requiredPinCount(for: selectedIndex)
        if selectedIndex != 2 {
            if selectedCoordinates.count >= maxPins {
                showInfoAlert(message: "You already have \(maxPins) pins for this route type. Tap Cancel to reset.")
                return
            }
        }
        selectedCoordinates.append(coordinate)
        let label: String
        if selectedCoordinates.count == 1 {
            label = "Start"
        } else if selectedIndex == 2 {
            let base = 64 + selectedCoordinates.count
            if let scalar = UnicodeScalar(base), CharacterSet.uppercaseLetters.contains(scalar) {
                label = String(scalar)
            } else {
                label = "P\(selectedCoordinates.count)"
            }
        } else {
            label = "Stop"
        }
        addAnnotation(at: coordinate, title: label)
    }

    // MARK: Map Helpers
    private func safelyCenterMap(on coordinate: CLLocationCoordinate2D, distance: CLLocationDistance = 10000) {
        let camera = MKMapCamera(lookingAtCenter: coordinate, fromDistance: max(100, distance), pitch: 0, heading: 0)
        mapView.setCamera(camera, animated: true)
    }

    private func requiredPinCount(for selectedIndex: Int) -> Int { (selectedIndex == 2) ? 3 : 2 }

    func removeAnnotations() { mapView.removeAnnotations(mapView.annotations) }

    func addAnnotation(at coordinate: CLLocationCoordinate2D, title: String? = nil) {
        let annotation = RouteAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        annotation.index = max(0, selectedCoordinates.count - 1)
        mapView.addAnnotation(annotation)
    }

    // MARK: Routing
    private func angleRange(for direction: String) -> ClosedRange<Double> {
        switch direction {
        case "N": return 337.5...360.0
        case "NE": return 22.5...67.5
        case "E": return 67.5...112.5
        case "SE": return 112.5...157.5
        case "S": return 157.5...202.5
        case "SW": return 202.5...247.5
        case "W": return 247.5...292.5
        case "NW": return 292.5...337.5
        default: return 0.0...360.0
        }
    }

    func updateRouteInfoLabel(distance: CLLocationDistance, time: TimeInterval) {
        let distanceMiles = distance / 1609.34
        let timeMinutes = time / 60.0
        let infoText = String(format: "%.2f miles • ~%.0f min", distanceMiles, timeMinutes)
        routeInfoLabel.text = infoText
    }

    private func resetProgressTracking(totalDistance: CLLocationDistance, routeCoords: [CLLocationCoordinate2D]) {
        totalRouteDistance = totalDistance
        currentRouteCoordinates = routeCoords
        traveledDistance = 0
        lastLocationForProgress = nil
        prepareSnapToRouteData(from: routeCoords)
        DispatchQueue.main.async { self.progressView.setProgress(0, animated: true) }
    }

    private func prepareSnapToRouteData(from coords: [CLLocationCoordinate2D]) {
        routeSegments = coords
        cumulativeSegmentLengths = Array(repeating: 0, count: coords.count)
        guard coords.count >= 2 else { return }
        var running: CLLocationDistance = 0
        for i in 1..<coords.count {
            let a = CLLocation(latitude: coords[i-1].latitude, longitude: coords[i-1].longitude)
            let b = CLLocation(latitude: coords[i].latitude, longitude: coords[i].longitude)
            running += a.distance(from: b)
            cumulativeSegmentLengths[i] = running
        }
    }

    private func snappedProgress(for location: CLLocation) -> CLLocationDistance? {
        guard routeSegments.count >= 2 else { return nil }
        var bestDistanceToSegment = CLLocationDistance.greatestFiniteMagnitude
        var bestAlongDistance: CLLocationDistance = 0
        for i in 1..<routeSegments.count {
            let p0 = routeSegments[i-1]
            let p1 = routeSegments[i]
            let a = MKMapPoint(p0)
            let b = MKMapPoint(p1)
            let p = MKMapPoint(location.coordinate)
            let ab = CGPoint(x: b.x - a.x, y: b.y - a.y)
            let ap = CGPoint(x: p.x - a.x, y: p.y - a.y)
            let abLen2 = (ab.x * ab.x) + (ab.y * ab.y)
            if abLen2 == 0 { continue }
            var t = ((ap.x * ab.x) + (ap.y * ab.y)) / abLen2
            t = max(0, min(1, t))
            let proj = CGPoint(x: a.x + ab.x * t, y: a.y + ab.y * t)
            let dx = proj.x - p.x
            let dy = proj.y - p.y
            let distToSeg = sqrt(dx*dx + dy*dy)
            if distToSeg < bestDistanceToSegment {
                bestDistanceToSegment = distToSeg
                let upToPrev = cumulativeSegmentLengths[i-1]
                let segStart = CLLocation(latitude: p0.latitude, longitude: p0.longitude)
                let projCoord = MKMapPoint(x: proj.x, y: proj.y).coordinate
                let projLoc = CLLocation(latitude: projCoord.latitude, longitude: projCoord.longitude)
                let partial = segStart.distance(from: projLoc)
                bestAlongDistance = upToPrev + partial
            }
        }
        return bestAlongDistance
    }

    private func nearestRouteIndex(to location: CLLocation) -> Int {
        var closestIndex = 0
        var closestDistance = CLLocationDistance.greatestFiniteMagnitude
        for (index, coord) in currentRouteCoordinates.enumerated() {
            let routePoint = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            let d = location.distance(from: routePoint)
            if d < closestDistance {
                closestDistance = d
                closestIndex = index
            }
        }
        return closestIndex
    }

    private func updateProgress(with newLocation: CLLocation) {
        guard !currentRouteCoordinates.isEmpty, totalRouteDistance > 0 else { return }
        if let along = snappedProgress(for: newLocation) {
            traveledDistance = along
            let progress = max(0, min(Float(traveledDistance / totalRouteDistance), 1))
            DispatchQueue.main.async { self.progressView.setProgress(progress, animated: true) }
        }
        lastLocationForProgress = newLocation
        let nearest = nearestRouteIndex(to: newLocation)
        updateRouteOverlay(nearestIndex: nearest)
    }

    private func speedMode(for speed: CLLocationSpeed) -> SpeedMode {
        if speed.isNaN || speed < 0 { return .unknown }
        switch speed {
        case ..<2.0: return .walking
        case 2.0..<3.5: return .jogging
        default: return .running
        }
    }

    func getCoordinates(from polyline: MKPolyline) -> [CLLocationCoordinate2D] {
        let points = polyline.points()
        let pointCount = polyline.pointCount
        var coordinates: [CLLocationCoordinate2D] = []
        for i in 0..<pointCount { coordinates.append(points[i].coordinate) }
        return coordinates
    }

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
            if let error = error { self?.showErrorAlert(message: "Error calculating route: \(error.localizedDescription)"); return }
            guard let route = response?.routes.first else { return }
            let totalDistance = route.distance * 2
            let totalTime = route.expectedTravelTime * 2
            self?.updateRouteInfoLabel(distance: totalDistance, time: totalTime)
            self?.mapView.addOverlay(route.polyline)
            let forwardCoords = self?.getCoordinates(from: route.polyline) ?? []
            let backward = Array(forwardCoords.reversed())
            let backwardPolyline = StyledPolyline(coordinates: backward, count: backward.count)
            backwardPolyline.kind = .backward
            self?.mapView.addOverlay(backwardPolyline)
            let combined = forwardCoords + backward
            self?.resetProgressTracking(totalDistance: totalDistance, routeCoords: combined)
        }
    }

    private func requestWalkingRoutes(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D, requestAlternates: Bool, completion: @escaping (Result<[MKRoute], Error>) -> Void) {
        let source = MKMapItem(location: CLLocation(latitude: start.latitude, longitude: start.longitude), address: nil)
        let destination = MKMapItem(location: CLLocation(latitude: end.latitude, longitude: end.longitude), address: nil)
        let request = MKDirections.Request()
        request.source = source
        request.destination = destination
        request.transportType = .walking
        request.requestsAlternateRoutes = requestAlternates
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let error = error { completion(.failure(error)); return }
            guard let routes = response?.routes, !routes.isEmpty else {
                completion(.failure(NSError(domain: "Route", code: -1, userInfo: [NSLocalizedDescriptionKey: "No route found."])));
                return
            }
            completion(.success(routes))
        }
    }

    private func requestWalkingRoute(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D, completion: @escaping (Result<MKRoute, Error>) -> Void) {
        requestWalkingRoutes(from: start, to: end, requestAlternates: false) { result in
            switch result {
            case .failure(let error): completion(.failure(error))
            case .success(let routes):
                guard let fastest = routes.min(by: { $0.expectedTravelTime < $1.expectedTravelTime }) else {
                    completion(.failure(NSError(domain: "Route", code: -2, userInfo: [NSLocalizedDescriptionKey: "No route found."]))); return
                }
                completion(.success(fastest))
            }
        }
    }

    private func pickScenicRoute(from routes: [MKRoute]) -> MKRoute {
        guard let fastest = routes.min(by: { $0.expectedTravelTime < $1.expectedTravelTime }) else { return routes[0] }
        let fastestDistance = fastest.distance
        struct ScoredRoute { let route: MKRoute; let score: Double }
        let scored = routes.map { route -> ScoredRoute in
            let distance = route.distance
            let time = max(route.expectedTravelTime, 1.0)
            let avgSpeedProxy = distance / time
            let lengthRatio = distance / max(fastestDistance, 1.0)
            let withinCap = min(lengthRatio, 2.0)
            let lengthScore = withinCap
            let speedScore = 1.0 / avgSpeedProxy
            let combined = (lengthScore * 0.9) + (speedScore * 0.1)
            return ScoredRoute(route: route, score: combined)
        }
        let capped = scored.filter { $0.route.distance <= fastestDistance * 2.0 }.sorted { $0.score > $1.score }
        return capped.first?.route ?? fastest
    }

    // MARK: Loop helpers
    func generateLoopRoute(points: [CLLocationCoordinate2D]) {
        if useScenicRouting { generateLoopRouteScenic(points: points) } else { generateLoopRouteFastest(points: points) }
    }

    private func generateLoopRouteFastest(points: [CLLocationCoordinate2D]) {
        guard points.count >= 3 else { showInfoAlert(message: "Need at least 3 points for a loop"); return }
        guard !isGeneratingRoute else { return }
        isGeneratingRoute = true
        mapView.removeOverlays(mapView.overlays)
        var totalDistance: CLLocationDistance = 0
        var totalTime: TimeInterval = 0
        let n = points.count
        func finish() { DispatchQueue.main.async { [weak self] in self?.isGeneratingRoute = false } }
        func routeLeg(at index: Int) {
            if index >= n { finish(); return }
            let start = points[index]
            let end = points[(index + 1) % n]
            requestWalkingRoute(from: start, to: end) { [weak self] result in
                switch result {
                case .failure(let error): self?.showErrorAlert(message: "Leg \(index + 1) failed: \(error.localizedDescription)"); finish()
                case .success(let route):
                    DispatchQueue.main.async {
                        let coords = self?.getCoordinates(from: route.polyline) ?? []
                        let styled = StyledPolyline(coordinates: coords, count: coords.count)
                        styled.legIndex = index
                        styled.mode = .fastest
                        self?.mapView.addOverlay(styled)
                    }
                    totalDistance += route.distance
                    totalTime += route.expectedTravelTime
                    if index == n - 1 {
                        DispatchQueue.main.async { [weak self] in self?.updateRouteInfoLabel(distance: totalDistance, time: totalTime) }
                        var allCoords: [CLLocationCoordinate2D] = []
                        for overlay in self?.mapView.overlays ?? [] {
                            if let sp = overlay as? StyledPolyline { allCoords.append(contentsOf: self?.getCoordinates(from: sp) ?? []) }
                        }
                        self?.resetProgressTracking(totalDistance: totalDistance, routeCoords: allCoords)
                        finish()
                    } else { routeLeg(at: index + 1) }
                }
            }
        }
        routeLeg(at: 0)
    }

    private func generateLoopRouteScenic(points: [CLLocationCoordinate2D]) {
        guard points.count >= 3 else { showInfoAlert(message: "Need at least 3 points for a loop"); return }
        guard !isGeneratingRoute else { return }
        isGeneratingRoute = true
        mapView.removeOverlays(mapView.overlays)
        var totalDistance: CLLocationDistance = 0
        var totalTime: TimeInterval = 0
        let n = points.count
        func finish() { DispatchQueue.main.async { [weak self] in self?.isGeneratingRoute = false } }
        func routeLeg(at index: Int) {
            if index >= n { finish(); return }
            let start = points[index]
            let end = points[(index + 1) % n]
            requestWalkingRoutes(from: start, to: end, requestAlternates: true) { [weak self] result in
                switch result {
                case .failure(let error): self?.showErrorAlert(message: "Leg \(index + 1) failed: \(error.localizedDescription)"); finish()
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
                        DispatchQueue.main.async { [weak self] in self?.updateRouteInfoLabel(distance: totalDistance, time: totalTime) }
                        var allCoords: [CLLocationCoordinate2D] = []
                        for overlay in self?.mapView.overlays ?? [] {
                            if let sp = overlay as? StyledPolyline { allCoords.append(contentsOf: self?.getCoordinates(from: sp) ?? []) }
                        }
                        self?.resetProgressTracking(totalDistance: totalDistance, routeCoords: allCoords)
                        finish()
                    } else { routeLeg(at: index + 1) }
                }
            }
        }
        routeLeg(at: 0)
    }

    func generateRoute(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) {
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
            if let error = error { self?.showErrorAlert(message: "Error calculating route: \(error.localizedDescription)"); return }
            guard let route = response?.routes.first else { return }
            if let targetMiles = self?.currentUserInputMiles() {
                let targetMeters = targetMiles * 1609.34
                let actualMeters = route.distance
                let difference = abs(actualMeters - targetMeters)
                let tolerance = targetMeters * 0.3
                if difference > tolerance {
                    let actualMiles = actualMeters / 1609.34
                    self?.showInfoAlert(message: String(format: "Closest route found: %.1f miles (requested %.1f)", actualMiles, targetMiles))
                }
            }
            self?.updateRouteInfoLabel(distance: route.distance, time: route.expectedTravelTime)
            self?.mapView.addOverlay(route.polyline)
            let coords = self?.getCoordinates(from: route.polyline) ?? []
            self?.resetProgressTracking(totalDistance: route.distance, routeCoords: coords)
        }
    }

    // MARK: MKMapViewDelegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let styled = overlay as? StyledPolyline {
            let renderer = MKPolylineRenderer(polyline: styled)
            let colors: [UIColor] = [.systemBlue, .systemGreen, .systemOrange, .systemPurple, .systemRed, .systemTeal, .systemPink, .brown]
            let color = colors[styled.legIndex % colors.count]
            renderer.strokeColor = color
            renderer.lineWidth = (styled.mode == .scenic) ? 6 : 5
            if styled.kind == .backward { renderer.lineDashPattern = [2, 5] }
            if styled.kind == .walked { renderer.strokeColor = UIColor.gray.withAlphaComponent(0.4); renderer.lineWidth = 5 }
            if styled.kind == .remaining { renderer.strokeColor = .systemBlue; renderer.lineWidth = 5 }
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

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        let identifier = "PinAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.isDraggable = true
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        annotationView?.frame = CGRect(x: 0, y: 0, width: 75, height: 75)
        return annotationView
    }

    private func updateRouteOverlay(nearestIndex: Int) {
        let overlaysToRemove = mapView.overlays.compactMap { overlay -> MKOverlay? in
            if let styled = overlay as? StyledPolyline, (styled.kind == .walked || styled.kind == .remaining) { return overlay }
            return nil
        }
        mapView.removeOverlays(overlaysToRemove)
        guard currentRouteCoordinates.count > 1, nearestIndex < currentRouteCoordinates.count else { return }
        let walkedCoords = Array(currentRouteCoordinates[0...nearestIndex])
        let remainingCoords = Array(currentRouteCoordinates[nearestIndex...])
        let walkedLine = StyledPolyline(coordinates: walkedCoords, count: walkedCoords.count)
        walkedLine.kind = .walked
        let remainingLine = StyledPolyline(coordinates: remainingCoords, count: remainingCoords.count)
        remainingLine.kind = .remaining
        DispatchQueue.main.async {
            self.mapView.addOverlay(walkedLine)
            self.mapView.addOverlay(remainingLine)
        }
    }

    // MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location.coordinate
        updateProgress(with: location)
        updateSpeedLabel(speed: location.speed)
        updateSpeedAverages(speed: location.speed)
        if !hasAlreadyCentered {
            safelyCenterMap(on: location.coordinate, distance: 10000)
            hasAlreadyCentered = true
        } else if followUser {
            safelyCenterMap(on: location.coordinate, distance: 1000)
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            showInfoAlert(message: "Using default location")
        default: break
        }
    }

    // MARK: Keyboard
    @objc private func dismissKeyboard() { view.endEditing(true) }

    // MARK: Inputs
    private func currentUserInputMiles() -> Double? {
        guard let text = distanceTextField?.text, !text.isEmpty else { return nil }
        guard let value = Double(text) else { return nil }
        if useTimeInput {
            let walkingSpeedMPH = 3.5
            return (value / 60.0) * walkingSpeedMPH
        } else {
            return value
        }
    }

    // MARK: Random coordinate
    func generateRandomCoordinate(around center: CLLocationCoordinate2D, radius: Double, direction: String = "random") -> CLLocationCoordinate2D {
        let range = angleRange(for: direction)
        let randomAngleDegrees: Double
        if direction == "N" {
            randomAngleDegrees = Bool.random() ? Double.random(in: 337.5...360.0) : Double.random(in: 0.0...22.5)
        } else {
            randomAngleDegrees = Double.random(in: range)
        }
        let randomAngleRadians = randomAngleDegrees * (.pi / 180)
        let randomDistance = Double.random(in: (0.7 * radius)...radius)
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

    // MARK: Speed UI/Averages
    private func updateSpeedLabel(speed: CLLocationSpeed) {
        let mph = speed * 2.23694
        guard mph >= 0 else { speedLabel.text = "Speed: --"; return }
        let category = speedMode(for: speed)
        speedLabel.text = String(format: "%.1f mph - \(category.rawValue)", mph)
    }

    private func updateSpeedAverages(speed: CLLocationSpeed) {
        guard speed > 0 else { return }
        let mode = speedMode(for: speed)
        switch mode {
        case .walking:
            avgWalkingSpeed = ((avgWalkingSpeed * Double(walkSampleCount)) + speed) / Double(walkSampleCount + 1)
            walkSampleCount += 1
        case .jogging:
            avgJoggingSpeed = ((avgJoggingSpeed * Double(jogSampleCount)) + speed) / Double(jogSampleCount + 1)
            jogSampleCount += 1
        case .running:
            avgRunningSpeed = ((avgRunningSpeed * Double(runSampleCount)) + speed) / Double(runSampleCount + 1)
            runSampleCount += 1
        case .unknown:
            return
        }
        let totalSamples = walkSampleCount + jogSampleCount + runSampleCount
        if totalSamples % 10 == 0 { saveSpeeds() }
    }

    private func loadSavedSpeeds() {
        let defaults = UserDefaults.standard
        if defaults.double(forKey: "avgWalkingSpeed") > 0 {
            avgWalkingSpeed = defaults.double(forKey: "avgWalkingSpeed")
            walkSampleCount = defaults.integer(forKey: "walkSampleCount")
        }
        if defaults.double(forKey: "avgJoggingSpeed") > 0 {
            avgJoggingSpeed = defaults.double(forKey: "avgJoggingSpeed")
            jogSampleCount = defaults.integer(forKey: "jogSampleCount")
        }
        if defaults.double(forKey: "avgRunningSpeed") > 0 {
            avgRunningSpeed = defaults.double(forKey: "avgRunningSpeed")
            runSampleCount = defaults.integer(forKey: "runSampleCount")
        }
        print("Loaded speeds - Walk: \(avgWalkingSpeed) | Jog: \(avgJoggingSpeed) | Run: \(avgRunningSpeed)")
    }

    private func saveSpeeds() {
        let defaults = UserDefaults.standard
        defaults.set(avgWalkingSpeed, forKey: "avgWalkingSpeed")
        defaults.set(avgJoggingSpeed, forKey: "avgJoggingSpeed")
        defaults.set(avgRunningSpeed, forKey: "avgRunningSpeed")
        defaults.set(walkSampleCount, forKey: "walkSampleCount")
        defaults.set(jogSampleCount, forKey: "jogSampleCount")
        defaults.set(runSampleCount, forKey: "runSampleCount")
        print("💾 Saved speeds - Walk: \(String(format: "%.2f", avgWalkingSpeed)) | Jog: \(String(format: "%.2f", avgJoggingSpeed)) | Run: \(String(format: "%.2f", avgRunningSpeed))")
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
 
        Have the ability to change accuracy of tracking (either in settings) or if route is super long distance/time then it will automatically switch to help with effeiency.
 
 
 
  Feb 16: Stuff that needs done/refined
    I need to add in a better way of using the users inputted times when calculating a random route, it seems to be only going a little distance and I also keep getting a pop up that says: "Info closest route found: 0.0 miles (requested 0.6)" when I put in that I want a 10 miniute long route.
*/

