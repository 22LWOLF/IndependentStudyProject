//
//  ViewController.swift
//  MapApp
//
//  Created by Wolf,Luke D on 1/16/26.
//

import UIKit
import MapKit
import CoreLocation

// MARK: - Color Scheme
extension UIColor {
    static let appPrimary = UIColor(red: 152.0/255.0, green: 168.0/255.0, blue: 105.0/255.0, alpha: 1.0)
    static let compColor = UIColor(red: 105.0/255.0, green: 120.0/255.0, blue: 168.0/255.0, alpha: 1.0)
    static let darkColor = UIColor(red: 51.0/255.0, green: 35.0/255.0, blue: 51.0/255.0, alpha: 1.0)
}

// MARK: - Custom Classes
class RouteAnnotation: MKPointAnnotation { var index: Int = 0 }

class StyledPolyline: MKPolyline {
    enum Kind { case forward, backward, walked, remaining }
    var kind: Kind = .forward
    var legIndex: Int = 0
    enum Mode { case fastest, scenic }
    var mode: Mode = .fastest
}

// MARK: - Custom Table Cell
class RouteTableViewCell: UITableViewCell {
    let moreButton = UIButton(type: .system)
    let favoriteButton = UIButton(type: .system)
    let editButton = UIButton(type: .system)
    let deleteButton = UIButton(type: .system)
    private var isRevealed = false
    
    var deleteAction: (() -> Void)?
    var editAction: (() -> Void)?
    var favoriteAction: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        setupButtons()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    private func setupButtons() {
        // More button (3 dots) - always visible
        moreButton.setImage(UIImage(systemName: "ellipsis.circle.fill"), for: .normal)
        moreButton.tintColor = .systemGray
        moreButton.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
        contentView.addSubview(moreButton)
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            moreButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            moreButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            moreButton.widthAnchor.constraint(equalToConstant: 32),
            moreButton.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        // Delete button FIRST (behind edit)
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.backgroundColor = .systemRed
        deleteButton.layer.cornerRadius = 8
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        contentView.addSubview(deleteButton)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 140),
            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 70),
            deleteButton.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        
        // Favorite button (heart)
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.tintColor = .systemPink
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        contentView.addSubview(favoriteButton)
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            favoriteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 36),
            favoriteButton.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        // Edit button SECOND (on top)
        editButton.setTitle("Edit", for: .normal)
        editButton.setTitleColor(.white, for: .normal)
        editButton.backgroundColor = .systemBlue
        editButton.layer.cornerRadius = 8
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        contentView.addSubview(editButton)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            editButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 70),
            editButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            editButton.widthAnchor.constraint(equalToConstant: 60),
            editButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    @objc private func moreButtonTapped() {
        print("🔘 More tapped, revealed: \(isRevealed)")
        if isRevealed {
            hideOptionsButton()
        } else {
            revealOptionsButtons()
        }
    }
    
    @objc private func editButtonTapped() {
        print("✏️ Edit tapped")
        editAction?()
        hideOptionsButton()
    }
    
    @objc private func deleteButtonTapped() {
        print("🗑️ Delete tapped")
        deleteAction?()
        hideOptionsButton()
    }
    
    @objc private func favoriteButtonTapped() {
        print("❤️ Favorite tapped")
        favoriteAction?()
        // Don't hide buttons - let user tap multiple actions
        
    }
    
    func updateFavoriteIcon(isFavorite: Bool){
        let iconName = isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: iconName), for: .normal)
    }
    
    private func revealOptionsButtons() {
        isRevealed = true
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.editButton.transform = CGAffineTransform(translationX: -96, y: 0)
            self.favoriteButton.transform = CGAffineTransform(translationX: -166, y: 0)
            self.deleteButton.transform = CGAffineTransform(translationX: -230, y: 0)
            self.textLabel?.transform = CGAffineTransform(translationX: -166, y: 0)
            self.detailTextLabel?.transform = CGAffineTransform(translationX: -166, y: 0)
            self.moreButton.transform = CGAffineTransform(translationX: -166, y: 0)
            self.moreButton.alpha = 1.0
        }
    }
    
    private func hideOptionsButton() {
        isRevealed = false
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self.editButton.transform = .identity
            self.favoriteButton.transform = .identity
            self.deleteButton.transform = .identity
            self.moreButton.transform = .identity
            self.textLabel?.transform = .identity
            self.detailTextLabel?.transform = .identity
        
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Ensure the more button is visible if this cell was reused from the placeholder state
        moreButton.isHidden = false
        // Reset any revealed transforms
        hideOptionsButton()
    }
}

// MARK: - Route Configuration
struct RouteConfig {
    enum RouteType: Int { case oneWay = 0, outAndBack = 1, loop = 2 }
    var type: RouteType
    var isScenic: Bool
    var waypoints: [CLLocationCoordinate2D]
    var targetDistance: Double? // in miles
    var direction: String?
}

// MARK: - ViewController
class ViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var headerBox: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var routeInfoLabel: UILabel!
    @IBOutlet weak var routeTypeSelector: UISegmentedControl!
    @IBOutlet weak var bottomTabContainer: UIView!
    @IBOutlet weak var routeHistorySheet: UIView!
    @IBOutlet weak var routesTableView: UITableView!
    @IBOutlet weak var routesSearchBar: UISearchBar!
    @IBOutlet weak var filterButton: UIButton!

    // MARK: - UI Components
    private var slidePanel: UIView!
    private var panelScrollView: UIScrollView!
    private var distanceTextField: UITextField?
    private var distanceOrTimeLabel: UILabel?
    private var speedLabel: UILabel = UILabel()
    private var selectedDirectionButton: UIButton?
    private var loopPointStepper: UIStepper?
    private var loopPointLabel: UILabel?
    private var timeToggle: UISwitch?
    private var progressView = UIProgressView(progressViewStyle: .default)

    // MARK: - State
    private var selectedCoordinates: [CLLocationCoordinate2D] = []
    private var isPanelOpen = false
    private var isGeneratingRoute = false
    private var isFollowingUser = false
    private var isActivelyWalkingRoute = false
    private var hasAlreadyCentered = false
    
    //Filter state
    private var showOnlyFavorites: Bool = false   //means it shows favs and non-favs
    private var filterByRouteType: Int? = nil   //nil = show all types
    private var filterByScenicMode: Bool? = nil   //nil = show all, 1 = fastest, 2 = scenic
    private var sortOption: SortOption = .newestFirst
    
    enum SortOption {
        case newestFirst
        case oldestFirst
        case shortestDistance
        case longestDistance
        case shortestTime
        case longestTime
        case nameAZ
        case nameZA
    }

    // MARK: - User Preferences
    private var useScenicRouting = false
    private var useTimeInput = false
    private var selectedDirection = "random"
    private var selectedLoopPoints = 3
    
    // MARK: - Route History
    private var savedRoutes: [SavedRoute] = []
    private var filteredRoutes: [SavedRoute] = []

    // MARK: - Location
    private var locationManager: CLLocationManager!
    private var userLocation: CLLocationCoordinate2D?

    // MARK: - Route Tracking
    private var currentRouteCoordinates: [CLLocationCoordinate2D] = []
    private var totalRouteDistance: CLLocationDistance = 0
    private var traveledDistance: CLLocationDistance = 0
    private var routeSegments: [CLLocationCoordinate2D] = []
    private var cumulativeSegmentLengths: [CLLocationDistance] = []
    private var currentRouteType: RouteConfig.RouteType = .oneWay

    // MARK: - Speed Learning
    private var avgWalkingSpeed: Double = 1.4
    private var avgJoggingSpeed: Double = 2.7
    private var avgRunningSpeed: Double = 4.0
    private var walkSampleCount = 0
    private var jogSampleCount = 0
    private var runSampleCount = 0
    
    // MARK: - Route History Sheet State
    private var routeSheetState: RouteSheetState = .collapsed
    private var routeSheetCollapsedHeight: CGFloat = 30
    // Just pill visible
    private var routeSheetExpandedHeight: CGFloat = 0
    

    enum RouteSheetState {
        case collapsed
        case expanded
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        setupLocation()
        setupUI()
        loadSavedSpeeds()
        setupRouteHistorySheet()
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerBox.layer.cornerRadius = 44
        headerBox.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerBox.layer.masksToBounds = true

        bottomTabContainer.layer.cornerRadius = 44
        bottomTabContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomTabContainer.layer.masksToBounds = true
        
        calculateRouteSheetHeight()
    }
}

// MARK: - Setup Methods
extension ViewController {
    private func setupMap() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap))
        mapView.addGestureRecognizer(tapGesture)
    }

    private func setupLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 5.0
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    private func setupUI() {
        setupProgressBar()
        setupSlidePanel()
        setupLoopControls()
    }

    private func setupProgressBar() {
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progress = 0
        progressView.progressTintColor = .compColor
        progressView.trackTintColor = .darkColor
        progressView.layer.cornerRadius = 2
        headerBox.addSubview(progressView)
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: headerBox.leadingAnchor, constant: 16),
            progressView.trailingAnchor.constraint(equalTo: headerBox.trailingAnchor, constant: -16),
            progressView.bottomAnchor.constraint(equalTo: headerBox.bottomAnchor, constant: -8),
            progressView.heightAnchor.constraint(equalToConstant: 4)
        ])
    }

    private func setupLoopControls() {
        loopPointStepper?.isEnabled = false
        loopPointStepper?.alpha = 0.4
        loopPointLabel?.isEnabled = false
        loopPointLabel?.alpha = 0.4
    }
    
    private func setupRouteHistorySheet() {
        // Round top corners
        routeHistorySheet.layer.cornerRadius = 20
        routeHistorySheet.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        routeHistorySheet.layer.masksToBounds = true
        
        // Add shadow for depth
        routeHistorySheet.layer.shadowColor = UIColor.black.cgColor
        routeHistorySheet.layer.shadowOpacity = 0.1
        routeHistorySheet.layer.shadowOffset = CGSize(width: 0, height: -2)
        routeHistorySheet.layer.shadowRadius = 8
        
        
        // Add pan gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleRouteSheetPan(_:)))
        panGesture.delegate = self
        routeHistorySheet.addGestureRecognizer(panGesture)
            
        
        // Set initial collapsed state
        setRouteSheetHeight(routeSheetCollapsedHeight, animated: false)
        
        // Setup table view
        routesTableView.delegate = self
        routesTableView.dataSource = self
        routesTableView.register(RouteTableViewCell.self, forCellReuseIdentifier: "RouteCell")
            
        // Setup search bar
        routesSearchBar.delegate = self
        
        routesSearchBar.searchBarStyle = .minimal  // Removes background
        routesSearchBar.backgroundImage = UIImage()
        
        // Hide search/filter when collapsed
        routesSearchBar.alpha = 0
        filterButton.alpha = 0
        routesTableView.alpha = 0
        
        //drop down for filter button
        setupFilterMenu()
    }
    
    private func setupFilterMenu() {
        //create menu items
        let showAllAction = UIAction (title: "All Routes", image: UIImage(systemName: "list.bullet")) { [weak self] _ in
            self?.showOnlyFavorites = false
            self?.filterByRouteType = nil
            self?.filterByScenicMode = nil
            self?.applyFiltersAndSort()
        }
        
        let favoritesAction = UIAction(title: "❤️ Favorites Only", image: UIImage(systemName: "heart.fill")) { [weak self] _ in
                self?.showOnlyFavorites = true
                self?.filterByRouteType = nil
                self?.filterByScenicMode = nil
                self?.applyFiltersAndSort()
            }
            
            let loopsAction = UIAction(title: "🔄 Loops Only", image: UIImage(systemName: "arrow.triangle.2.circlepath")) { [weak self] _ in
                self?.showOnlyFavorites = false
                self?.filterByRouteType = 2  // Loop = 2
                self?.filterByScenicMode = nil
                self?.applyFiltersAndSort()
            }
            
            let oneWayAction = UIAction(title: "➡️ One-Way Only", image: UIImage(systemName: "arrow.right")) { [weak self] _ in
                self?.showOnlyFavorites = false
                self?.filterByRouteType = 0  // One-Way = 0
                self?.filterByScenicMode = nil
                self?.applyFiltersAndSort()
            }
            
            let outBackAction = UIAction(title: "↔️ Out & Back Only", image: UIImage(systemName: "arrow.left.arrow.right")) { [weak self] _ in
                self?.showOnlyFavorites = false
                self?.filterByRouteType = 1  // Out & Back = 1
                self?.filterByScenicMode = nil
                self?.applyFiltersAndSort()
            }
            
            let scenicAction = UIAction(title: "🌳 Scenic Only", image: UIImage(systemName: "leaf.fill")) { [weak self] _ in
                self?.filterByScenicMode = true
                self?.applyFiltersAndSort()
            }
            
            let fastestAction = UIAction(title: "⚡ Fastest Only", image: UIImage(systemName: "bolt.fill")) { [weak self] _ in
                self?.filterByScenicMode = false
                self?.applyFiltersAndSort()
            }
            
            // === SORT OPTIONS ===
            
            let newestAction = UIAction(title: "📅 Newest First", image: UIImage(systemName: "calendar")) { [weak self] _ in
                self?.sortOption = .newestFirst
                self?.applyFiltersAndSort()
            }
            
            let oldestAction = UIAction(title: "📅 Oldest First", image: UIImage(systemName: "calendar.badge.clock")) { [weak self] _ in
                self?.sortOption = .oldestFirst
                self?.applyFiltersAndSort()
            }
            
            let shortestDistAction = UIAction(title: "📏 Shortest Distance", image: UIImage(systemName: "ruler")) { [weak self] _ in
                self?.sortOption = .shortestDistance
                self?.applyFiltersAndSort()
            }
            
            let longestDistAction = UIAction(title: "📏 Longest Distance", image: UIImage(systemName: "ruler.fill")) { [weak self] _ in
                self?.sortOption = .longestDistance
                self?.applyFiltersAndSort()
            }
            
            let shortestTimeAction = UIAction(title: "⏱️ Shortest Time", image: UIImage(systemName: "clock")) { [weak self] _ in
                self?.sortOption = .shortestTime
                self?.applyFiltersAndSort()
            }
            
            let longestTimeAction = UIAction(title: "⏱️ Longest Time", image: UIImage(systemName: "clock.fill")) { [weak self] _ in
                self?.sortOption = .longestTime
                self?.applyFiltersAndSort()
            }
            
            let nameAZAction = UIAction(title: "🔤 Name (A-Z)", image: UIImage(systemName: "textformat.abc")) { [weak self] _ in
                self?.sortOption = .nameAZ
                self?.applyFiltersAndSort()
            }
            
            let nameZAAction = UIAction(title: "🔤 Name (Z-A)", image: UIImage(systemName: "textformat.abc.dottedunderline")) { [weak self] _ in
                self?.sortOption = .nameZA
                self?.applyFiltersAndSort()
            }
            
            // Create menu sections
            let showMenu = UIMenu(title: "Show", options: .displayInline, children: [
                showAllAction,
                favoritesAction,
                loopsAction,
                oneWayAction,
                outBackAction,
                scenicAction,
                fastestAction
            ])
            
            let sortMenu = UIMenu(title: "Sort By", options: .displayInline, children: [
                newestAction,
                oldestAction,
                shortestDistAction,
                longestDistAction,
                shortestTimeAction,
                longestTimeAction,
                nameAZAction,
                nameZAAction
            ])
            
            // Combine into final menu
            let menu = UIMenu(title: "Filter & Sort", children: [showMenu, sortMenu])
            
            // Attach to button
            filterButton.menu = menu
            filterButton.showsMenuAsPrimaryAction = true
        }
     
    private func calculateRouteSheetHeight() {
        let screenHeight = self.view.bounds.height
        let headerMaxY = self.headerBox.frame.maxY
        let bottomHeight = self.bottomTabContainer.bounds.height
        // calc avaliable space
        // space below header
        let padding: CGFloat = 20
        self.routeSheetExpandedHeight = screenHeight - headerMaxY - bottomHeight - padding
            
        print("Screen: \(screenHeight), Header: \(headerMaxY), bottom: \(bottomHeight)")
        print("📐 Calculated expanded height: \(self.routeSheetExpandedHeight)")
        }
    }

// MARK: - Bottom Sheet State
private var bottomSheetState: BottomSheetState = .collapsed
private var bottomSheetCollapsedHeight: CGFloat = 100
private var bottomSheetExpandedHeight: CGFloat = 500

enum BottomSheetState {
    case collapsed  // Just shows "Go" and "Cancel" buttons
    case expanded   // Shows full route list
}


// MARK: - Slide Panel Setup
extension ViewController {
    private func setupSlidePanel() {
        let screenWidth = view.bounds.width
        let screenHeight = view.bounds.height
        slidePanel = UIView(frame: CGRect(x: screenWidth, y: 165, width: 184, height: screenHeight - 450))
        slidePanel.backgroundColor = .white
        view.addSubview(slidePanel)

        panelScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: slidePanel.frame.width, height: slidePanel.frame.height))
        panelScrollView.backgroundColor = .clear
        slidePanel.addSubview(panelScrollView)

        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: slidePanel.frame.width, height: 600))
        contentView.backgroundColor = .clear
        panelScrollView.addSubview(contentView)

        setupPanelContent(in: contentView)
    }

    private func setupPanelContent(in container: UIView) {
        let padding: CGFloat = 12
        let fieldWidth = container.frame.width - (padding * 2)
        var currentY: CGFloat = 20

        currentY = addClearSettingsButton(to: container, y: currentY, width: fieldWidth, padding: padding)
        currentY = addSectionHeader(to: container, text: "ROUTE STYLE", y: currentY, width: fieldWidth, padding: padding)
        currentY = addRoutingModeSelector(to: container, y: currentY, width: fieldWidth, padding: padding)
        currentY = addDivider(to: container, y: currentY, width: fieldWidth, padding: padding)

        currentY = addSectionHeader(to: container, text: "RANDOM GENERATION", y: currentY, width: fieldWidth, padding: padding)
        currentY = addDistanceInput(to: container, y: currentY, width: fieldWidth, padding: padding)
        currentY = addTimeToggle(to: container, y: currentY, width: fieldWidth, padding: padding)
        currentY = addDirectionGrid(to: container, y: currentY, width: fieldWidth)
        currentY = addDivider(to: container, y: currentY, width: fieldWidth, padding: padding)

        currentY = addSectionHeader(to: container, text: "LOOP OPTIONS", y: currentY, width: fieldWidth, padding: padding)
        currentY = addLoopPointControls(to: container, y: currentY, width: fieldWidth, padding: padding)

        panelScrollView.contentSize = CGSize(width: slidePanel.frame.width, height: currentY + 20)
    }

    private func addClearSettingsButton(to container: UIView, y: CGFloat, width: CGFloat, padding: CGFloat) -> CGFloat {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: padding, y: y, width: width, height: 36)
        button.setTitle("Clear Settings", for: .normal)
        button.backgroundColor = .systemRed.withAlphaComponent(0.1)
        button.setTitleColor(.systemRed, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(clearRandomSettings), for: .touchUpInside)
        container.addSubview(button)
        return y + 40
    }

    private func addSectionHeader(to container: UIView, text: String, y: CGFloat, width: CGFloat, padding: CGFloat) -> CGFloat {
        let label = UILabel(frame: CGRect(x: padding, y: y, width: width, height: 20))
        label.text = text
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = .systemGray
        container.addSubview(label)
        return y + 25
    }

    private func addRoutingModeSelector(to container: UIView, y: CGFloat, width: CGFloat, padding: CGFloat) -> CGFloat {
        let control = UISegmentedControl(items: ["Fastest", "Scenic"])
        control.selectedSegmentIndex = useScenicRouting ? 1 : 0
        control.addTarget(self, action: #selector(routeVibeSelector(_:)), for: .valueChanged)
        control.frame = CGRect(x: padding, y: y, width: width, height: 32)
        container.addSubview(control)
        return y + 45
    }

    private func addDistanceInput(to container: UIView, y: CGFloat, width: CGFloat, padding: CGFloat) -> CGFloat {
        var currentY = y
        let label = UILabel(frame: CGRect(x: padding, y: currentY, width: width, height: 20))
        label.text = "Distance (miles)"
        label.font = .systemFont(ofSize: 14)
        container.addSubview(label)
        distanceOrTimeLabel = label
        currentY += 25
        let field = UITextField(frame: CGRect(x: padding, y: currentY, width: width, height: 36))
        field.placeholder = "e.g. 3.1"
        field.borderStyle = .roundedRect
        field.keyboardType = .decimalPad
        field.delegate = self
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.items = [flexSpace, doneButton]
        field.inputAccessoryView = toolbar
        container.addSubview(field)
        distanceTextField = field
        return currentY + 45
    }

    private func addTimeToggle(to container: UIView, y: CGFloat, width: CGFloat, padding: CGFloat) -> CGFloat {
        let label = UILabel(frame: CGRect(x: padding, y: y, width: width - 50, height: 20))
        label.text = "Use Time Instead"
        label.font = .systemFont(ofSize: 13)
        container.addSubview(label)
        let toggle = UISwitch(frame: CGRect(x: width + padding - 51, y: y - 4, width: 51, height: 31))
        toggle.addTarget(self, action: #selector(timeToggleChanged(_:)), for: .valueChanged)
        container.addSubview(toggle)
        timeToggle = toggle
        return y + 40
    }

    private func addDirectionGrid(to container: UIView, y: CGFloat, width: CGFloat) -> CGFloat {
        var currentY = y
        let label = UILabel(frame: CGRect(x: 12, y: currentY, width: width - 24, height: 20))
        label.text = "Direction"
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        container.addSubview(label)
        currentY += 25
        let directions = [["NW", "N", "NE"], ["W", ".", "E"], ["SW", "S", "SE"]]
        let buttonSize: CGFloat = 44
        let gap: CGFloat = 4
        let gridWidth = (buttonSize * 3) + (gap * 2)
        let startX = (container.frame.width - gridWidth) / 2
        for row in 0..<3 {
            for col in 0..<3 {
                let title = directions[row][col]
                let button = UIButton(type: .system)
                button.frame = CGRect(x: startX + CGFloat(col) * (buttonSize + gap), y: currentY + CGFloat(row) * (buttonSize + gap), width: buttonSize, height: buttonSize)
                button.setTitle(title, for: .normal)
                button.setTitleColor(.black, for: .normal)
                button.backgroundColor = .systemGray3
                button.layer.cornerRadius = 8
                if title == "." {
                    button.setTitleColor(.clear, for: .normal)
                    button.isEnabled = false
                } else {
                    button.addTarget(self, action: #selector(directionButtonTapped(_:)), for: .touchUpInside)
                }
                container.addSubview(button)
            }
        }
        return currentY + 150
    }

    private func addLoopPointControls(to container: UIView, y: CGFloat, width: CGFloat, padding: CGFloat) -> CGFloat {
        var currentY = y
        let label = UILabel(frame: CGRect(x: padding, y: currentY, width: width, height: 20))
        label.text = "Loop Points: 4"
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.isEnabled = false
        container.addSubview(label)
        loopPointLabel = label
        currentY += 25
        let stepper = UIStepper(frame: CGRect(x: (container.frame.width - 94) / 2, y: currentY, width: 94, height: 29))
        stepper.minimumValue = 3
        stepper.maximumValue = 8
        stepper.value = 4
        stepper.isEnabled = false
        stepper.addTarget(self, action: #selector(loopPointStepperChanged(_:)), for: .valueChanged)
        container.addSubview(stepper)
        loopPointStepper = stepper
        return currentY + 40
    }

    private func addDivider(to container: UIView, y: CGFloat, width: CGFloat, padding: CGFloat) -> CGFloat {
        let divider = UIView(frame: CGRect(x: padding, y: y, width: width, height: 1))
        divider.backgroundColor = .systemGray4
        container.addSubview(divider)
        return y + 15
    }
}

// MARK: - IBActions
extension ViewController {
    @IBAction func showCoordinateEntry(_ sender: Any) { presentCoordinateEntryDialog() }

    @IBAction func settingsBTN(_ sender: UIButton) {
        resetSpeedData()
        printSavedRoutes()
        clearAllRoutesFromDatabase()
    }

    @IBAction func generateRouteBTN(_ sender: UIButton) {
        let config = buildRouteConfig()
        if let targetMiles = config.targetDistance {
            generateRandomRoute(config: config, targetMiles: targetMiles)
        } else {
            generateManualRoute(config: config)
        }
    }

    @IBAction func clearRouteBTN(_ sender: UIButton) { clearAllRoutes() }

    @IBAction func routeTypeChanged(_ sender: UISegmentedControl) { updateLoopControlsVisibility(isLoop: sender.selectedSegmentIndex == 2) }

    @IBAction func routeVibeSelector(_ sender: UISegmentedControl) {
        useScenicRouting = (sender.selectedSegmentIndex == 1)
        regenerateCurrentRoute()
    }

    @IBAction func recenterBTN(_ sender: UIButton) { toggleFollowUser(button: sender) }

    @IBAction func routeSettingsBTNTapped(_ sender: UIButton) {
        animateSettingsCog(sender)
        isPanelOpen ? closePanel() : openPanel()
    }
}

// MARK: - Route Building
extension ViewController {
    private func buildRouteConfig() -> RouteConfig {
        let type = RouteConfig.RouteType(rawValue: routeTypeSelector.selectedSegmentIndex) ?? .oneWay
        return RouteConfig(type: type, isScenic: useScenicRouting, waypoints: selectedCoordinates, targetDistance: getUserInputMiles(), direction: selectedDirection)
    }

    private func generateRandomRoute(config: RouteConfig, targetMiles: Double) {
        clearPinsAndOverlays()
        let center = determineStartLocation()
        let waypoints = generateWaypoints(for: config, center: center, targetMiles: targetMiles)
        selectedCoordinates = waypoints
        placeAnnotations(for: waypoints, routeType: config.type)
        requestRoutes(for: waypoints, config: config)
    }

    private func generateManualRoute(config: RouteConfig) {
        guard validatePinCount(for: config.type) else { return }
        requestRoutes(for: config.waypoints, config: config)
    }

    private func generateWaypoints(for config: RouteConfig, center: CLLocationCoordinate2D, targetMiles: Double) -> [CLLocationCoordinate2D] {
        switch config.type {
        case .oneWay, .outAndBack:
            let radius = calculateRadius(targetMiles: targetMiles, windingFactor: 2.5)
            let endpoint = generateRandomCoordinate(around: center, radius: radius, direction: config.direction ?? "random")
            return [center, endpoint]
        case .loop:
            let targetMeters = targetMiles * 1609.34
            let averageRadius = targetMeters / (Double(selectedLoopPoints) * 1.8)
            return generateLoopPoints(count: selectedLoopPoints, center: center, averageRadius: averageRadius, direction: config.direction ?? "random")
        }
    }

    private func calculateRadius(targetMiles: Double, windingFactor: Double) -> Double { (targetMiles * 1609.34) / (2 * .pi * windingFactor) }
}

// MARK: - Core Route Request
extension ViewController {
    private func requestRoutes(for waypoints: [CLLocationCoordinate2D], config: RouteConfig) {
        guard !isGeneratingRoute else { return }
        isGeneratingRoute = true
        if config.targetDistance != nil { mapView.removeOverlays(mapView.overlays) }
        switch config.type {
        case .oneWay:
            requestSingleLeg(from: waypoints[0], to: waypoints[1], config: config, targetMiles: config.targetDistance)
        case .outAndBack:
            requestSingleLeg(from: waypoints[0], to: waypoints[1], config: config, targetMiles: config.targetDistance, isOutAndBack: true)
        case .loop:
            requestMultiLegLoop(waypoints: waypoints, config: config, targetMiles: config.targetDistance)
        }
    }

    private func requestSingleLeg(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D, config: RouteConfig, targetMiles: Double?, isOutAndBack: Bool = false, retryCount: Int = 0) {
        let request = buildDirectionsRequest(from: start, to: end, requestAlternates: config.isScenic)
        MKDirections(request: request).calculate { [weak self] response, error in
            guard let self = self else { return }
            if let error = error { self.showErrorAlert(message: "Route failed: \(error.localizedDescription)"); self.isGeneratingRoute = false; return }
            guard let routes = response?.routes, !routes.isEmpty else { self.isGeneratingRoute = false; return }
            let selectedRoute = config.isScenic ? self.pickScenicRoute(from: routes) : routes[0]
            if let targetMiles = targetMiles, retryCount < 4 {
                let actualDistance = isOutAndBack ? selectedRoute.distance * 2 : selectedRoute.distance
                let targetMeters = targetMiles * 1609.34
                let ratio = actualDistance / targetMeters
                if abs(ratio - 1.0) > 0.25 {
                    let currentDistance = CLLocation(latitude: start.latitude, longitude: start.longitude).distance(from: CLLocation(latitude: end.latitude, longitude: end.longitude))
                    let adjustedRadius = currentDistance / ratio
                    let newEndpoint = self.generateRandomCoordinate(around: start, radius: adjustedRadius, direction: config.direction ?? "random")
                    DispatchQueue.main.async { self.requestSingleLeg(from: start, to: newEndpoint, config: config, targetMiles: targetMiles, isOutAndBack: isOutAndBack, retryCount: retryCount + 1) }
                    return
                }
            }
            self.drawSingleLegRoute(selectedRoute, isOutAndBack: isOutAndBack, config: config)
        }
    }

    private func drawSingleLegRoute(_ route: MKRoute, isOutAndBack: Bool, config: RouteConfig) {
        let coords = getCoordinates(from: route.polyline)
        var allCoords = coords
        var totalDistance = route.distance
        var totalTime = route.expectedTravelTime
        DispatchQueue.main.async {
            self.mapView.addOverlay(route.polyline)
            if isOutAndBack {
                let backward = Array(coords.reversed())
                let backwardPolyline = StyledPolyline(coordinates: backward, count: backward.count)
                backwardPolyline.kind = .backward
                self.mapView.addOverlay(backwardPolyline)
                allCoords += backward
                totalDistance *= 2
                totalTime *= 2
            }
            self.finishRouteGeneration(coordinates: allCoords, totalDistance: totalDistance, totalTime: totalTime, config: config)
        }
    }

    private func requestMultiLegLoop(waypoints: [CLLocationCoordinate2D], config: RouteConfig, targetMiles: Double? = nil, retryCount: Int = 0) {
        var totalDistance: CLLocationDistance = 0
        var totalTime: TimeInterval = 0
        let n = waypoints.count
        
        func requestLeg(at index: Int) {
            if index >= n {
                var allCoords: [CLLocationCoordinate2D] = []
                for overlay in self.mapView.overlays {
                    if let sp = overlay as? StyledPolyline {
                        allCoords.append(contentsOf: self.getCoordinates(from: sp))
                    }
                }
                
                //CHECK IF WE NEED TO RETRY
                if let targetMiles = targetMiles, retryCount < 3 {
                    let actualMiles = totalDistance / 1609.34
                    let ratio = actualMiles / targetMiles
                    
                    if abs(ratio - 1.0) > 0.25 {  // More than 25% off
                        print("Loop retry \(retryCount + 1): Got \(String(format: "%.2f", actualMiles))mi, wanted \(String(format: "%.2f", targetMiles))mi")
                        
                        // Clear current overlays
                        self.mapView.removeOverlays(self.mapView.overlays)
                        
                        // Adjust radius and regenerate
                        let currentAvgRadius = CLLocation(latitude: waypoints[0].latitude, longitude: waypoints[0].longitude)
                            .distance(from: CLLocation(latitude: waypoints[1].latitude, longitude: waypoints[1].longitude))
                        
                        let adjustedRadius = currentAvgRadius / ratio
                        
                        let newWaypoints = self.generateLoopPoints(
                            count: waypoints.count,
                            center: waypoints[0],  // Keep same start
                            averageRadius: adjustedRadius,
                            direction: config.direction ?? "random"
                        )
                        
                        // Update pins
                        self.mapView.removeAnnotations(self.mapView.annotations.filter { !($0 is MKUserLocation) })
                        self.selectedCoordinates = newWaypoints
                        self.placeAnnotations(for: newWaypoints, routeType: .loop)
                        
                        // Retry with new waypoints
                        DispatchQueue.main.async {
                            self.requestMultiLegLoop(waypoints: newWaypoints, config: config, targetMiles: targetMiles, retryCount: retryCount + 1)
                        }
                        return
                    }
                }
                
                self.finishRouteGeneration(coordinates: allCoords, totalDistance: totalDistance, totalTime: totalTime, config: config)
                return
            }
            
            let start = waypoints[index]
            let end = waypoints[(index + 1) % n]
            let request = buildDirectionsRequest(from: start, to: end, requestAlternates: config.isScenic)
            MKDirections(request: request).calculate { [weak self] response, error in
                guard let self = self else { return }
                if let error = error {
                    self.showErrorAlert(message: "Leg \(index + 1) failed: \(error.localizedDescription)")
                    self.isGeneratingRoute = false
                    return
                }
                guard let routes = response?.routes, !routes.isEmpty else {
                    self.isGeneratingRoute = false
                    return
                }
                let selectedRoute = config.isScenic ? self.pickScenicRoute(from: routes) : routes[0]
                DispatchQueue.main.async {
                    let coords = self.getCoordinates(from: selectedRoute.polyline)
                    let styled = StyledPolyline(coordinates: coords, count: coords.count)
                    styled.legIndex = index
                    styled.mode = config.isScenic ? .scenic : .fastest
                    self.mapView.addOverlay(styled)
                }
                totalDistance += selectedRoute.distance
                totalTime += selectedRoute.expectedTravelTime
                requestLeg(at: index + 1)
            }
        }
        requestLeg(at: 0)
    }

    private func buildDirectionsRequest(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D, requestAlternates: Bool) -> MKDirections.Request {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: end))
        request.transportType = .walking
        request.requestsAlternateRoutes = requestAlternates
        return request
    }
}

// MARK: - Route Completion
extension ViewController {
    private func finishRouteGeneration(coordinates: [CLLocationCoordinate2D], totalDistance: CLLocationDistance, totalTime: TimeInterval, config: RouteConfig) {
        updateRouteInfoLabel(distance: totalDistance, time: totalTime)
        resetProgressTracking(totalDistance: totalDistance, routeCoords: coordinates)
        isActivelyWalkingRoute = true
        isGeneratingRoute = false
        currentRouteType = config.type
        saveRouteToDatabase(coordinates: coordinates, totalDistance: totalDistance, config: config)
    }

    private func saveRouteToDatabase(coordinates: [CLLocationCoordinate2D], totalDistance: CLLocationDistance, config: RouteConfig) {
        CoreDataManager.shared.saveRoute(
            routeType: config.type.rawValue,
            isScenicMode: config.isScenic,
            targetDistance: totalDistance / 1609.34,
            direction: config.direction,
            waypoints: selectedCoordinates,
            fullRoute: coordinates
        )
    }
}

// MARK: - Route Utilities
extension ViewController {
    private func pickScenicRoute(from routes: [MKRoute]) -> MKRoute {
        guard let fastest = routes.min(by: { $0.expectedTravelTime < $1.expectedTravelTime }) else { return routes[0] }
        let fastestDistance = fastest.distance
        struct ScoredRoute { let route: MKRoute; let score: Double }
        let scored = routes.map { route -> ScoredRoute in
            let lengthRatio = min(route.distance / max(fastestDistance, 1.0), 2.0)
            let speedScore = 1.0 / max(route.distance / max(route.expectedTravelTime, 1.0), 1.0)
            let combinedScore = (lengthRatio * 0.9) + (speedScore * 0.1)
            return ScoredRoute(route: route, score: combinedScore)
        }
        return scored.filter { $0.route.distance <= fastestDistance * 2.0 }.max(by: { $0.score < $1.score })?.route ?? fastest
    }

    private func getCoordinates(from polyline: MKPolyline) -> [CLLocationCoordinate2D] {
        let points = polyline.points()
        return (0..<polyline.pointCount).map { points[$0].coordinate }
    }

    private func updateRouteInfoLabel(distance: CLLocationDistance, time: TimeInterval) {
        let miles = distance / 1609.34
        let minutes = time / 60.0
        routeInfoLabel.text = String(format: "%.2f miles • ~%.0f min", miles, minutes)
    }
}

// MARK: - Random Coordinate Generation
extension ViewController {
    private func generateRandomCoordinate(around center: CLLocationCoordinate2D, radius: Double, direction: String) -> CLLocationCoordinate2D {
        let range = angleRangeForDirection(direction)
        let randomAngle = direction == "N" ? (Bool.random() ? Double.random(in: 337.5...360.0) : Double.random(in: 0.0...22.5)) : Double.random(in: range)
        let randomAngleRadians = randomAngle * (.pi / 180)
        let randomDistance = Double.random(in: (0.7 * radius)...radius)
        let earthRadius = 6371000.0
        let latOffset = (randomDistance * cos(randomAngleRadians)) / earthRadius
        let centerLatRadians = center.latitude * (.pi / 180)
        let longOffset = (randomDistance * sin(randomAngleRadians)) / (earthRadius * cos(centerLatRadians))
        let newLatitude = center.latitude + (latOffset * (180 / .pi))
        let newLongitude = center.longitude + (longOffset * (180 / .pi))
        return CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude)
    }

    private func generateLoopPoints(count: Int, center: CLLocationCoordinate2D, averageRadius: Double, direction: String) -> [CLLocationCoordinate2D] {
        var points = [center]
        for _ in 1..<count {
            let radiusVariation = Double.random(in: 0.7...1.3)
            let pointRadius = averageRadius * radiusVariation
            let point = generateRandomCoordinate(around: center, radius: pointRadius, direction: direction)
            points.append(point)
        }
        return points
    }

    private func angleRangeForDirection(_ direction: String) -> ClosedRange<Double> {
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
}

// MARK: - Progress Tracking
extension ViewController {
    private func resetProgressTracking(totalDistance: CLLocationDistance, routeCoords: [CLLocationCoordinate2D]) {
        totalRouteDistance = totalDistance
        currentRouteCoordinates = routeCoords
        traveledDistance = 0
        prepareSnapToRouteData(from: routeCoords)
        let oldOverlays = mapView.overlays.compactMap { overlay -> MKOverlay? in
            guard let styled = overlay as? StyledPolyline else { return nil }
            return (styled.kind == .walked || styled.kind == .remaining) ? overlay : nil
        }
        mapView.removeOverlays(oldOverlays)
        DispatchQueue.main.async { self.progressView.setProgress(0, animated: true) }
    }

    private func prepareSnapToRouteData(from coords: [CLLocationCoordinate2D]) {
        routeSegments = coords
        cumulativeSegmentLengths = Array(repeating: 0, count: coords.count)
        guard coords.count >= 2 else { return }
        var runningDistance: CLLocationDistance = 0
        for i in 1..<coords.count {
            let a = CLLocation(latitude: coords[i-1].latitude, longitude: coords[i-1].longitude)
            let b = CLLocation(latitude: coords[i].latitude, longitude: coords[i].longitude)
            runningDistance += a.distance(from: b)
            cumulativeSegmentLengths[i] = runningDistance
        }
    }

    private func updateProgress(with location: CLLocation) {
        guard !currentRouteCoordinates.isEmpty, totalRouteDistance > 0 else { return }
        if let snappedDistance = calculateSnappedProgress(for: location) {
            traveledDistance = snappedDistance
            let progress = Float(min(max(traveledDistance / totalRouteDistance, 0), 1))
            DispatchQueue.main.async { self.progressView.setProgress(progress, animated: true) }
        }
        
        if currentRouteType != .loop{
            updateWalkedOverlay()
        }
        updateLiveRouteInfo()
    }
    
    private func updateWalkedOverlay() {
        // Remove old walked/remaining overlays
        let oldOverlays = mapView.overlays.compactMap { overlay -> MKOverlay? in
            guard let styled = overlay as? StyledPolyline else { return nil }
            return (styled.kind == .walked || styled.kind == .remaining) ? overlay : nil
        }
        mapView.removeOverlays(oldOverlays)
        
        guard currentRouteCoordinates.count > 1 else { return }
        
        // Find nearest point on route
        var closestIndex = 0
        var closestDistance = CLLocationDistance.greatestFiniteMagnitude
        guard let userLoc = userLocation else { return }
        let location = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
        
        for (index, coord) in currentRouteCoordinates.enumerated() {
            let routePoint = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            let distance = location.distance(from: routePoint)
            if distance < closestDistance {
                closestDistance = distance
                closestIndex = index
            }
        }
        
        guard closestIndex < currentRouteCoordinates.count else { return }
        
        // Create walked and remaining segments
        let walkedCoords = Array(currentRouteCoordinates[0...closestIndex])
        let remainingCoords = Array(currentRouteCoordinates[closestIndex...])
        
        let walkedLine = StyledPolyline(coordinates: walkedCoords, count: walkedCoords.count)
        walkedLine.kind = .walked
        
        let remainingLine = StyledPolyline(coordinates: remainingCoords, count: remainingCoords.count)
        remainingLine.kind = .remaining
        
        DispatchQueue.main.async {
            self.mapView.addOverlay(walkedLine)
            self.mapView.addOverlay(remainingLine)
        }
    }

    private func calculateSnappedProgress(for location: CLLocation) -> CLLocationDistance? {
        guard routeSegments.count >= 2 else { return nil }
        var bestDistance: CLLocationDistance = 0
        var bestDistanceToSegment = CLLocationDistance.greatestFiniteMagnitude
        for i in 1..<routeSegments.count {
            let p0 = routeSegments[i-1]
            let p1 = routeSegments[i]
            let a = MKMapPoint(p0)
            let b = MKMapPoint(p1)
            let p = MKMapPoint(location.coordinate)
            let ab = CGPoint(x: b.x - a.x, y: b.y - a.y)
            let ap = CGPoint(x: p.x - a.x, y: p.y - a.y)
            let abLengthSquared = (ab.x * ab.x) + (ab.y * ab.y)
            guard abLengthSquared > 0 else { continue }
            var t = ((ap.x * ab.x) + (ap.y * ab.y)) / abLengthSquared
            t = max(0, min(1, t))
            let projection = CGPoint(x: a.x + ab.x * t, y: a.y + ab.y * t)
            let dx = projection.x - p.x
            let dy = projection.y - p.y
            let distanceToSegment = sqrt(dx*dx + dy*dy)
            if distanceToSegment < bestDistanceToSegment {
                bestDistanceToSegment = distanceToSegment
                let upToPreviousPoint = cumulativeSegmentLengths[i-1]
                let segmentStart = CLLocation(latitude: p0.latitude, longitude: p0.longitude)
                let projectedCoord = MKMapPoint(x: projection.x, y: projection.y).coordinate
                let projectedLocation = CLLocation(latitude: projectedCoord.latitude, longitude: projectedCoord.longitude)
                let partialSegmentDistance = segmentStart.distance(from: projectedLocation)
                bestDistance = upToPreviousPoint + partialSegmentDistance
            }
        }
        return bestDistance
    }

    private func updateLiveRouteInfo() {
        guard totalRouteDistance > 0 else { return }
        let remainingMeters = max(0, totalRouteDistance - traveledDistance)
        let remainingMiles = remainingMeters / 1609.34
        let speedMPH = walkSampleCount >= 10 ? avgWalkingSpeed * 2.23694 : 3.5
        let remainingMinutes = (remainingMiles / speedMPH) * 60
        DispatchQueue.main.async { self.routeInfoLabel.text = String(format: "%.2f mi left • ~%.0f min", remainingMiles, remainingMinutes) }
    }
}

// MARK: - Route History Sheet Helpers
extension ViewController {
    private func expandRouteSheet() {
        setRouteSheetHeight(routeSheetExpandedHeight, animated: true)
        routeSheetState = .expanded
        
        // Show search/filter
        UIView.animate(withDuration: 0.2) {
            self.routesSearchBar.alpha = 1
            self.filterButton.alpha = 1
            self.routesTableView.alpha = 1
        }
        loadSavedRoutes()
    }

    private func collapseRouteSheet() {
        setRouteSheetHeight(routeSheetCollapsedHeight, animated: true)
        routeSheetState = .collapsed
        
        // Hide search/filter
        UIView.animate(withDuration: 0.2) {
            self.routesSearchBar.alpha = 0
            self.filterButton.alpha = 0
        }
        
        // Dismiss keyboard
        routesSearchBar.resignFirstResponder()
    }

    private func setRouteSheetHeight(_ height: CGFloat, animated: Bool) {
        // Find the height constraint
        for constraint in routeHistorySheet.constraints {
            if constraint.firstAttribute == .height {
                constraint.constant = height
                break
            }
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                self.view.layoutIfNeeded()
            }
        } else {
            view.layoutIfNeeded()
        }
    }

    @objc private func handleRouteSheetPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state {
        case .changed:
            let newHeight = routeHistorySheet.frame.height - translation.y
            let clampedHeight = max(routeSheetCollapsedHeight, min(routeSheetExpandedHeight, newHeight))
            setRouteSheetHeight(clampedHeight, animated: false)
            gesture.setTranslation(.zero, in: view)
            
            
        case .ended:
            if velocity.y < -500 {             // Smaller # = harder   (open)
                expandRouteSheet()
            } else if velocity.y > 500 {      // bigger # = harder (close)
                collapseRouteSheet()
            } else {
                let midpoint = (routeSheetCollapsedHeight + routeSheetExpandedHeight) / 2
                if routeHistorySheet.frame.height > midpoint {
                    expandRouteSheet()
                } else {
                    collapseRouteSheet()
                }
            }
            
        default:
            break
        }
    }
    
    @objc private func handlePillTap() {
        if routeSheetState == .collapsed {
            expandRouteSheet()
        } else {
            collapseRouteSheet()
        }
    }
}

// MARK: - Map Helpers
extension ViewController {
    private func clearAllRoutes() {
        selectedCoordinates.removeAll()
        isGeneratingRoute = false
        isActivelyWalkingRoute = false
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })
        resetProgressTracking(totalDistance: 0, routeCoords: [])
        progressView.setProgress(0, animated: false)
    }

    private func clearPinsAndOverlays() {
        selectedCoordinates.removeAll()
        mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })
        mapView.removeOverlays(mapView.overlays)
    }

    private func placeAnnotations(for waypoints: [CLLocationCoordinate2D], routeType: RouteConfig.RouteType) {
        for (index, coordinate) in waypoints.enumerated() {
            let label: String
            if index == 0 { label = "Start" }
            else if routeType == .loop {
                let base = 64 + index
                label = UnicodeScalar(base).map { String($0) } ?? "P\(index)"
            } else { label = "End" }
            addAnnotation(at: coordinate, title: label, index: index)
        }
    }

    private func addAnnotation(at coordinate: CLLocationCoordinate2D, title: String, index: Int) {
        let annotation = RouteAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        annotation.index = index
        mapView.addAnnotation(annotation)
    }

    private func safelyCenterMap(on coordinate: CLLocationCoordinate2D, distance: CLLocationDistance = 10000) {
        let camera = MKMapCamera(lookingAtCenter: coordinate, fromDistance: max(100, distance), pitch: 0, heading: 0)
        mapView.setCamera(camera, animated: true)
    }

    private func determineStartLocation() -> CLLocationCoordinate2D { isFollowingUser ? (userLocation ?? CLLocationCoordinate2D(latitude: 40.2022, longitude: -93.1252)) : (userLocation ?? CLLocationCoordinate2D(latitude: 40.2022, longitude: -93.1252)) }

    private func validatePinCount(for type: RouteConfig.RouteType) -> Bool {
        let required = type == .loop ? 3 : 2
        guard selectedCoordinates.count >= required else { showInfoAlert(message: "Please place \(required) pins"); return false }
        return true
    }

    private func regenerateCurrentRoute() {
        guard !selectedCoordinates.isEmpty else { return }
        mapView.removeOverlays(mapView.overlays)
        let config = buildRouteConfig()
        requestRoutes(for: selectedCoordinates, config: config)
    }

    private func updateLoopControlsVisibility(isLoop: Bool) {
        loopPointStepper?.isEnabled = isLoop
        loopPointLabel?.isEnabled = isLoop
        loopPointStepper?.alpha = isLoop ? 1.0 : 0.4
        loopPointLabel?.alpha = isLoop ? 1.0 : 0.4
    }

    private func toggleFollowUser(button: UIButton) {
        isFollowingUser.toggle()
        if isFollowingUser {
            button.setImage(UIImage(systemName: "location.fill"), for: .normal)
            button.tintColor = .systemBlue
            if let location = userLocation { safelyCenterMap(on: location, distance: 3000) }
        } else {
            button.setImage(UIImage(systemName: "location"), for: .normal)
            button.tintColor = .systemGray
        }
    }

    private func animateSettingsCog(_ button: UIButton) {
        UIView.animate(withDuration: 0.3) { button.transform = CGAffineTransform(rotationAngle: .pi) } completion: { _ in button.transform = .identity }
    }

    private func openPanel() { UIView.animate(withDuration: 0.3) { self.slidePanel.frame.origin.x = self.view.bounds.width - 184 }; isPanelOpen = true }
    private func closePanel() { UIView.animate(withDuration: 0.3) { self.slidePanel.frame.origin.x = self.view.bounds.width }; isPanelOpen = false }
}

// MARK: - Input Helpers
extension ViewController {
    private func getUserInputMiles() -> Double? {
        guard let text = distanceTextField?.text, !text.isEmpty, let value = Double(text) else { return nil }
        if useTimeInput {
            let walkingSpeedMPH: Double
            if walkSampleCount >= 10 {
                walkingSpeedMPH = avgWalkingSpeed * 2.23694 //converting m/s to mph
            } else {
                walkingSpeedMPH = 3.5
            }
            return (value/60.0) * walkingSpeedMPH
        }
        return value
    }
}

// MARK: - @objc Handlers
extension ViewController {
    @objc private func handleMapTap(_ gesture: UITapGestureRecognizer) {
        let coordinate = mapView.convert(gesture.location(in: mapView), toCoordinateFrom: mapView)
        let routeType = RouteConfig.RouteType(rawValue: routeTypeSelector.selectedSegmentIndex) ?? .oneWay
        if isFollowingUser && selectedCoordinates.isEmpty, let userLoc = userLocation { selectedCoordinates.append(userLoc); addAnnotation(at: userLoc, title: "Start", index: 0) }
        if routeType != .loop && selectedCoordinates.count >= 2 { showInfoAlert(message: "You already have 2 pins. Tap Clear to reset."); return }
        selectedCoordinates.append(coordinate)
        let label: String
        if selectedCoordinates.count == 1 { label = "Start" }
        else if routeType == .loop { let base = 64 + selectedCoordinates.count; label = UnicodeScalar(base).map { String($0) } ?? "P\(selectedCoordinates.count)" }
        else { label = "End" }
        addAnnotation(at: coordinate, title: label, index: selectedCoordinates.count - 1)
    }

    @objc private func timeToggleChanged(_ sender: UISwitch) {
        useTimeInput = sender.isOn
        distanceOrTimeLabel?.text = sender.isOn ? "Time (min)" : "Distance (miles)"
        distanceTextField?.placeholder = sender.isOn ? "e.g. 30" : "e.g. 3.1"
        distanceTextField?.text = ""
    }

    @objc private func directionButtonTapped(_ sender: UIButton) {
        guard let direction = sender.title(for: .normal) else { return }
        selectedDirectionButton?.backgroundColor = .systemGray3
        selectedDirectionButton?.setTitleColor(.black, for: .normal)
        if selectedDirectionButton == sender { selectedDirectionButton = nil; selectedDirection = "random"; return }
        sender.backgroundColor = .appPrimary
        sender.setTitleColor(.black, for: .normal)
        selectedDirectionButton = sender
        selectedDirection = direction
    }

    @objc private func loopPointStepperChanged(_ sender: UIStepper) { selectedLoopPoints = Int(sender.value); loopPointLabel?.text = "Loop Points: \(selectedLoopPoints)" }

    @objc private func clearRandomSettings() {
        distanceTextField?.text = ""
        selectedDirectionButton?.backgroundColor = .systemGray3
        selectedDirectionButton?.setTitleColor(.black, for: .normal)
        selectedDirectionButton = nil
        selectedDirection = "random"
        useTimeInput = false
        distanceOrTimeLabel?.text = "Distance (miles)"
        distanceTextField?.placeholder = "e.g. 3.1"
        timeToggle?.setOn(false, animated: true)
    }

    @objc private func dismissKeyboard() { view.endEditing(true); closePanel() }

    private func presentCoordinateEntryDialog() {
        let alert = UIAlertController(title: "Enter Coordinates", message: "Enter Latitude and Longitude", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Latitude (-90 to 90)"; $0.keyboardType = .numbersAndPunctuation }
        alert.addTextField { $0.placeholder = "Longitude (-180 to 180)"; $0.keyboardType = .numbersAndPunctuation }
        let goAction = UIAlertAction(title: "Go", style: .default) { [weak self] _ in
            guard let self = self,
                  let latText = alert.textFields?[0].text, !latText.isEmpty,
                  let longText = alert.textFields?[1].text, !longText.isEmpty,
                  let lat = Double(latText), let long = Double(longText),
                  lat >= -90, lat <= 90, long >= -180, long <= 180 else {
                self?.showErrorAlert(message: "Invalid coordinates"); return }
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            self.safelyCenterMap(on: coordinate, distance: 10000)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(goAction)
        present(alert, animated: true)
    }
}

// MARK: - Speed Learning
extension ViewController {
    private func updateSpeedAverages(speed: CLLocationSpeed) {
        guard speed > 0 else { return }
        enum SpeedCategory { case walking, jogging, running }
        let category: SpeedCategory
        switch speed { case ..<2.0: category = .walking; case 2.0..<3.5: category = .jogging; default: category = .running }
        switch category {
        case .walking:
            avgWalkingSpeed = ((avgWalkingSpeed * Double(walkSampleCount)) + speed) / Double(walkSampleCount + 1)
            walkSampleCount += 1
        case .jogging:
            avgJoggingSpeed = ((avgJoggingSpeed * Double(jogSampleCount)) + speed) / Double(jogSampleCount + 1)
            jogSampleCount += 1
        case .running:
            avgRunningSpeed = ((avgRunningSpeed * Double(runSampleCount)) + speed) / Double(runSampleCount + 1)
            runSampleCount += 1
        }
        let totalSamples = walkSampleCount + jogSampleCount + runSampleCount
        if totalSamples % 10 == 0 { saveSpeeds() }
    }

    private func loadSavedSpeeds() {
        let defaults = UserDefaults.standard
        if defaults.double(forKey: "avgWalkingSpeed") > 0 { avgWalkingSpeed = defaults.double(forKey: "avgWalkingSpeed"); walkSampleCount = defaults.integer(forKey: "walkSampleCount") }
        if defaults.double(forKey: "avgJoggingSpeed") > 0 { avgJoggingSpeed = defaults.double(forKey: "avgJoggingSpeed"); jogSampleCount = defaults.integer(forKey: "jogSampleCount") }
        if defaults.double(forKey: "avgRunningSpeed") > 0 { avgRunningSpeed = defaults.double(forKey: "avgRunningSpeed"); runSampleCount = defaults.integer(forKey: "runSampleCount") }
    }

    private func saveSpeeds() {
        let defaults = UserDefaults.standard
        defaults.set(avgWalkingSpeed, forKey: "avgWalkingSpeed")
        defaults.set(avgJoggingSpeed, forKey: "avgJoggingSpeed")
        defaults.set(avgRunningSpeed, forKey: "avgRunningSpeed")
        defaults.set(walkSampleCount, forKey: "walkSampleCount")
        defaults.set(jogSampleCount, forKey: "jogSampleCount")
        defaults.set(runSampleCount, forKey: "runSampleCount")
    }

    private func resetSpeedData() {
        avgWalkingSpeed = 1.4
        avgJoggingSpeed = 2.7
        avgRunningSpeed = 4.0
        walkSampleCount = 50
        jogSampleCount = 50
        runSampleCount = 50
        saveSpeeds()
        showInfoAlert(message: "Speed data reset to defaults")
    }
}

// MARK: - Debug Helpers
extension ViewController {
    private func printSavedRoutes() {
        let routes = CoreDataManager.shared.fetchAllRoutes()
        print("Total saved routes: \(routes.count)")
        for route in routes { print("  - \(route.targetDistance) miles, created \(String(describing: route.createdDate))") }
    }
}

// MARK: - Alerts
extension ViewController {
    private func showInfoAlert(title: String = "Info", message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }

    private func showErrorAlert(title: String = "Error", message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .destructive))
            self.present(alert, animated: true)
        }
    }
}

// MARK: - MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let styled = overlay as? StyledPolyline {
            let renderer = MKPolylineRenderer(polyline: styled)
            switch styled.kind {
            case .walked:
                renderer.strokeColor = UIColor.appPrimary
                renderer.lineWidth = 5
            case .remaining:
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 5
            case .forward, .backward:
                let colors: [UIColor] = [.systemBlue, .systemGreen, .systemOrange, .systemPurple, .systemRed, .systemTeal, .systemPink, .brown]
                renderer.strokeColor = colors[styled.legIndex % colors.count]
                renderer.lineWidth = styled.mode == .scenic ? 6 : 5
                if styled.kind == .backward { renderer.lineDashPattern = [2, 5] }
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

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        let identifier = "PinAnnotation"
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        if view == nil {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view?.isDraggable = true
            view?.canShowCallout = true
        } else { view?.annotation = annotation }
        return view
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        guard newState == .ending, let annotation = view.annotation as? RouteAnnotation, annotation.index < selectedCoordinates.count else { return }
        selectedCoordinates[annotation.index] = annotation.coordinate
        mapView.removeOverlays(mapView.overlays)
        let config = buildRouteConfig()
        requestRoutes(for: selectedCoordinates, config: config)
        
    }
}

// MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location.coordinate
        if isActivelyWalkingRoute { updateProgress(with: location) }
        updateSpeedAverages(speed: location.speed)
        if !hasAlreadyCentered { safelyCenterMap(on: location.coordinate, distance: 10000); hasAlreadyCentered = true }
        else if isFollowingUser { safelyCenterMap(on: location.coordinate, distance: 3000) }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways: locationManager.startUpdatingLocation()
        case .denied, .restricted: showInfoAlert(message: "Location access denied - using default location")
        default: break
        }
    }
}

// MARK: - UITextFieldDelegate
extension ViewController: UITextFieldDelegate { }

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredRoutes.isEmpty {
            // Show placeholder when no routes
            return 1
        }
        return filteredRoutes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RouteCell", for: indexPath) as! RouteTableViewCell

        // Placeholder when no routes
        if filteredRoutes.isEmpty {
            cell.textLabel?.text = "No saved routes yet"
            cell.textLabel?.textColor = .systemGray
            cell.detailTextLabel?.text = nil
            cell.selectionStyle = .none
            cell.moreButton.isHidden = true
            // Also reset transforms to avoid leaked reveal state
            cell.editButton.transform = .identity
            cell.deleteButton.transform = .identity
            cell.moreButton.transform = .identity
            cell.textLabel?.transform = .identity
            cell.detailTextLabel?.transform = .identity
            return cell
        }

        // Real route
        let route = filteredRoutes[indexPath.row]

        // Reset reusable state in case this cell was previously used as placeholder
        cell.moreButton.isHidden = false
        // Ensure action buttons and labels are back to default positions
        cell.editButton.transform = .identity
        cell.deleteButton.transform = .identity
        cell.moreButton.transform = .identity
        cell.textLabel?.transform = .identity
        cell.detailTextLabel?.transform = .identity

        // Format the cell
        let routeName = route.name ?? "Route \(indexPath.row + 1)"
        let distance = String(format: "%.2f mi", route.targetDistance)

        let routeTypeText: String
        switch route.routeType {
        case 0: routeTypeText = "One-Way"
        case 1: routeTypeText = "Out & Back"
        case 2: routeTypeText = "Loop"
        default: routeTypeText = ""
        }

        let modeText = route.isScenicMode ? "🌳 Scenic" : "⚡️ Fastest"

        // Format date
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        let dateText = route.createdDate.map { formatter.string(from: $0) } ?? ""

        // Set cell text
        cell.textLabel?.text = "\(routeName) • \(distance)"
        cell.detailTextLabel?.text = "\(routeTypeText) • \(modeText) • \(dateText)"
        cell.textLabel?.textColor = .label
        cell.selectionStyle = .default
        cell.detailTextLabel?.font = .systemFont(ofSize: 12)

        // Actions
        cell.deleteAction = { [weak self] in
            self?.confirmDeleteRoute(at: indexPath)
        }
        cell.editAction = { [weak self] in
            self?.renameRoute(at: indexPath)
        }
        
        cell.favoriteAction = { [weak self] in
            self?.toggleFavorite(at: indexPath)
        }
        cell.updateFavoriteIcon(isFavorite: route.isFavorite)

        return cell
    }
        
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Don't do anything if it's the "no" routes placeholder
        guard !filteredRoutes.isEmpty else {return}
        
        let selectedRoute = filteredRoutes[indexPath.row]
        // close sheet
        collapseRouteSheet()
        // load route on map
        loadRouteOnMap(selectedRoute)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // dont allow for deletion of place holder
        
        guard !filteredRoutes.isEmpty else {return nil}
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, view, completion in
            self?.confirmDeleteRoute(at: indexPath)
            completion(true)
        }
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false //require confo, dont auto delete
        
        return configuration

    }
}

// MARK: - UISearchBarDelegate
extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // TODO: Filter routes
        print("Searching for: \(searchText)")
    }
}

// MARK: - Route History Data
extension ViewController {
    private func loadSavedRoutes() {
        savedRoutes = CoreDataManager.shared.fetchAllRoutes()
        filteredRoutes = savedRoutes  // Show all routes initially
        routesTableView.reloadData()
        
        print("Loaded \(savedRoutes.count) routes")
    }
    private func loadRouteOnMap(_ route: SavedRoute) {
        // clear existing routes
        clearAllRoutes()
        
        // decode waypoints
        guard let waypointsData = route.waypointsData,
              let waypoints = CoreDataManager.shared.decodeCoordinates(waypointsData) else {showErrorAlert(title: "", message: "Could not load route waypoints")
            return
        }
        
        // set up UI to match route settings
        routeTypeSelector.selectedSegmentIndex = Int(route.routeType)
        useScenicRouting = route.isScenicMode
        
        // store waypoints
        selectedCoordinates = waypoints
        
        // place annos on map
        let routeType = RouteConfig.RouteType(rawValue: Int(route.routeType)) ?? .oneWay
        placeAnnotations(for: waypoints, routeType: routeType)
        
        // build config and generate route
        let config = RouteConfig(
            type: routeType,
            isScenic: route.isScenicMode,
            waypoints: waypoints,
            targetDistance: nil,   //don't retry use orignal waypoints
            direction: route.direction
        )
        
        // generate route
        requestRoutes(for: waypoints, config: config)
        
        // center map on route
        if let firstPoint = waypoints.first {
            safelyCenterMap(on: firstPoint, distance: 7500)
        }
        print("Loaded rotue: \(route.name ?? "Unnamed"), \(route.targetDistance) miles")
        
    }
    
    private func confirmDeleteRoute(at indexPath: IndexPath) {
        let route = filteredRoutes[indexPath.row]
        let routeName = route.name ?? "Unnamed Route"
        let distance = String(format: "%.2f mi", route.targetDistance)
        
        let alert = UIAlertController(
            title: "Delete Route?",
            message: "Are you sure you want to delete \"\(routeName)\" (\(distance))? This cannot be undone.",
            preferredStyle:  .alert
        )
        
        // cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        // delete button
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteRoute(at: indexPath)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        present(alert, animated: true)
        
    }
    
    private func deleteRoute(at indexPath: IndexPath) {
        let route = filteredRoutes[indexPath.row]
        
        // delete from core data
        CoreDataManager.shared.deleteRoute(route)
        
        //remove from arrays
        filteredRoutes.remove(at: indexPath.row)
        if let index = savedRoutes.firstIndex(where: { $0.id == route.id}) {
            savedRoutes.remove(at: index)
        }
        //update table
        routesTableView.deleteRows(at: [indexPath], with: .fade)
        
        print("Deleted route: \(route.name ?? "Unnamed")")
        
        if filteredRoutes.isEmpty {
            routesTableView.reloadData()
        }
    }
    private func renameRoute(at indexPath: IndexPath) {
        let route = filteredRoutes[indexPath.row]
        let currentName = route.name ?? "Route \(indexPath.row + 1)"
        
        let alert = UIAlertController(
            title: "Rename Route",
            message: "Enter a new name for this route",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.text = currentName
            textField.placeholder = "Route name"
            textField.autocapitalizationType = .words
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let newName = alert.textFields?.first?.text, !newName.isEmpty else { return }
            
            route.name = newName
            CoreDataManager.shared.saveContext()
            
            self?.routesTableView.reloadRows(at: [indexPath], with: .automatic)
            
            print("Renamed worked new name is \(newName)")
        }
    
        alert.addAction(saveAction)
        present(alert,animated: true)
    }
    
    private func toggleFavorite(at indexPath: IndexPath) {
        let route = filteredRoutes[indexPath.row]
        
        // Toggle the favorite state
        route.isFavorite.toggle()
        
        // Save to Core Data
        CoreDataManager.shared.saveContext()
        
        // Update the cell icon
        if let cell = routesTableView.cellForRow(at: indexPath) as? RouteTableViewCell {
            cell.updateFavoriteIcon(isFavorite: route.isFavorite)
        }
        
        let status = route.isFavorite ? "favorited" : "unfavorited"
        print("❤️ Route \(status)")
    }
    
    private func clearAllRoutesFromDatabase() {
        // Delete all routes from Core Data
        for route in savedRoutes {
            CoreDataManager.shared.deleteRoute(route)
        }
        
        // Clear arrays
        savedRoutes.removeAll()
        filteredRoutes.removeAll()
        
        // Reload table
        routesTableView.reloadData()
        
        print("🗑️ All routes cleared")
    }
    
    private func applyFiltersAndSort()
    {
        // step 1: look at all routes from DB
        var results = savedRoutes
        
        // step 2: apply "show only favs" filter
        if showOnlyFavorites {
            results = results.filter{ route in     // .filter goes through each route and asks if it is X.
                return route.isFavorite == true}
        }
        
        // step 3: apply "route type filter"
        if let typeFilter = filterByRouteType {
            results = results.filter {route in      //EX: if typeFilter = 2(loop) only show loops
                return route.routeType == typeFilter
            }
            
        }
        // if vibefilter = true only scenic. false = only fastest
        if let vibeFilter = filterByScenicMode {
            results = results.filter {route in
                return route.isScenicMode == vibeFilter}
        }
        
        // step 4: sort remaining routes
        switch sortOption {
                case .newestFirst:
                    // Sort by date, newest at top
                    results.sort { route1, route2 in
                        guard let date1 = route1.createdDate, let date2 = route2.createdDate else { return false }
                        return date1 > date2  // > means descending (newest first)
                    }
                    
                case .oldestFirst:
                    // Sort by date, oldest at top
                    results.sort { route1, route2 in
                        guard let date1 = route1.createdDate, let date2 = route2.createdDate else { return false }
                        return date1 < date2  // < means ascending (oldest first)
                    }
                    
                case .shortestDistance:
                    // Sort by distance, shortest at top
                    results.sort { route1, route2 in
                        return route1.targetDistance < route2.targetDistance
                    }
                    
                case .longestDistance:
                    // Sort by distance, longest at top
                    results.sort { route1, route2 in
                        return route1.targetDistance > route2.targetDistance
                    }
                
            case .shortestTime:
                // UPDATE: later will need to make more complex when other feats added
                results.sort{ route1, route2 in
                    // estimate time = distance/speed
                    // using avg walking speed (same as route info label
                    let speedMPH = walkSampleCount >= 10 ? avgWalkingSpeed * 2.2369 : 3.5
                    let time1 = (route1.targetDistance / speedMPH) * 60  //mins
                    let time2 = (route2.targetDistance / speedMPH) * 60
                    return time1 < time2
                }
                
            case .longestTime:
                // UPDATE: later will need to make more complex when other feats added
                results.sort { route1, route2 in
                    let speedMPH = walkSampleCount >= 10 ? avgWalkingSpeed * 2.23694 : 3.5
                    let time1 = (route1.targetDistance / speedMPH) * 60
                    let time2 = (route2.targetDistance / speedMPH) * 60
                    
                    return time1 > time2
                }
                
            case .nameAZ:
                // alphabetical A->Z
                results.sort{ route1, route2 in
                    let name1 = route1.name ?? "Unnamed"
                    let name2 = route2.name ?? "Unnamed"
                    return name1 < name2
                    
                }
                
            case .nameZA:
                // alphabetical Z->A
                results.sort{route1, route2 in
                    let name1 = route1.name ?? "Unnamed"
                    let name2 = route2.name ?? "Unnamed"
                    return name1 > name2
                    
                }
            }
            
            // step 5: update what table displays
            filteredRoutes = results
            
            // step 6: refersth table to display new stuff
            routesTableView.reloadData()
            
            // Debug: show what happened
            print("Applied filters: \(results.count) routes match")
            
            
        }
        
    }
// MARK: - UIGestureRecognizerDelegate
extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Allow table view gestures to work alongside sheet pan gesture
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == routeHistorySheet.gestureRecognizers?.first(where: { $0 is UIPanGestureRecognizer}) {
            let location = gestureRecognizer.location(in: routeHistorySheet)
            
            // convert location to table view coords
            let tableLocation = routeHistorySheet.convert(location, to: routesTableView)
            
            // if touch is inside the table view bounds dont allow sheet pan
            if routesTableView.bounds.contains(tableLocation) && routesTableView.alpha > 0 {
                return false // disable sheet pan- let table scroll instead
            }
            
            //otherwise let it pan (touching pill, search bar, or bg
            return true
        }
        return true
    }
}
/*


 */

