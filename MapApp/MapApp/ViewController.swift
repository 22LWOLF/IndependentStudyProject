//
//  ViewController.swift
//  MapApp
//
//  Created by Wolf,Luke D on 1/16/26.
//

import UIKit
import MapKit
import CoreLocation
import ActivityKit
import AVFAudio

// MARK: - Color Scheme
struct AppPalette {
    let primary: UIColor
    let secondary: UIColor
    let background: UIColor
    let floatingButtonBackground: UIColor
    let floatingButtonForeground: UIColor
    let sidePanelBackground: UIColor
}

enum AppTheme: String, CaseIterable {
    // MARK: Wildflower Trail
    case wildflowerTrail

    // MARK: Coastal Morning
    case coastalMorning

    // MARK: Canyon Path
    case canyonPath

    // MARK: Early Frost
    case earlyFrost

    // MARK: Urban Fog
    case urbanFog

    // MARK: Evening Stroll
    case eveningStroll

    init(index: Int) {
        let themes = AppTheme.allCases
        if themes.indices.contains(index) {
            self = themes[index]
        } else {
            self = .wildflowerTrail
        }
    }

    var index: Int {
        AppTheme.allCases.firstIndex(of: self) ?? 0
    }

    var displayName: String {
        switch self {
        case .wildflowerTrail: return "Wildflower Trail"
        case .coastalMorning: return "Coastal Morning"
        case .canyonPath: return "Canyon Path"
        case .earlyFrost: return "Early Frost"
        case .urbanFog: return "Urban Fog"
        case .eveningStroll: return "Evening Stroll"
        }
    }

    var palette: AppPalette {
        switch self {
        case .wildflowerTrail:
            return AppPalette(
                primary: UIColor(hex: "#7A8B62"),
                secondary: UIColor(hex: "#9B6A82"),
                background: UIColor(hex: "#2A1E24"),
                floatingButtonBackground: UIColor(hex: "#F9F9F9"),
                floatingButtonForeground: UIColor(hex: "#1A1A1A"),
                sidePanelBackground: UIColor(hex: "#F4F1ED")
            )
        case .coastalMorning:
            return AppPalette(
                primary: UIColor(hex: "#6B8CAE"),
                secondary: UIColor(hex: "#E0A98B"),
                background: UIColor(hex: "#1A2430"),
                floatingButtonBackground: UIColor(hex: "#1A1A1A"),
                floatingButtonForeground: UIColor(hex: "#FFFFFF"),
                sidePanelBackground: UIColor(hex: "#EBF0F5")
            )
        case .canyonPath:
            return AppPalette(
                primary: UIColor(hex: "#C27A62"),
                secondary: UIColor(hex: "#8BA382"),
                background: UIColor(hex: "#2D2421"),
                floatingButtonBackground: UIColor(hex: "#F5EFE9"),
                floatingButtonForeground: UIColor(hex: "#2D2421"),
                sidePanelBackground: UIColor(hex: "#EAE3DB")
            )
        case .earlyFrost:
            return AppPalette(
                primary: UIColor(hex: "#88B7AA"),
                secondary: UIColor(hex: "#A89BBD"),
                background: UIColor(hex: "#1F302D"),
                floatingButtonBackground: UIColor(hex: "#FFFFFF"),
                floatingButtonForeground: UIColor(hex: "#1F302D"),
                sidePanelBackground: UIColor(hex: "#EEF2F0")
            )
        case .urbanFog:
            return AppPalette(
                primary: UIColor(hex: "#7B848A"),
                secondary: UIColor(hex: "#D1B26E"),
                background: UIColor(hex: "#1E2022"),
                floatingButtonBackground: UIColor(hex: "#000000"),
                floatingButtonForeground: UIColor(hex: "#FFFFFF"),
                sidePanelBackground: UIColor(hex: "#E1E4E6")
            )
        case .eveningStroll:
            return AppPalette(
                primary: UIColor(hex: "#C48B8B"),
                secondary: UIColor(hex: "#CFA16B"),
                background: UIColor(hex: "#301B20"),
                floatingButtonBackground: UIColor(hex: "#FAEEEE"),
                floatingButtonForeground: UIColor(hex: "#301B20"),
                sidePanelBackground: UIColor(hex: "#F5E6E6")
            )
        }
    }
}

extension UIColor {
    static var activeTheme: AppTheme = .urbanFog
    static var activeThemeIndex: Int {
        get { activeTheme.index }
        set { activeTheme = AppTheme(index: newValue) }
    }

    static var appPrimary: UIColor { activeTheme.palette.primary }
    static var compColor: UIColor { activeTheme.palette.secondary }
    static var darkColor: UIColor { activeTheme.palette.background }
    static var floatingButtonBackground: UIColor { activeTheme.palette.floatingButtonBackground }
    static var floatingButtonForeground: UIColor { activeTheme.palette.floatingButtonForeground }
    static var sidePanelBackground: UIColor { activeTheme.palette.sidePanelBackground }
    static var headerBG: UIColor {
        switch activeTheme {
        case .wildflowerTrail:
            return darkColor
                .blended(withFraction: 0.42, of: compColor)
                .blended(withFraction: 0.12, of: appPrimary)
                .withAlphaComponent(0.58)
        case .coastalMorning:
            return darkColor
                .blended(withFraction: 0.38, of: appPrimary)
                .blended(withFraction: 0.10, of: UIColor(hex: "#BBD5E8"))
                .withAlphaComponent(0.54)
        case .canyonPath:
            return darkColor
                .blended(withFraction: 0.34, of: appPrimary)
                .blended(withFraction: 0.14, of: compColor)
                .withAlphaComponent(0.60)
        case .earlyFrost:
            return darkColor
                .blended(withFraction: 0.34, of: appPrimary)
                .blended(withFraction: 0.10, of: compColor)
                .withAlphaComponent(0.54)
        case .urbanFog:
            return darkColor
                .blended(withFraction: 0.18, of: compColor)
                .blended(withFraction: 0.08, of: UIColor(hex: "#A6B0B8"))
                .withAlphaComponent(0.62)
        case .eveningStroll:
            return darkColor
                .blended(withFraction: 0.36, of: compColor)
                .blended(withFraction: 0.14, of: appPrimary)
                .withAlphaComponent(0.58)
        }
    }
    static var bottomBG: UIColor {
        switch activeTheme {
        case .wildflowerTrail:
            return darkColor
                .blended(withFraction: 0.42, of: compColor)
                .blended(withFraction: 0.12, of: appPrimary)
                .withAlphaComponent(0.58)
        case .coastalMorning:
            return darkColor
                .blended(withFraction: 0.38, of: appPrimary)
                .blended(withFraction: 0.10, of: UIColor(hex: "#BBD5E8"))
                .withAlphaComponent(0.54)
        case .canyonPath:
            return darkColor
                .blended(withFraction: 0.34, of: appPrimary)
                .blended(withFraction: 0.14, of: compColor)
                .withAlphaComponent(0.60)
        case .earlyFrost:
            return darkColor
                .blended(withFraction: 0.34, of: appPrimary)
                .blended(withFraction: 0.10, of: compColor)
                .withAlphaComponent(0.54)
        case .urbanFog:
            return darkColor
                .blended(withFraction: 0.18, of: compColor)
                .blended(withFraction: 0.08, of: UIColor(hex: "#A6B0B8"))
                .withAlphaComponent(0.62)
        case .eveningStroll:
            return darkColor
                .blended(withFraction: 0.36, of: compColor)
                .blended(withFraction: 0.14, of: appPrimary)
                .withAlphaComponent(0.58)
        }
    }
    static var primaryTextColor: UIColor { activeTheme.palette.floatingButtonForeground }
    static var secondaryTextColor: UIColor { activeTheme.palette.floatingButtonForeground.withAlphaComponent(0.72) }
    static var panelHeaderTextColor: UIColor {
        sidePanelBackground.isLightColor
            ? UIColor(hex: "#1F1F1F").withAlphaComponent(0.72)
            : UIColor.white.withAlphaComponent(0.82)
    }
    static var panelBodyTextColor: UIColor {
        sidePanelBackground.isLightColor
            ? UIColor(hex: "#1F1F1F")
            : UIColor.white.withAlphaComponent(0.92)
    }
    static var elevatedPanelSurface: UIColor {
        switch activeTheme {
        case .wildflowerTrail:
            return sidePanelBackground.blended(withFraction: 0.18, of: compColor)
        case .coastalMorning:
            return sidePanelBackground.blended(withFraction: 0.14, of: appPrimary)
        case .canyonPath:
            return sidePanelBackground.blended(withFraction: 0.18, of: appPrimary)
        case .earlyFrost:
            return sidePanelBackground.blended(withFraction: 0.16, of: appPrimary)
        case .urbanFog:
            return sidePanelBackground.blended(withFraction: 0.10, of: darkColor)
        case .eveningStroll:
            return sidePanelBackground.blended(withFraction: 0.18, of: compColor)
        }
    }
    static var searchFieldSurface: UIColor {
        switch activeTheme {
        case .wildflowerTrail:
            return sidePanelBackground.blended(withFraction: 0.16, of: appPrimary)
        case .coastalMorning:
            return sidePanelBackground.blended(withFraction: 0.14, of: compColor)
        case .canyonPath:
            return sidePanelBackground.blended(withFraction: 0.18, of: compColor)
        case .earlyFrost:
            return sidePanelBackground.blended(withFraction: 0.15, of: compColor)
        case .urbanFog:
            return sidePanelBackground.blended(withFraction: 0.12, of: compColor)
        case .eveningStroll:
            return sidePanelBackground.blended(withFraction: 0.18, of: appPrimary)
        }
    }
    static var selectorSurface: UIColor {
        switch activeTheme {
        case .wildflowerTrail:
            return sidePanelBackground.blended(withFraction: 0.22, of: compColor)
        case .coastalMorning:
            return sidePanelBackground.blended(withFraction: 0.20, of: appPrimary)
        case .canyonPath:
            return sidePanelBackground.blended(withFraction: 0.24, of: appPrimary)
        case .earlyFrost:
            return sidePanelBackground.blended(withFraction: 0.22, of: appPrimary)
        case .urbanFog:
            return sidePanelBackground.blended(withFraction: 0.16, of: darkColor)
        case .eveningStroll:
            return sidePanelBackground.blended(withFraction: 0.24, of: compColor)
        }
    }
    static var dividerColor: UIColor { compColor.withAlphaComponent(0.32) }
    static var panelNeutralButtonBackground: UIColor { sidePanelBackground.blended(withFraction: 0.18, of: darkColor) }
    static var panelNeutralButtonForeground: UIColor { activeTheme.palette.floatingButtonForeground }
    static var semanticGenerateColor: UIColor { UIColor(hex: "#8AAF5C").blended(withFraction: 0.22, of: appPrimary) }
    static var semanticClearColor: UIColor { UIColor(hex: "#D46A74").blended(withFraction: 0.22, of: compColor) }

    convenience init(hex: String) {
        let cleanedHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleanedHex).scanHexInt64(&value)

        let red = CGFloat((value >> 16) & 0xFF) / 255.0
        let green = CGFloat((value >> 8) & 0xFF) / 255.0
        let blue = CGFloat(value & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }

    func blended(withFraction fraction: CGFloat, of color: UIColor) -> UIColor {
        let clampedFraction = max(0, min(1, fraction))

        var redA: CGFloat = 0
        var greenA: CGFloat = 0
        var blueA: CGFloat = 0
        var alphaA: CGFloat = 0
        getRed(&redA, green: &greenA, blue: &blueA, alpha: &alphaA)

        var redB: CGFloat = 0
        var greenB: CGFloat = 0
        var blueB: CGFloat = 0
        var alphaB: CGFloat = 0
        color.getRed(&redB, green: &greenB, blue: &blueB, alpha: &alphaB)

        return UIColor(
            red: redA + (redB - redA) * clampedFraction,
            green: greenA + (greenB - greenA) * clampedFraction,
            blue: blueA + (blueB - blueA) * clampedFraction,
            alpha: alphaA + (alphaB - alphaA) * clampedFraction
        )
    }

    var isLightColor: Bool {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let brightness = (red * 299 + green * 587 + blue * 114) / 1000
        return brightness > 0.68
    }
}

// MARK: - Custom Classes
class RouteAnnotation: MKPointAnnotation { var index: Int = 0 }

class StyledPolyline: MKPolyline {
    enum Kind { case forward, backward, walked, remaining }
    var kind: Kind = .forward
    var legIndex: Int = 0
    enum Mode { case fastest, scenic }
    var mode: Mode = .fastest
    var paceType: PaceType? = nil
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
        print("More tapped, revealed: \(isRevealed)")
        if isRevealed {
            hideOptionsButton()
        } else {
            revealOptionsButtons()
        }
    }
    
    @objc private func editButtonTapped() {
        print("Edit tapped")
        editAction?()
        hideOptionsButton()
    }
    
    @objc private func deleteButtonTapped() {
        print("Delete tapped")
        deleteAction?()
        hideOptionsButton()
    }
    
    @objc private func favoriteButtonTapped() {
        print("Favorite tapped")
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

// MARK: - Pace Configuration
struct PaceSegmentConfig {
    let paceType: PaceType
    var percentage: Double
    var distance: Double
    
    var symbolName: String {
        switch paceType {
        case .walk: return "tortoise.fill"
        case .jog: return "figure.run"
        case .run: return "hare.fill"
        }
    }
    
    var color: UIColor {
        switch paceType {
        case .walk: return .systemGreen
        case .jog: return .systemOrange
        case .run: return .systemRed
        }
    }
}

enum PaceType: String {
    case walk = "Walk"
    case jog = "Jog"
    case run = "Run"
}


// MARK: - ViewController
class ViewController: UIViewController, MKLocalSearchCompleterDelegate {
    private struct PendingRouteSave {
        let waypoints: [CLLocationCoordinate2D]
        let coordinates: [CLLocationCoordinate2D]
        let totalDistance: CLLocationDistance
        let config: RouteConfig
    }
    
    private struct NavigationCue {
        let triggerDistance: CLLocationDistance
        let instruction: String
        let announcementLeadDistance: CLLocationDistance
    }
    
    // MARK: - Outlets
    @IBOutlet weak var headerBox: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var routeNameLabel: UILabel?
    @IBOutlet weak var routeInfoLabel: UILabel!
    @IBOutlet weak var routeTypeSelector: UISegmentedControl!
    @IBOutlet weak var bottomTabContainer: UIView!
    @IBOutlet weak var routeHistorySheet: UIView!
    @IBOutlet weak var routesTableView: UITableView!
    @IBOutlet weak var routesSearchBar: UISearchBar!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton?
    @IBOutlet weak var goToButton: UIButton?
    @IBOutlet weak var generateButton: UIButton?
    @IBOutlet weak var cancelButton: UIButton?
    @IBOutlet weak var recenterButton: UIButton?
    @IBOutlet weak var pacePatternButton: UIButton?
    @IBOutlet weak var routeSettingsButton: UIButton?

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
    private var saveRoutePillButton: UIButton!
    
    // MARK: - Pace Settings Panel
    private var pacePanel: UIView!
    private var walkSlider: UISlider!
    private var jogSlider: UISlider!
    private var runSlider: UISlider!
    private var walkPercentLabel: UILabel!
    private var jogPercentLabel: UILabel!
    private var runPercentLabel: UILabel!
    private var paceChipsContainer: UIStackView!
    private var pulseModeButton: UIButton!
    private var pulsePickerInputField: UITextField!
    private var isPacePanelOpen = false

    // MARK: - State
    private var selectedCoordinates: [CLLocationCoordinate2D] = []
    private var isPanelOpen = false
    private var isGeneratingRoute = false
    private var isFollowingUser = false
    private var isActivelyWalkingRoute = false
    private var hasAlreadyCentered = false
    private var isReloadingExistingRoute = false
    
    //Filter state
    private var showOnlyFavorites: Bool = false   //means it shows favs and non-favs
    private var filterByRouteType: Int? = nil   //nil = show all types
    private var filterByScenicMode: Bool? = nil   //nil = show all, 1 = fastest, 2 = scenic
    private var sortOption: SortOption = .none
    
    enum SortOption {
        case none
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
    
    // MARK: - Go To search completer
    private var searchCompleter = MKLocalSearchCompleter()

    // MARK: - Route Tracking
    private var currentRouteCoordinates: [CLLocationCoordinate2D] = []
    private var totalRouteDistance: CLLocationDistance = 0
    private var traveledDistance: CLLocationDistance = 0
    private var routeSegments: [CLLocationCoordinate2D] = []
    private var cumulativeSegmentLengths: [CLLocationDistance] = []
    private var currentRouteType: RouteConfig.RouteType = .oneWay
    private var currentRouteDisplayName = "Welcome to APPNAME"
    private var lastRouteTypeSelection = 0
    private var pendingRouteSave: PendingRouteSave?
    private var speechSynthesizer = AVSpeechSynthesizer()
    private var navigationCues: [NavigationCue] = []
    private var nextNavigationCueIndex = 0
    private var routeLiveActivity: Activity<MapAppRouteActivityAttributes>?
    private var lastLiveActivityUpdateDate: Date?
    private var lastLoggedPaceType: PaceType?
    private var hasAttemptedDebugLiveActivityStart = false
    private let walkPaceFeedback = UIImpactFeedbackGenerator(style: .soft)
    private let jogPaceFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let runPaceFeedback = UIImpactFeedbackGenerator(style: .rigid)

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
    
    // MARK: - Pace Configuration State
    private var paceOrder: [PaceSegmentConfig] = []
    private var lastPaceOrder: [PaceType] = []
    private var pacePercentLabels: [UILabel] = []
    private let pulseOptions = Array(1...12)
    private var pulseSegmentCount = 1
    

    enum RouteSheetState {
        case collapsed
        case expanded
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        speechSynthesizer.delegate = self
        configureSpokenGuidanceAudioSession()
        preparePaceHaptics()
        setupMap()
        setupLocation()
        setupUI()
        loadSavedSpeeds()
        setupRouteHistorySheet()
        setupPacePanel()
        CoreDataManager.shared.migrateExistingRoutes()
        lastRouteTypeSelection = routeTypeSelector.selectedSegmentIndex
        routeNameLabel?.text = currentRouteDisplayName
        
        searchCompleter = MKLocalSearchCompleter()
           searchCompleter.delegate = self
           // Limit to search results to the map view's current region.
            searchCompleter.region = mapView.region

        
        
    }
    


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerBox.layer.cornerRadius = 44
        headerBox.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerBox.layer.masksToBounds = true

        bottomTabContainer.layer.cornerRadius = 44
        bottomTabContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomTabContainer.layer.masksToBounds = true

        applyButtonGeometry()
        
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
        applyTheme()
        setupProgressBar()
        setupSlidePanel()
        setupLoopControls()
        setupSaveRoutePill()
    }

    private func applyTheme(themeIndex: Int? = nil) {
        if let themeIndex {
            UIColor.activeThemeIndex = themeIndex
        }

        view.backgroundColor = .darkColor
        headerBox.backgroundColor = .headerBG
        bottomTabContainer.backgroundColor = .bottomBG
        routeHistorySheet.backgroundColor = .elevatedPanelSurface
        routeHistorySheet.layer.borderWidth = 0
        routeHistorySheet.layer.borderColor = UIColor.clear.cgColor

        routeNameLabel?.textColor = .primaryTextColor
        routeInfoLabel.textColor = .primaryTextColor

        routeTypeSelector.backgroundColor = .selectorSurface
        routeTypeSelector.layer.cornerRadius = 16
        routeTypeSelector.layer.borderWidth = 1
        routeTypeSelector.layer.borderColor = UIColor.dividerColor.cgColor
        routeTypeSelector.selectedSegmentTintColor = .appPrimary
        routeTypeSelector.setTitleTextAttributes([.foregroundColor: UIColor.panelNeutralButtonForeground], for: .selected)
        routeTypeSelector.setTitleTextAttributes([.foregroundColor: UIColor.panelBodyTextColor], for: .normal)

        routesSearchBar.searchTextField.backgroundColor = .searchFieldSurface
        routesSearchBar.searchTextField.textColor = .panelNeutralButtonForeground
        routesSearchBar.searchTextField.leftView?.tintColor = .secondaryTextColor
        routesSearchBar.tintColor = .appPrimary
        if var filterConfiguration = filterButton.configuration {
            filterConfiguration.baseBackgroundColor = .compColor
            filterConfiguration.baseForegroundColor = .floatingButtonForeground
            buttonConfigurationPreservingTitle(button: filterButton, configuration: filterConfiguration)
        } else {
            filterButton.backgroundColor = .compColor
            filterButton.tintColor = .floatingButtonForeground
            filterButton.setTitleColor(.floatingButtonForeground, for: .normal)
        }

        progressView.progressTintColor = .compColor
        progressView.trackTintColor = .darkColor

        slidePanel?.backgroundColor = .elevatedPanelSurface
        pacePanel?.backgroundColor = .elevatedPanelSurface
        slidePanel?.layer.borderWidth = 1
        slidePanel?.layer.borderColor = UIColor.dividerColor.cgColor
        pacePanel?.layer.borderWidth = 1
        pacePanel?.layer.borderColor = UIColor.dividerColor.cgColor

        saveRoutePillButton?.backgroundColor = UIColor.floatingButtonBackground.withAlphaComponent(0.96)
        saveRoutePillButton?.setTitleColor(.floatingButtonForeground, for: .normal)
        styleRouteSheetGrabber()

        styleThemeButton(settingsButton, role: .secondary)
        styleThemeButton(goToButton, role: .primary)
        styleThemeButton(generateButton, role: .generate)
        styleThemeButton(cancelButton, role: .clear)
        styleFloatingIconButton(recenterButton, diameter: 50)
        styleFloatingIconButton(pacePatternButton, diameter: 40)
        styleFloatingIconButton(routeSettingsButton, diameter: 40)

        applyThemeToStoryboardButtons(in: view)
    }

    private func applyThemeToStoryboardButtons(in container: UIView) {
        for subview in container.subviews {
            if let button = subview as? UIButton {
                styleThemeButton(button)
            }
            applyThemeToStoryboardButtons(in: subview)
        }
    }

    private func styleRouteSheetGrabber() {
        guard let grabberView = routeHistorySheet.subviews.first else { return }
        grabberView.backgroundColor = .darkColor.withAlphaComponent(0.34)
        grabberView.layer.borderWidth = 1
        grabberView.layer.borderColor = UIColor.dividerColor.cgColor

        if let imageView = grabberView.subviews.compactMap({ $0 as? UIImageView }).first {
            imageView.tintColor = .floatingButtonForeground.withAlphaComponent(0.88)
        }
    }

    private enum ThemeButtonRole {
        case primary
        case secondary
        case generate
        case clear
    }

    private func styleThemeButton(_ button: UIButton?, role: ThemeButtonRole) {
        guard let button else { return }
        let backgroundColor: UIColor
        switch role {
        case .primary:
            backgroundColor = .appPrimary
        case .secondary:
            backgroundColor = .compColor
        case .generate:
            backgroundColor = .semanticGenerateColor
        case .clear:
            backgroundColor = .semanticClearColor
        }
        applyThemeColors(to: button, backgroundColor: backgroundColor)
        applyButtonOutline(to: button, color: UIColor.floatingButtonForeground.withAlphaComponent(0.45), width: 2)

        if let titleLabel = button.titleLabel {
            titleLabel.font = .systemFont(ofSize: titleLabel.font.pointSize, weight: .bold)
        }
    }

    private func styleThemeButton(_ button: UIButton) {
        guard let rawTitle = button.title(for: .normal)?.trimmingCharacters(in: .whitespacesAndNewlines),
              !rawTitle.isEmpty else { return }

        let normalizedTitle = rawTitle.lowercased()
        let usesPrimaryTheme = normalizedTitle == "go to" || normalizedTitle == "go"
        let usesSecondaryTheme = normalizedTitle == "settings" || normalizedTitle == "clear settings"
        let usesGenerateTheme = normalizedTitle == "generate"
        let usesClearTheme = normalizedTitle == "cancel" || normalizedTitle == "clear"

        guard usesPrimaryTheme || usesSecondaryTheme || usesGenerateTheme || usesClearTheme else { return }

        let backgroundColor: UIColor
        if usesGenerateTheme {
            backgroundColor = .semanticGenerateColor
        } else if usesClearTheme {
            backgroundColor = .semanticClearColor
        } else if usesPrimaryTheme {
            backgroundColor = .appPrimary
        } else {
            backgroundColor = .compColor
        }
        applyThemeColors(to: button, backgroundColor: backgroundColor)
    }

    private func styleFloatingIconButton(_ button: UIButton?, diameter: CGFloat) {
        guard let button else { return }
        applyThemeColors(to: button, backgroundColor: .floatingButtonBackground)
        applyButtonOutline(to: button, color: UIColor.floatingButtonForeground.withAlphaComponent(0.35), width: 1.5)

        if var configuration = button.configuration {
            configuration.title = nil
            configuration.subtitle = nil
            configuration.cornerStyle = .fixed
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            configuration.background.cornerRadius = diameter / 2
            configuration.background.strokeColor = UIColor.floatingButtonForeground.withAlphaComponent(0.35)
            configuration.background.strokeWidth = 1.5
            button.configuration = configuration
        }
    }

    private func applyThemeColors(to button: UIButton, backgroundColor: UIColor) {
        let foregroundColor = UIColor.floatingButtonForeground

        if var configuration = button.configuration {
            configuration.baseBackgroundColor = backgroundColor
            configuration.baseForegroundColor = foregroundColor
            buttonConfigurationPreservingTitle(button: button, configuration: configuration)
        } else {
            button.backgroundColor = backgroundColor
            button.setTitleColor(foregroundColor, for: .normal)
            button.tintColor = foregroundColor
        }
    }

    private func buttonConfigurationPreservingTitle(button: UIButton, configuration: UIButton.Configuration) {
        var updatedConfiguration = configuration
        if updatedConfiguration.title == nil {
            updatedConfiguration.title = button.title(for: .normal)
        }
        button.configuration = updatedConfiguration
    }

    private func applyButtonOutline(to button: UIButton, color: UIColor, width: CGFloat) {
        button.layer.borderColor = color.cgColor
        button.layer.borderWidth = width
    }

    private func applyButtonGeometry() {
        enforceFixedSize(for: generateButton, width: 100, height: 100)
        enforceFixedSize(for: cancelButton, width: 100, height: 100)
        enforceFixedSize(for: recenterButton, width: 50, height: 50)
        enforceFixedSize(for: pacePatternButton, width: 40, height: 40)
        enforceFixedSize(for: routeSettingsButton, width: 40, height: 40)

        generateButton?.layer.cornerRadius = 50
        cancelButton?.layer.cornerRadius = 50
        recenterButton?.layer.cornerRadius = 25
        pacePatternButton?.layer.cornerRadius = 20
        routeSettingsButton?.layer.cornerRadius = 20
        generateButton?.clipsToBounds = true
        cancelButton?.clipsToBounds = true
        recenterButton?.clipsToBounds = true
        pacePatternButton?.clipsToBounds = true
        routeSettingsButton?.clipsToBounds = true

        applyCapsuleShape(to: settingsButton)
        applyCapsuleShape(to: goToButton)
    }

    private func applyCapsuleShape(to button: UIButton?) {
        guard let button else { return }
        button.layer.cornerRadius = button.bounds.height / 2
        button.clipsToBounds = true
    }

    private func enforceFixedSize(for button: UIButton?, width: CGFloat, height: CGFloat) {
        guard let button else { return }

        if let widthConstraint = button.constraints.first(where: { $0.firstAttribute == .width && $0.relation == .equal }) {
            widthConstraint.constant = width
        } else {
            button.widthAnchor.constraint(equalToConstant: width).isActive = true
        }

        if let heightConstraint = button.constraints.first(where: { $0.firstAttribute == .height && $0.relation == .equal }) {
            heightConstraint.constant = height
        } else {
            button.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
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
    
    private func setupSaveRoutePill() {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Save Route", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.darkColor.withAlphaComponent(0.92)
        button.layer.cornerRadius = 22
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.18
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        button.layer.shadowRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        button.alpha = 0
        button.isHidden = true
        button.addTarget(self, action: #selector(saveRoutePillTapped), for: .touchUpInside)
        view.addSubview(button)
        saveRoutePillButton = button
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: bottomTabContainer.topAnchor, constant: -35),
            button.heightAnchor.constraint(equalToConstant: 44)
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
        // === SHOW FILTERS ===
        
        let showAllAction = UIAction(
            title: "All Routes",
            image: UIImage(systemName: "list.bullet"),
            state: (!showOnlyFavorites && filterByRouteType == nil && filterByScenicMode == nil) ? .on : .off
        ) { [weak self] _ in
            self?.showOnlyFavorites = false
            self?.filterByRouteType = nil
            self?.filterByScenicMode = nil
            self?.applyFiltersAndSort()
        }
        
        let favoritesAction = UIAction(
            title: "❤️ Favorites Only",
            image: UIImage(systemName: "heart.fill"),
            state: showOnlyFavorites ? .on : .off
        ) { [weak self] _ in
            self?.showOnlyFavorites = true
            self?.filterByRouteType = nil
            self?.filterByScenicMode = nil
            self?.applyFiltersAndSort()
        }
        
        let loopsAction = UIAction(
            title: "🔄 Loops Only",
            image: UIImage(systemName: "arrow.triangle.2.circlepath"),
            state: filterByRouteType == 2 ? .on : .off
        ) { [weak self] _ in
            self?.showOnlyFavorites = false
            self?.filterByRouteType = 2
            self?.filterByScenicMode = nil
            self?.applyFiltersAndSort()
        }
        
        let oneWayAction = UIAction(
            title: "➡️ One-Way Only",
            image: UIImage(systemName: "arrow.right"),
            state: filterByRouteType == 0 ? .on : .off
        ) { [weak self] _ in
            self?.showOnlyFavorites = false
            self?.filterByRouteType = 0
            self?.filterByScenicMode = nil
            self?.applyFiltersAndSort()
        }
        
        let outBackAction = UIAction(
            title: "↔️ Out & Back Only",
            image: UIImage(systemName: "arrow.left.arrow.right"),
            state: filterByRouteType == 1 ? .on : .off
        ) { [weak self] _ in
            self?.showOnlyFavorites = false
            self?.filterByRouteType = 1
            self?.filterByScenicMode = nil
            self?.applyFiltersAndSort()
        }
        
        let scenicAction = UIAction(
            title: "🌳 Scenic Only",
            image: UIImage(systemName: "leaf.fill"),
            state: filterByScenicMode == true ? .on : .off
        ) { [weak self] _ in
            // Toggle: if already on scenic, turn it off
            if self?.filterByScenicMode == true {
                self?.filterByScenicMode = nil  // Turn off filter
            } else {
                self?.filterByScenicMode = true  // Turn on scenic filter
            }
            self?.applyFiltersAndSort()
        }

        let fastestAction = UIAction(
            title: "⚡ Fastest Only",
            image: UIImage(systemName: "bolt.fill"),
            state: filterByScenicMode == false ? .on : .off
        ) { [weak self] _ in
            // Toggle: if already on fastest, turn it off
            if self?.filterByScenicMode == false {
                self?.filterByScenicMode = nil  // Turn off filter
            } else {
                self?.filterByScenicMode = false  // Turn on fastest filter
            }
            self?.applyFiltersAndSort()
        }
        // === SORT OPTIONS ===

        let newestAction = UIAction(
            title: "📅 Newest First",
            image: UIImage(systemName: "calendar"),
            state: sortOption == .newestFirst ? .on : .off
        ) { [weak self] _ in
            // Toggle: if already on, turn off
            if self?.sortOption == .newestFirst {
                self?.sortOption = .none
            } else {
                self?.sortOption = .newestFirst
            }
            self?.applyFiltersAndSort()
        }

        let oldestAction = UIAction(
            title: "📅 Oldest First",
            image: UIImage(systemName: "calendar.badge.clock"),
            state: sortOption == .oldestFirst ? .on : .off
        ) { [weak self] _ in
            if self?.sortOption == .oldestFirst {
                self?.sortOption = .none
            } else {
                self?.sortOption = .oldestFirst
            }
            self?.applyFiltersAndSort()
        }

        let shortestDistAction = UIAction(
            title: "📏 Shortest Distance",
            image: UIImage(systemName: "ruler"),
            state: sortOption == .shortestDistance ? .on : .off
        ) { [weak self] _ in
            if self?.sortOption == .shortestDistance {
                self?.sortOption = .none
            } else {
                self?.sortOption = .shortestDistance
            }
            self?.applyFiltersAndSort()
        }

        let longestDistAction = UIAction(
            title: "📏 Longest Distance",
            image: UIImage(systemName: "ruler.fill"),
            state: sortOption == .longestDistance ? .on : .off
        ) { [weak self] _ in
            if self?.sortOption == .longestDistance {
                self?.sortOption = .none
            } else {
                self?.sortOption = .longestDistance
            }
            self?.applyFiltersAndSort()
        }

        let shortestTimeAction = UIAction(
            title: "⏱️ Shortest Time",
            image: UIImage(systemName: "clock"),
            state: sortOption == .shortestTime ? .on : .off
        ) { [weak self] _ in
            if self?.sortOption == .shortestTime {
                self?.sortOption = .none
            } else {
                self?.sortOption = .shortestTime
            }
            self?.applyFiltersAndSort()
        }

        let longestTimeAction = UIAction(
            title: "⏱️ Longest Time",
            image: UIImage(systemName: "clock.fill"),
            state: sortOption == .longestTime ? .on : .off
        ) { [weak self] _ in
            if self?.sortOption == .longestTime {
                self?.sortOption = .none
            } else {
                self?.sortOption = .longestTime
            }
            self?.applyFiltersAndSort()
        }

        let nameAZAction = UIAction(
            title: "🔤 Name (A-Z)",
            image: UIImage(systemName: "textformat.abc"),
            state: sortOption == .nameAZ ? .on : .off
        ) { [weak self] _ in
            if self?.sortOption == .nameAZ {
                self?.sortOption = .none
            } else {
                self?.sortOption = .nameAZ
            }
            self?.applyFiltersAndSort()
        }

        let nameZAAction = UIAction(
            title: "🔤 Name (Z-A)",
            image: UIImage(systemName: "textformat.abc.dottedunderline"),
            state: sortOption == .nameZA ? .on : .off
        ) { [weak self] _ in
            if self?.sortOption == .nameZA {
                self?.sortOption = .none
            } else {
                self?.sortOption = .nameZA
            }
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


// MARK: - Slide Panel Setup      TEMPORARY: CHANGE SSP TO ROUTESETTINGSPANEL
extension ViewController {
    private var sidePanelTopY: CGFloat { 165 }
    private var sidePanelHeight: CGFloat { view.bounds.height - 450 }

    private func setupSlidePanel() {
        let screenWidth = view.bounds.width
        slidePanel = UIView(frame: CGRect(x: screenWidth, y: sidePanelTopY, width: 184, height: sidePanelHeight))
        slidePanel.backgroundColor = .elevatedPanelSurface
        slidePanel.layer.cornerRadius = 12
        slidePanel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        slidePanel.layer.shadowColor = UIColor.black.cgColor
        slidePanel.layer.shadowOpacity = 0.2
        slidePanel.layer.shadowOffset = CGSize(width: -2, height: 0)
        slidePanel.layer.shadowRadius = 8
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
        button.backgroundColor = .semanticClearColor
        button.setTitleColor(.floatingButtonForeground, for: .normal)
        button.layer.cornerRadius = 8
        applyButtonOutline(to: button, color: UIColor.floatingButtonForeground.withAlphaComponent(0.45), width: 2)
        button.addTarget(self, action: #selector(clearRandomSettings), for: .touchUpInside)
        container.addSubview(button)
        return y + 40
    }

    private func addSectionHeader(to container: UIView, text: String, y: CGFloat, width: CGFloat, padding: CGFloat) -> CGFloat {
        let label = UILabel(frame: CGRect(x: padding, y: y, width: width, height: 20))
        label.text = text
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = .panelHeaderTextColor
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
        label.textColor = .panelBodyTextColor
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
        label.textColor = .panelBodyTextColor
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
        label.textColor = .panelBodyTextColor
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
                button.setTitleColor(.panelBodyTextColor, for: .normal)
                button.backgroundColor = .panelNeutralButtonBackground
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
        label.textColor = .panelBodyTextColor
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
        divider.backgroundColor = .dividerColor
        container.addSubview(divider)
        return y + 15
    }
}

// MARK: - Pace Panel Setup
extension ViewController {
    private func setupPacePanel() {
        let panelWidth: CGFloat = 140  // Skinny panel
        
        // Create panel (starts off-screen to the left)
        pacePanel = UIView(frame: CGRect(x: -panelWidth, y: sidePanelTopY, width: panelWidth, height: sidePanelHeight))
        pacePanel.backgroundColor = .elevatedPanelSurface
        pacePanel.layer.cornerRadius = 12
        pacePanel.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]  // Round right corners
        pacePanel.layer.shadowColor = UIColor.black.cgColor
        pacePanel.layer.shadowOpacity = 0.2
        pacePanel.layer.shadowOffset = CGSize(width: 2, height: 0)
        pacePanel.layer.shadowRadius = 8
        view.addSubview(pacePanel)
        
        setupPacePanelContent()
    }
    
    private func setupPacePanelContent() {
        let padding: CGFloat = 12
        var currentY: CGFloat = 0
        
        // === SECTION 1: VERTICAL SLIDERS ===
        currentY = addPaceSectionHeader(to: pacePanel, text: "PACE MIX", y: currentY, padding: padding)
        
        // Container for sliders (horizontal layout)
        let sliderContainer = UIView(frame: CGRect(x: padding, y: currentY, width: pacePanel.frame.width - (padding * 2), height: 160))
        pacePanel.addSubview(sliderContainer)
        
        let sliderWidth: CGFloat = 36
        
        let walkContainer = createVerticalSlider(
            label: "W",
            color: .systemGreen,
            x: 0,
            width: sliderWidth,
            action: #selector(paceSliderChanged(_:))
        )
        sliderContainer.addSubview(walkContainer)
        
        let jogContainer = createVerticalSlider(
            label: "J",
            color: .systemOrange,
            x: 40,
            width: sliderWidth,
            action: #selector(paceSliderChanged(_:))
        )
        sliderContainer.addSubview(jogContainer)
        
        let runContainer = createVerticalSlider(
            label: "R",
            color: .systemRed,
            x: 80,
            width: sliderWidth,
            action: #selector(paceSliderChanged(_:))
        )
        sliderContainer.addSubview(runContainer)
        
        currentY += 160
        currentY += 8
        
        // === SECTION 2: PACE ORDER CHIPS ===
        currentY = addPaceSectionHeader(to: pacePanel, text: "PACE ORDER", y: currentY, padding: padding)
        
        // Horizontal stack for chips
        paceChipsContainer = UIStackView(frame: CGRect(x: padding, y: currentY, width: pacePanel.frame.width - (padding * 2), height: 65))
        paceChipsContainer.axis = .horizontal
        paceChipsContainer.spacing = 4
        paceChipsContainer.distribution = .fillEqually
        pacePanel.addSubview(paceChipsContainer)
        
        currentY += 75
        
        // === SECTION 3: BUTTONS ===
        // Randomize percentages button
        let randomizePercentButton = createPaceButton(
            symbolName: "dice.fill",
            color: .appPrimary,
            y: currentY,
            action: #selector(randomizePacePercentages)
        )
        pacePanel.addSubview(randomizePercentButton)
        
        currentY += 44
        
        // Shuffle order button
        let shuffleOrderButton = createPaceButton(
            symbolName: "shuffle",
            color: .compColor,
            y: currentY,
            action: #selector(shufflePaceOrder)
        )
        pacePanel.addSubview(shuffleOrderButton)
        
        currentY += 44
        
        let pulseButton = createPaceButton(
            title: "Pulse: Off",
            color: .systemTeal,
            y: currentY,
            action: #selector(showPulsePicker)
        )
        pulseButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        pacePanel.addSubview(pulseButton)
        pulseModeButton = pulseButton
        
        let pulseField = UITextField(frame: .zero)
        pulseField.isHidden = true
        pacePanel.addSubview(pulseField)
        pulsePickerInputField = pulseField
        
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        
        let pickerContainer = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 316))
        picker.backgroundColor = .elevatedPanelSurface
        picker.frame = CGRect(x: 0, y: 0, width: pickerContainer.bounds.width, height: pickerContainer.bounds.height)
        picker.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pickerContainer.addSubview(picker)
        pulseField.inputView = pickerContainer
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissPulsePicker))
        let flexItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissPulsePicker))
        toolbar.items = [cancelItem, flexItem, doneItem]
        pulseField.inputAccessoryView = toolbar
        
        // Initialize pace order
        updatePaceConfiguration()
        updatePulseButtonTitle()
    }
    
    private func createVerticalSlider(label: String, color: UIColor, x: CGFloat, width: CGFloat, action: Selector) -> UIView {
        let container = UIView(frame: CGRect(x: x, y: 0, width: width, height: 160))
        
        // Label on top
        let labelView = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 20))
        labelView.text = label
        labelView.font = .systemFont(ofSize: 12, weight: .bold)
        labelView.textAlignment = .center
        labelView.textColor = color
        container.addSubview(labelView)
        
        // Vertical slider
        let sliderWidth: CGFloat = 100
        let slider = UISlider(frame: CGRect(x: (width - sliderWidth) / 2, y: 60, width: sliderWidth, height: 20))
        slider.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)  // Rotate to vertical
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 1.0 / 3.0
        slider.tintColor = color
        slider.addTarget(self, action: action, for: .valueChanged)
        container.addSubview(slider)
        
        // Store reference
        if label == "W" {
            walkSlider = slider
        } else if label == "J" {
            jogSlider = slider
        } else {
            runSlider = slider
        }
        
        // Percentage label at bottom
        let percentLabel = UILabel(frame: CGRect(x: 0, y: 135, width: width, height: 20))
        percentLabel.text = "33%"
        percentLabel.font = .systemFont(ofSize: 11)
        percentLabel.textAlignment = .center
        percentLabel.textColor = .secondaryLabel
        container.addSubview(percentLabel)
        
        // Store reference
        if label == "W" {
            walkPercentLabel = percentLabel
        } else if label == "J" {
            jogPercentLabel = percentLabel
        } else {
            runPercentLabel = percentLabel
        }
        
        return container
    }
    
    private func createPaceButton(title: String? = nil, symbolName: String? = nil, color: UIColor, y: CGFloat, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 12, y: y, width: pacePanel.frame.width - 24, height: 36)
        if let title {
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 20)
        }
        if let symbolName {
            button.setImage(UIImage(systemName: symbolName), for: .normal)
            button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold), forImageIn: .normal)
            button.tintColor = color
        }
        button.backgroundColor = color.withAlphaComponent(0.1)
        button.setTitleColor(color, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    private func addPaceSectionHeader(to container: UIView, text: String, y: CGFloat, padding: CGFloat) -> CGFloat {
        let label = UILabel(frame: CGRect(x: padding, y: y, width: container.frame.width - (padding * 2), height: 20))
        label.text = text
        label.font = .systemFont(ofSize: 10, weight: .semibold)
        label.textColor = .panelHeaderTextColor
        label.textAlignment = .center
        container.addSubview(label)
        return y + 25
    }
    
    private func updatePulseButtonTitle() {
        pulseModeButton?.setTitle(pulseSegmentCount == 1 ? "Pulse: Off" : "Pulse: \(pulseSegmentCount)", for: .normal)
    }
}

// MARK: - Pace Panel Toggle
extension ViewController {
    @objc private func showPulsePicker() {
        guard let pickerContainer = pulsePickerInputField.inputView,
              let picker = pickerContainer.subviews.compactMap({ $0 as? UIPickerView }).first,
              let selectedRow = pulseOptions.firstIndex(of: pulseSegmentCount) else {
            pulsePickerInputField.becomeFirstResponder()
            return
        }
        picker.selectRow(selectedRow, inComponent: 0, animated: false)
        pulsePickerInputField.becomeFirstResponder()
    }
    
    @objc private func dismissPulsePicker() {
        pulsePickerInputField.resignFirstResponder()
    }
    
    private func openPacePanel() {
        UIView.animate(withDuration: 0.3) {
            self.pacePanel.frame.origin.x = 0
        }
        isPacePanelOpen = true
    }
    
    private func closePacePanel() {
        UIView.animate(withDuration: 0.3) {
            self.pacePanel.frame.origin.x = -self.pacePanel.frame.width
        }
        isPacePanelOpen = false
    }
}

// MARK: - IBActions
extension ViewController {
    @IBAction func showCoordinateEntry(_ sender: Any) { goToButtonTapped() }
    
    

    @IBAction func settingsBTN(_ sender: UIButton) { //TEMPORARY
        // Show action sheet with options
            let alert = UIAlertController(title: "Settings", message: "Choose an action", preferredStyle: .actionSheet)
            
            // Reset speed data
            let resetSpeedAction = UIAlertAction(title: "Reset Speed Data", style: .default) { [weak self] _ in
                self?.resetSpeedData()
            }
            
            // Print saved routes (debug)
            let printRoutesAction = UIAlertAction(title: "Print Routes (Debug)", style: .default) { [weak self] _ in
                self?.printSavedRoutes()
            }
            
            let printSpeedAveragesAction = UIAlertAction(title: "Print Speed Averages", style: .default) { [weak self] _ in
                self?.printSpeedAverages()
            }
            
            // Clear all routes AND reset counter (destructive)
            let clearAllAction = UIAlertAction(title: "Clear All Routes", style: .destructive) { [weak self] _ in
                self?.confirmClearAllData()
            }
            
            // Reset Everything (nuclear option)
            let resetEverythingAction = UIAlertAction(title: "Reset Everything", style: .destructive) { [weak self] _ in
                self?.confirmResetEverything()
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            alert.addAction(resetSpeedAction)
            alert.addAction(printRoutesAction)
            alert.addAction(printSpeedAveragesAction)
            alert.addAction(clearAllAction)
            alert.addAction(resetEverythingAction)
            alert.addAction(cancelAction)
            
            // For iPad (action sheets need a source)
            if let popover = alert.popoverPresentationController {
                popover.sourceView = sender
                popover.sourceRect = sender.bounds
            }
            
            present(alert, animated: true)
        }

    @IBAction func generateRouteBTN(_ sender: UIButton) {
        let config = buildRouteConfig()
        setRouteDisplayName("Current Route")
        if let targetMiles = config.targetDistance {
            generateRandomRoute(config: config, targetMiles: targetMiles)
        } else {
            generateManualRoute(config: config)
        }
    }
    @IBAction func clearRouteBTN(_ sender: UIButton) {
        clearAllRoutes()
        routeInfoLabel.text = nil
    }

    @IBAction func routeTypeChanged(_ sender: UISegmentedControl) {
        let wasLoopSelected = lastRouteTypeSelection == RouteConfig.RouteType.loop.rawValue
        let isLoopSelected = sender.selectedSegmentIndex == RouteConfig.RouteType.loop.rawValue
        lastRouteTypeSelection = sender.selectedSegmentIndex
        
        if wasLoopSelected && !isLoopSelected && (!selectedCoordinates.isEmpty || !mapView.overlays.isEmpty) {
            clearAllRoutes()
        }
        
        updateLoopControlsVisibility(isLoop: isLoopSelected)
    }

    @IBAction func routeVibeSelector(_ sender: UISegmentedControl) {
        useScenicRouting = (sender.selectedSegmentIndex == 1)
        regenerateCurrentRoute()
    }

    @IBAction func recenterBTN(_ sender: UIButton) { toggleFollowUser(button: sender) }

    @IBAction func routeSettingsBTNTapped(_ sender: UIButton) {
        animateSettingsCog(sender)
        isPanelOpen ? closePanel() : openPanel()}
        
    @IBAction func paceSettingsButtonTapped(_ sender: UIButton) {
        animateSettingsCog(sender, clockwise: false)
        isPacePanelOpen ? closePacePanel() : openPacePanel()
        }
    }

// MARK: - Route Building
extension ViewController {
    private func buildRouteConfig() -> RouteConfig {
        let type = RouteConfig.RouteType(rawValue: routeTypeSelector.selectedSegmentIndex) ?? .oneWay
        return RouteConfig(type: type, isScenic: useScenicRouting, waypoints: selectedCoordinates, targetDistance: getUserInputMiles(), direction: selectedDirection)
    }

    private func generateRandomRoute(config: RouteConfig, targetMiles: Double) {
        isReloadingExistingRoute = false
        clearPinsAndOverlays()
        let center = determineStartLocation()
        let waypoints = generateWaypoints(for: config, center: center, targetMiles: targetMiles)
        selectedCoordinates = waypoints
        placeAnnotations(for: waypoints, routeType: config.type)
        requestRoutes(for: waypoints, config: config)
    }

    private func generateManualRoute(config: RouteConfig) {
        isReloadingExistingRoute = false
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
        var cues = buildNavigationCues(from: route.steps, distanceOffset: 0)
        DispatchQueue.main.async {
            self.syncSingleLegEndpointAnnotation(with: coords, isOutAndBack: isOutAndBack)
            self.mapView.addOverlay(route.polyline)
            if isOutAndBack {
                let backward = Array(coords.reversed())
                let backwardPolyline = StyledPolyline(coordinates: backward, count: backward.count)
                backwardPolyline.kind = .backward
                self.mapView.addOverlay(backwardPolyline)
                allCoords += backward
                totalDistance *= 2
                totalTime *= 2
                cues.append(
                    NavigationCue(
                        triggerDistance: route.distance,
                        instruction: "Turn around to return to your starting point.",
                        announcementLeadDistance: 20
                    )
                )
            }
            self.finishRouteGeneration(coordinates: allCoords, totalDistance: totalDistance, totalTime: totalTime, config: config, navigationCues: cues)
        }
    }

    private func syncSingleLegEndpointAnnotation(with coordinates: [CLLocationCoordinate2D], isOutAndBack: Bool) {
        guard !isOutAndBack, let actualEndpoint = coordinates.last, selectedCoordinates.count > 1 else { return }
        selectedCoordinates[1] = actualEndpoint
        for annotation in mapView.annotations {
            guard let routeAnnotation = annotation as? RouteAnnotation, routeAnnotation.index == 1 else { continue }
            routeAnnotation.coordinate = actualEndpoint
        }
    }

    private func requestMultiLegLoop(waypoints: [CLLocationCoordinate2D], config: RouteConfig, targetMiles: Double? = nil, retryCount: Int = 0) {
        var totalDistance: CLLocationDistance = 0
        var totalTime: TimeInterval = 0
        let n = waypoints.count
        var legCoordinateSegments = Array(repeating: [CLLocationCoordinate2D](), count: n)
        var collectedCues: [NavigationCue] = []
        
        func requestLeg(at index: Int) {
            if index >= n {
                var allCoords: [CLLocationCoordinate2D] = []
                for (legIndex, coords) in legCoordinateSegments.enumerated() {
                    guard !coords.isEmpty else { continue }
                    if allCoords.isEmpty || legIndex == 0 {
                        allCoords.append(contentsOf: coords)
                    } else {
                        allCoords.append(contentsOf: coords.dropFirst())
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
                
                self.finishRouteGeneration(coordinates: allCoords, totalDistance: totalDistance, totalTime: totalTime, config: config, navigationCues: collectedCues)
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
                let coords = self.getCoordinates(from: selectedRoute.polyline)
                legCoordinateSegments[index] = coords
                collectedCues.append(contentsOf: self.buildNavigationCues(from: selectedRoute.steps, distanceOffset: totalDistance))
                
                if self.paceOrder.isEmpty {
                    DispatchQueue.main.async {
                        let styled = StyledPolyline(coordinates: coords, count: coords.count)
                        styled.legIndex = index
                        styled.mode = config.isScenic ? .scenic : .fastest
                        self.mapView.addOverlay(styled)
                    }
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
    private func finishRouteGeneration(coordinates: [CLLocationCoordinate2D], totalDistance: CLLocationDistance, totalTime: TimeInterval, config: RouteConfig, navigationCues: [NavigationCue] = []) {
        updateRouteInfoLabel(distance: totalDistance, time: totalTime)
        resetProgressTracking(totalDistance: totalDistance, routeCoords: coordinates)
        isActivelyWalkingRoute = true
        isGeneratingRoute = false
        currentRouteType = config.type
        beginNavigationCues(navigationCues)
        
        if !paceOrder.isEmpty {
               let pacedSegments = applyPaceToRoute(coordinates: coordinates, totalDistance: totalDistance)
               
               // Remove existing overlays
               mapView.removeOverlays(mapView.overlays)
               
               // Add paced segments
               for segment in pacedSegments {
                   mapView.addOverlay(segment)
               }
           }
           
        
        // UPDATED: Only save if this is a NEW route, not a reload
        if !isReloadingExistingRoute {
            pendingRouteSave = PendingRouteSave(waypoints: selectedCoordinates, coordinates: coordinates, totalDistance: totalDistance, config: config)
            setSaveRoutePillVisible(true)
            print("Route ready to save")
        } else {
            print("Reloaded existing route - not saving duplicate")
            isReloadingExistingRoute = false  // Reset flag for next route
            pendingRouteSave = nil
            setSaveRoutePillVisible(false)
        }
        
        startLiveActivityForCurrentRoute()
    }

    private func saveRouteToDatabase(coordinates: [CLLocationCoordinate2D], totalDistance: CLLocationDistance, config: RouteConfig, name: String? = nil, waypoints: [CLLocationCoordinate2D]? = nil) {
        CoreDataManager.shared.saveRoute(
            routeType: config.type.rawValue,
            isScenicMode: config.isScenic,
            targetDistance: totalDistance / 1609.34,
            direction: config.direction,
            waypoints: waypoints ?? selectedCoordinates,
            fullRoute: coordinates,
            name: name,
            paceConfig: paceOrder.isEmpty ? nil : paceOrder,
            pulseSegmentCount: pulseSegmentCount
        )
    }
    
    private func buildNavigationCues(from steps: [MKRoute.Step], distanceOffset: CLLocationDistance) -> [NavigationCue] {
        var cues: [NavigationCue] = []
        var accumulatedDistance = distanceOffset
        
        for step in steps {
            accumulatedDistance += step.distance
            let instruction = step.instructions.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !instruction.isEmpty else { continue }
            let leadDistance: CLLocationDistance
            switch step.distance {
            case 804...:
                leadDistance = 804
            case 321...:
                leadDistance = 321
            case 120...:
                leadDistance = 120
            default:
                leadDistance = 45
            }
            cues.append(
                NavigationCue(
                    triggerDistance: accumulatedDistance,
                    instruction: instruction,
                    announcementLeadDistance: leadDistance
                )
            )
        }
        
        return cues
    }
    
    private func beginNavigationCues(_ cues: [NavigationCue]) {
        navigationCues = cues.sorted { $0.triggerDistance < $1.triggerDistance }
        nextNavigationCueIndex = 0
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
        let minutes = paceOrder.isEmpty ? (time / 60.0) : estimatedRouteMinutes(totalDistance: distance)
        routeInfoLabel.text = String(format: "%.2f miles • ~%.0f min", miles, minutes)
    }
    
    private func learnedSpeed(for paceType: PaceType) -> Double {
        switch paceType {
        case .walk:
            return walkSampleCount >= 10 ? avgWalkingSpeed : 1.4
        case .jog:
            return jogSampleCount >= 10 ? avgJoggingSpeed : 2.7
        case .run:
            return runSampleCount >= 10 ? avgRunningSpeed : 4.0
        }
    }
    
    private func paceType(at distance: CLLocationDistance, totalDistance: CLLocationDistance? = nil) -> PaceType? {
        let routeDistance = totalDistance ?? totalRouteDistance
        guard routeDistance > 0 else { return nil }
        
        let activePaceSegments = effectivePaceSegments(totalDistance: routeDistance)
        guard !activePaceSegments.isEmpty else { return nil }
        
        let clampedDistance = min(max(distance, 0), routeDistance)
        var segmentStart: CLLocationDistance = 0
        
        for (index, pace) in activePaceSegments.enumerated() {
            let segmentLength = pace.percentage * routeDistance
            let segmentEnd = (index == activePaceSegments.count - 1) ? routeDistance : min(routeDistance, segmentStart + segmentLength)
            if clampedDistance <= segmentEnd || index == activePaceSegments.count - 1 {
                return pace.paceType
            }
            segmentStart = segmentEnd
        }
        
        return activePaceSegments.last?.paceType
    }
    
    private func estimatedRouteMinutes(totalDistance: CLLocationDistance, traveledDistance: CLLocationDistance = 0) -> Double {
        let remainingDistance = max(0, totalDistance - traveledDistance)
        guard remainingDistance > 0 else { return 0 }
        
        let activePaceSegments = effectivePaceSegments(totalDistance: totalDistance)
        guard !activePaceSegments.isEmpty else {
            return (remainingDistance / learnedSpeed(for: .walk)) / 60.0
        }
        
        var remainingMinutes: Double = 0
        var segmentStart: CLLocationDistance = 0
        
        for (index, pace) in activePaceSegments.enumerated() {
            let segmentLength = pace.percentage * totalDistance
            let segmentEnd = (index == activePaceSegments.count - 1) ? totalDistance : min(totalDistance, segmentStart + segmentLength)
            let overlapStart = max(traveledDistance, segmentStart)
            let overlapEnd = min(totalDistance, segmentEnd)
            
            if overlapEnd > overlapStart {
                remainingMinutes += ((overlapEnd - overlapStart) / learnedSpeed(for: pace.paceType)) / 60.0
            }
            
            segmentStart = segmentEnd
        }
        
        return remainingMinutes
    }
    
    private func refreshDisplayedRouteInfo() {
        guard totalRouteDistance > 0 else { return }
        
        if traveledDistance > 0 {
            let remainingMeters = max(0, totalRouteDistance - traveledDistance)
            let remainingMinutes = estimatedRouteMinutes(totalDistance: totalRouteDistance, traveledDistance: traveledDistance)
            routeInfoLabel.text = String(format: "%.2f mi left • ~%.0f min", remainingMeters / 1609.34, remainingMinutes)
        } else {
            let totalMinutes = estimatedRouteMinutes(totalDistance: totalRouteDistance)
            routeInfoLabel.text = String(format: "%.2f miles • ~%.0f min", totalRouteDistance / 1609.34, totalMinutes)
        }
        
        scheduleLiveActivityUpdateIfNeeded()
    }
    
    private func nextNavigationInstructionText() -> String {
        guard nextNavigationCueIndex < navigationCues.count else { return "" }
        return navigationCues[nextNavigationCueIndex].instruction
    }
    
    private func nextNavigationInstructionDistanceFeet() -> Int {
        guard nextNavigationCueIndex < navigationCues.count else { return 0 }
        let remainingDistance = max(0, navigationCues[nextNavigationCueIndex].triggerDistance - traveledDistance)
        return Int((remainingDistance * 3.28084).rounded())
    }
    
    private func currentPaceTypeForRouteState() -> PaceType {
        if let livePace = paceType(at: traveledDistance) {
            return livePace
        }
        return paceOrder.first?.paceType ?? .walk
    }
    
    private func liveActivityContentState() -> MapAppRouteActivityAttributes.ContentState {
        MapAppRouteActivityAttributes.ContentState(
            routeName: currentRouteDisplayName,
            remainingMiles: max(0, totalRouteDistance - traveledDistance) / 1609.34,
            remainingMinutes: Int(estimatedRouteMinutes(totalDistance: totalRouteDistance, traveledDistance: traveledDistance).rounded()),
            nextInstruction: nextNavigationInstructionText(),
            nextInstructionDistanceFeet: nextNavigationInstructionDistanceFeet(),
            currentPaceType: currentPaceTypeForRouteState().rawValue
        )
    }
    
    private func startLiveActivityForCurrentRoute() {
        guard totalRouteDistance > 0 else { return }
        guard #available(iOS 16.1, *) else { return }
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are disabled for this app/device")
            return
        }
        
        let attributes = MapAppRouteActivityAttributes(routeID: UUID().uuidString)
        let content = ActivityContent(
            state: liveActivityContentState(),
            staleDate: Date().addingTimeInterval(300),
            relevanceScore: 100
        )
        
        Task {
            do {
                for activity in Activity<MapAppRouteActivityAttributes>.activities {
                    await activity.end(nil, dismissalPolicy: .immediate)
                }
                routeLiveActivity = try Activity.request(attributes: attributes, content: content, pushType: nil)
                lastLiveActivityUpdateDate = Date()
                print("Live Activity started")
            } catch {
                print("Failed to start Live Activity: \(error.localizedDescription)")
            }
        }
    }
    
    private func startDebugLiveActivityPreviewIfNeeded() {
        guard #available(iOS 16.1, *) else { return }
        guard !hasAttemptedDebugLiveActivityStart else { return }
        hasAttemptedDebugLiveActivityStart = true
        
        guard totalRouteDistance <= 0 else { return }
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Debug Live Activity preview skipped because Live Activities are disabled")
            return
        }
        
        let attributes = MapAppRouteActivityAttributes(routeID: "debug-preview")
        let content = ActivityContent(
            state: MapAppRouteActivityAttributes.ContentState(
                routeName: "MapApp Debug",
                remainingMiles: 1.25,
                remainingMinutes: 18,
                nextInstruction: "Head north to verify the Dynamic Island preview.",
                nextInstructionDistanceFeet: 500,
                currentPaceType: PaceType.walk.rawValue
            ),
            staleDate: Date().addingTimeInterval(300),
            relevanceScore: 100
        )
        
        Task {
            do {
                for activity in Activity<MapAppRouteActivityAttributes>.activities {
                    await activity.end(nil, dismissalPolicy: .immediate)
                }
                routeLiveActivity = try Activity.request(attributes: attributes, content: content, pushType: nil)
                lastLiveActivityUpdateDate = Date()
                print("Debug Live Activity preview started. Active count: \(Activity<MapAppRouteActivityAttributes>.activities.count)")
            } catch {
                print("Debug Live Activity preview failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleLiveActivityUpdateIfNeeded(force: Bool = false) {
        guard totalRouteDistance > 0 else { return }
        guard #available(iOS 16.1, *) else { return }
        guard routeLiveActivity != nil else { return }
        
        let now = Date()
        if !force, let lastUpdate = lastLiveActivityUpdateDate, now.timeIntervalSince(lastUpdate) < 2 {
            return
        }
        
        let content = ActivityContent(
            state: liveActivityContentState(),
            staleDate: now.addingTimeInterval(300),
            relevanceScore: 100
        )
        
        Task {
            await routeLiveActivity?.update(content)
        }
        lastLiveActivityUpdateDate = now
    }
    
    private func endLiveActivity() {
        guard #available(iOS 16.1, *) else { return }
        
        Task {
            for activity in Activity<MapAppRouteActivityAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
            routeLiveActivity = nil
            lastLiveActivityUpdateDate = nil
            print("Live Activity ended")
        }
    }
    
    private func setRouteDisplayName(_ name: String?) {
        let trimmedName = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        currentRouteDisplayName = (trimmedName?.isEmpty == false) ? trimmedName! : "Welcome to APPNAME"
        routeNameLabel?.text = currentRouteDisplayName
    }
    
    private func setSaveRoutePillVisible(_ isVisible: Bool) {
        guard saveRoutePillButton != nil else { return }
        let shouldShow = isVisible && routeSheetState == .collapsed
        
        if shouldShow {
            saveRoutePillButton.isHidden = false
            UIView.animate(withDuration: 0.4) {
                self.saveRoutePillButton.alpha = 1
                self.saveRoutePillButton.transform = .identity
            }
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                self.saveRoutePillButton.alpha = 0
                self.saveRoutePillButton.transform = CGAffineTransform(translationX: 0, y: 8)
            }) { _ in
                self.saveRoutePillButton.isHidden = true
                self.saveRoutePillButton.transform = .identity
            }
        }
    }
}

// MARK: - Pace Segment Calculation
extension ViewController {
    private func effectivePaceSegments(totalDistance: Double) -> [PaceSegmentConfig] {
        let activePaceOrder = paceOrder.filter { $0.percentage >= 0.01 }
        guard !activePaceOrder.isEmpty else { return [] }
        guard pulseSegmentCount > 1 else {
            return activePaceOrder.map {
                PaceSegmentConfig(
                    paceType: $0.paceType,
                    percentage: $0.percentage,
                    distance: $0.percentage * totalDistance
                )
            }
        }
        
        var chunkCounts = activePaceOrder.map { max(0, Int(floor($0.percentage * Double(pulseSegmentCount)))) }
        let fractionalParts = activePaceOrder.enumerated().map {
            (index: $0.offset, fraction: ($0.element.percentage * Double(pulseSegmentCount)) - Double(chunkCounts[$0.offset]))
        }
        
        var assignedChunks = chunkCounts.reduce(0, +)
        let sortedFractions = fractionalParts.sorted { lhs, rhs in
            if lhs.fraction == rhs.fraction {
                return lhs.index < rhs.index
            }
            return lhs.fraction > rhs.fraction
        }
        
        var fractionIndex = 0
        while assignedChunks < pulseSegmentCount && !sortedFractions.isEmpty {
            let targetIndex = sortedFractions[fractionIndex % sortedFractions.count].index
            chunkCounts[targetIndex] += 1
            assignedChunks += 1
            fractionIndex += 1
        }
        
        while assignedChunks > pulseSegmentCount, let removableIndex = chunkCounts.firstIndex(where: { $0 > 0 }) {
            chunkCounts[removableIndex] -= 1
            assignedChunks -= 1
        }
        
        var remainingChunkCounts = chunkCounts
        var effectiveSegments: [PaceSegmentConfig] = []
        var nextStartIndex = 0
        
        while remainingChunkCounts.contains(where: { $0 > 0 }) {
            for offset in 0..<activePaceOrder.count {
                let paceIndex = (nextStartIndex + offset) % activePaceOrder.count
                guard remainingChunkCounts[paceIndex] > 0 else { continue }
                
                let pace = activePaceOrder[paceIndex]
                let repeatedCount = max(1, chunkCounts[paceIndex])
                let chunkPercentage = pace.percentage / Double(repeatedCount)
                effectiveSegments.append(
                    PaceSegmentConfig(
                        paceType: pace.paceType,
                        percentage: chunkPercentage,
                        distance: chunkPercentage * totalDistance
                    )
                )
                remainingChunkCounts[paceIndex] -= 1
                nextStartIndex = (paceIndex + 1) % activePaceOrder.count
                break
            }
        }
        
        if let lastIndex = effectiveSegments.indices.last {
            let totalPercentage = effectiveSegments.reduce(0) { $0 + $1.percentage }
            let correction = 1.0 - totalPercentage
            effectiveSegments[lastIndex].percentage += correction
            effectiveSegments[lastIndex].distance = effectiveSegments[lastIndex].percentage * totalDistance
        }
        
        return effectiveSegments.filter { $0.percentage > 0.0001 }
    }
    
    private func applyPaceToRoute(coordinates: [CLLocationCoordinate2D], totalDistance: Double) -> [StyledPolyline] {
        guard coordinates.count > 1 else { return [] }
        guard !paceOrder.isEmpty else {
            // No pacing - return single segment
            let polyline = StyledPolyline(coordinates: coordinates, count: coordinates.count)
            return [polyline]
        }
        
        print("🎨 Applying pace pattern to route...")
        
        // Calculate segment boundaries based on pace order
        let activePaceOrder = effectivePaceSegments(totalDistance: totalDistance)
        guard !activePaceOrder.isEmpty else {
            let polyline = StyledPolyline(coordinates: coordinates, count: coordinates.count)
            return [polyline]
        }
        
        var segmentBoundaries: [(distance: Double, paceType: PaceType)] = []
        var accumulatedDistance: Double = 0
        
        for (index, pace) in activePaceOrder.enumerated() {
            // Skip segments that round down to 0% in practice.
            if pace.percentage < 0.01 {
                continue
            }
            
            accumulatedDistance += pace.percentage * totalDistance
            print("  - \(pace.paceType.rawValue): 0 → \(Int(accumulatedDistance))m (\(Int(pace.percentage * 100))%)")
            
            if index < activePaceOrder.count - 1 {
                segmentBoundaries.append((accumulatedDistance, pace.paceType))
            }
        }
        
        if segmentBoundaries.isEmpty {
            let polyline = StyledPolyline(coordinates: coordinates, count: coordinates.count)
            polyline.paceType = activePaceOrder[0].paceType
            return [polyline]
        }
        
        // Walk through route coordinates and split exactly at pace boundaries.
        var polylines: [StyledPolyline] = []
        var distanceCovered: Double = 0
        var currentSegmentCoords: [CLLocationCoordinate2D] = [coordinates[0]]
        var boundaryIndex = 0
        var currentPace = activePaceOrder[0].paceType
        
        for i in 1..<coordinates.count {
            let prev = coordinates[i-1]
            let curr = coordinates[i]
            
            let prevLocation = CLLocation(latitude: prev.latitude, longitude: prev.longitude)
            let currLocation = CLLocation(latitude: curr.latitude, longitude: curr.longitude)
            let segmentLength = prevLocation.distance(from: currLocation)
            guard segmentLength > 0 else { continue }
            
            while boundaryIndex < segmentBoundaries.count &&
                    distanceCovered + segmentLength >= segmentBoundaries[boundaryIndex].distance {
                let boundaryDistance = segmentBoundaries[boundaryIndex].distance
                let distanceIntoSegment = boundaryDistance - distanceCovered
                let progress = max(0, min(1, distanceIntoSegment / segmentLength))
                let splitCoordinate = interpolatedCoordinate(from: prev, to: curr, progress: progress)
                
                if currentSegmentCoords.last?.latitude != splitCoordinate.latitude ||
                    currentSegmentCoords.last?.longitude != splitCoordinate.longitude {
                    currentSegmentCoords.append(splitCoordinate)
                }
                
                let polyline = StyledPolyline(coordinates: currentSegmentCoords, count: currentSegmentCoords.count)
                polyline.paceType = currentPace
                polylines.append(polyline)
                
                print("  ✅ Created \(currentPace.rawValue) segment: \(currentSegmentCoords.count) coords")
                
                boundaryIndex += 1
                if boundaryIndex < activePaceOrder.count {
                    currentPace = activePaceOrder[boundaryIndex].paceType
                    currentSegmentCoords = [splitCoordinate]
                }
            }
            
            currentSegmentCoords.append(curr)
            distanceCovered += segmentLength
        }
        
        // Save final segment
        if currentSegmentCoords.count > 1 {
            let polyline = StyledPolyline(coordinates: currentSegmentCoords, count: currentSegmentCoords.count)
            polyline.paceType = currentPace
            polylines.append(polyline)
            print("  ✅ Created final \(currentPace.rawValue) segment: \(currentSegmentCoords.count) coords")
        }
        
        print("🎨 Total segments created: \(polylines.count)")
        return polylines
    }
    
    private func interpolatedCoordinate(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D, progress: Double) -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: start.latitude + ((end.latitude - start.latitude) * progress),
            longitude: start.longitude + ((end.longitude - start.longitude) * progress)
        )
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
            logPaceTransitionIfNeeded()
            speakNextNavigationCueIfNeeded()
        }
        updateWalkedOverlay()
        updateLiveRouteInfo()
    }
    
    private func speakNextNavigationCueIfNeeded() {
        guard nextNavigationCueIndex < navigationCues.count else { return }
        let cue = navigationCues[nextNavigationCueIndex]
        guard traveledDistance + cue.announcementLeadDistance >= cue.triggerDistance else { return }
        
        let remainingDistance = max(0, cue.triggerDistance - traveledDistance)
        speakTurnInstruction(cue.instruction, remainingDistance: remainingDistance)
        nextNavigationCueIndex += 1
        scheduleLiveActivityUpdateIfNeeded(force: true)
    }
    
    private func speakTurnInstruction(_ instruction: String, remainingDistance: CLLocationDistance? = nil) {
        guard !instruction.isEmpty else { return }
        
        let message: String
        if let remainingDistance, remainingDistance > 5 {
            message = "\(spokenDistanceString(for: remainingDistance)), \(instruction)"
        } else {
            message = instruction
        }
        
        speakGuidance(message, interruptCurrent: true)
    }
    
    private func spokenDistanceString(for distance: CLLocationDistance) -> String {
        if distance >= 804 {
            return String(format: "In %.1f miles", distance / 1609.34)
        }
        if distance >= 321 {
            return String(format: "In %.1f miles", distance / 1609.34)
        }
        let roundedFeet = max(50, (distance * 3.28084 / 50).rounded() * 50)
        return "In \(Int(roundedFeet)) feet"
    }
    
    private func logPaceTransitionIfNeeded() {
        guard let currentPace = paceType(at: traveledDistance) else { return }
        guard currentPace != lastLoggedPaceType else { return }
        
        lastLoggedPaceType = currentPace
        playPaceTransitionHaptic(for: currentPace)
        speakPaceTransition(currentPace)
        let currentAverage: Double
        switch currentPace {
        case .walk:
            currentAverage = avgWalkingSpeed
        case .jog:
            currentAverage = avgJoggingSpeed
        case .run:
            currentAverage = avgRunningSpeed
        }
        
        print(
            "🏁 Pace segment switched to \(currentPace.rawValue) | " +
            String(format: "avg %.2f m/s (walk %.2f, jog %.2f, run %.2f)",
                   currentAverage, avgWalkingSpeed, avgJoggingSpeed, avgRunningSpeed)
        )
    }
    
    private func speakPaceTransition(_ paceType: PaceType) {
        let message: String
        switch paceType {
        case .walk:
            message = "Switch to walk pace."
        case .jog:
            message = "Switch to jog pace."
        case .run:
            message = "Switch to run pace."
        }
        speakGuidance(message, interruptCurrent: false)
    }
    
    private func preparePaceHaptics() {
        walkPaceFeedback.prepare()
        jogPaceFeedback.prepare()
        runPaceFeedback.prepare()
    }
    
    private func playPaceTransitionHaptic(for paceType: PaceType) {
        switch paceType {
        case .walk:
            walkPaceFeedback.impactOccurred(intensity: 0.55)
        case .jog:
            jogPaceFeedback.impactOccurred(intensity: 0.8)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                self.jogPaceFeedback.impactOccurred(intensity: 0.55)
                self.jogPaceFeedback.prepare()
            }
        case .run:
            runPaceFeedback.impactOccurred(intensity: 1.0)
        }
        preparePaceHaptics()
    }
    
    private func speakGuidance(_ message: String, interruptCurrent: Bool) {
        guard !message.isEmpty else { return }
        activateSpokenGuidanceAudioSession()
        
        if interruptCurrent, speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.48
        utterance.prefersAssistiveTechnologySettings = true
        speechSynthesizer.speak(utterance)
    }
    
    private func configureSpokenGuidanceAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(
                .playback,
                mode: .voicePrompt,
                options: [.duckOthers, .interruptSpokenAudioAndMixWithOthers]
            )
        } catch {
            print("🔴 Failed to configure spoken guidance audio session: \(error.localizedDescription)")
        }
    }
    
    private func activateSpokenGuidanceAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("🔴 Failed to activate spoken guidance audio session: \(error.localizedDescription)")
        }
    }
    
    private func deactivateSpokenGuidanceAudioSessionIfIdle() {
        guard !speechSynthesizer.isSpeaking, !speechSynthesizer.isPaused else { return }
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("🔴 Failed to deactivate spoken guidance audio session: \(error.localizedDescription)")
        }
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
        
        // Create walked-only overlay so the underlying pace colors stay visible.
        let walkedCoords = Array(currentRouteCoordinates[0...closestIndex])
        guard walkedCoords.count > 1 else { return }
        
        let walkedLine = StyledPolyline(coordinates: walkedCoords, count: walkedCoords.count)
        walkedLine.kind = .walked

        DispatchQueue.main.async {
            self.mapView.addOverlay(walkedLine)
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
        DispatchQueue.main.async {
            self.refreshDisplayedRouteInfo()
        }
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
        
        let shouldHideSavePill = pendingRouteSave != nil && height > (routeSheetCollapsedHeight + 8)
        if pendingRouteSave != nil {
            setSaveRoutePillVisible(!shouldHideSavePill)
        }

        let isFullyCollapsed = height <= (routeSheetCollapsedHeight + 1)
        routeHistorySheet.backgroundColor = isFullyCollapsed ? .clear : .elevatedPanelSurface
        routeHistorySheet.layer.shadowOpacity = isFullyCollapsed ? 0 : 0.1
        
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
        lastLoggedPaceType = nil
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })
        resetProgressTracking(totalDistance: 0, routeCoords: [])
        progressView.setProgress(0, animated: false)
        setRouteDisplayName(nil)
        pendingRouteSave = nil
        setSaveRoutePillVisible(false)
        beginNavigationCues([])
        endLiveActivity()
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
            button.tintColor = .compColor
            if let location = userLocation { safelyCenterMap(on: location, distance: 3000) }
        } else {
            button.setImage(UIImage(systemName: "location"), for: .normal)
            button.tintColor = .floatingButtonForeground
        }
    }

    private func animateSettingsCog(_ button: UIButton, clockwise: Bool = true) {
        let rotation = clockwise ? CGFloat.pi : -CGFloat.pi
        UIView.animate(withDuration: 0.3) {
            button.transform = CGAffineTransform(rotationAngle: rotation)
        } completion: { _ in
            button.transform = .identity
        }
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


// MARK: - @objc Handlers     TEMPORARY NEED TO ADD SECTION FOR EACH AREA
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
        selectedDirectionButton?.backgroundColor = .panelNeutralButtonBackground
        selectedDirectionButton?.setTitleColor(.panelBodyTextColor, for: .normal)
        if selectedDirectionButton == sender { selectedDirectionButton = nil; selectedDirection = "random"; return }
        sender.backgroundColor = .appPrimary
        sender.setTitleColor(.floatingButtonForeground, for: .normal)
        selectedDirectionButton = sender
        selectedDirection = direction
    }

    @objc private func loopPointStepperChanged(_ sender: UIStepper) { selectedLoopPoints = Int(sender.value); loopPointLabel?.text = "Loop Points: \(selectedLoopPoints)" }

    @objc private func clearRandomSettings() {
        distanceTextField?.text = ""
        selectedDirectionButton?.backgroundColor = .panelNeutralButtonBackground
        selectedDirectionButton?.setTitleColor(.panelBodyTextColor, for: .normal)
        selectedDirectionButton = nil
        selectedDirection = "random"
        useTimeInput = false
        distanceOrTimeLabel?.text = "Distance (miles)"
        distanceTextField?.placeholder = "e.g. 3.1"
        timeToggle?.setOn(false, animated: true)
    }

    @objc private func dismissKeyboard() { view.endEditing(true); closePanel() }
    
    @objc private func goToButtonTapped() {
        let alert = UIAlertController(title: "Search Destination", message: "Enter a city, address, or place.", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "e.g., Kansas City, MO or McDonalds"
            textField.returnKeyType = .search
        }
        
        let searchAction = UIAlertAction(title: "Search", style: .default) { [weak self, weak alert] _ in
            guard let query = alert?.textFields?.first?.text, !query.isEmpty else { return }
            self?.searchAndGo(to: query)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(searchAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func saveRoutePillTapped() {
        guard pendingRouteSave != nil else { return }
        presentSaveRouteDialog()
    }
    func searchAndGo(to query: String) {
            // 1. Create a search request
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            
            // Optional: Bias the search results to the area the user is currently viewing
            // This helps if they search "McDonalds" so it finds the closest one, not one in another state.
            request.region = mapView.region
            
            // 2. Initialize the search
            let search = MKLocalSearch(request: request)
            
            // Show a loading indicator here if you have one
            
            // 3. Start the search
            search.start { [weak self] (response, error) in
                guard let self = self else { return }
                
                // Handle errors (e.g., no internet)
                if let error = error {
                    print("Search failed with error: \(error.localizedDescription)")
                    // You might want to show a UIAlertController here letting the user know
                    return
                }
                
                // Ensure we got a valid response with at least one map item
                guard let response = response, let topResult = response.mapItems.first else {
                    print("No results found for \(query).")
                    return
                }
                
                // 4. Extract the data
                let coordinate = topResult.placemark.coordinate
                let name = topResult.name ?? "Unknown Location"
                let address = topResult.placemark.title ?? "" // Usually contains the full formatted address
                
                print("Found: \(name) at \(address)")
                
                // Optional: Clear old search pins before adding a new one
                // Let's assume you only want one "Go To" pin at a time.
                let existingAnnotations = self.mapView.annotations.filter { !($0 is MKUserLocation) }
                self.mapView.removeAnnotations(existingAnnotations)
                
                // 5. Create and add the new pin (Annotation)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = name
                annotation.subtitle = address
                self.mapView.addAnnotation(annotation)
                
                // 6. Move the camera to the new location
                // Apple provides a bounding region in the response which is perfectly sized for the result
                // (e.g., zoomed out for a city, zoomed in for a restaurant)
                self.mapView.setRegion(response.boundingRegion, animated: true)
                
                // Select the annotation so the title/subtitle bubble pops up automatically
                self.mapView.selectAnnotation(annotation, animated: true)
            }
            
        }
        
    
    
    private func presentSaveRouteDialog() {
        guard let pendingRouteSave else { return }
        
        let alert = UIAlertController(title: "Save Route", message: "Give this route a name.", preferredStyle: .alert)
        alert.addTextField { textField in
            let currentName = self.currentRouteDisplayName
            textField.placeholder = "Route name"
            textField.text = currentName == "Current Route" || currentName == "Welcome Back" ? "" : currentName
            textField.autocapitalizationType = .words
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            let enteredName = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let finalName = (enteredName?.isEmpty == false) ? enteredName : nil
            self.saveRouteToDatabase(
                coordinates: pendingRouteSave.coordinates,
                totalDistance: pendingRouteSave.totalDistance,
                config: pendingRouteSave.config,
                name: finalName,
                waypoints: pendingRouteSave.waypoints
            )
            self.pendingRouteSave = nil
            self.setSaveRoutePillVisible(false)
            self.setRouteDisplayName(finalName ?? "Current Route")
            self.loadSavedRoutes()
            self.showInfoAlert(message: "Route saved.")
        })
        
        present(alert, animated: true)
    }
}

// MARK: - Pace Panel Actions
extension ViewController {
    private func redrawCurrentPacedRouteIfNeeded() {
        guard !currentRouteCoordinates.isEmpty, totalRouteDistance > 0 else { return }
        let pacedSegments = applyPaceToRoute(coordinates: currentRouteCoordinates, totalDistance: totalRouteDistance)
        mapView.removeOverlays(mapView.overlays.filter { $0 is StyledPolyline })
        pacedSegments.forEach { mapView.addOverlay($0) }
        refreshDisplayedRouteInfo()
    }
    
    private func applyPulseSegmentCount(_ count: Int) {
        pulseSegmentCount = max(1, count)
        updatePulseButtonTitle()
        redrawCurrentPacedRouteIfNeeded()
        print("〰️ Pulse mode set to \(pulseSegmentCount == 1 ? "Off" : "\(pulseSegmentCount) segments")")
    }
    
    @objc private func paceSliderChanged(_ sender: UISlider) {
        let allSliders = [walkSlider, jogSlider, runSlider].compactMap { $0 }
        let otherSliders = allSliders.filter { $0 !== sender }
        let available = max(0, 1 - Double(sender.value))
        let currentOtherTotal = otherSliders.reduce(0.0) { $0 + Double($1.value) }
        
        if currentOtherTotal > 0 {
            for slider in otherSliders {
                slider.value = Float((Double(slider.value) / currentOtherTotal) * available)
            }
        } else {
            let evenShare = Float(available / Double(max(otherSliders.count, 1)))
            otherSliders.forEach { $0.value = evenShare }
        }
        
        updatePaceConfiguration()
    }
    
    private func updatePaceConfiguration() {
        let total = max(Double(walkSlider.value + jogSlider.value + runSlider.value), 0.0001)
        let walk = Double(walkSlider.value) / total
        let jog = Double(jogSlider.value) / total
        let run = Double(runSlider.value) / total
        
        walkSlider.value = Float(walk)
        jogSlider.value = Float(jog)
        runSlider.value = Float(run)
        
        // Update percentage labels
        walkPercentLabel.text = "\(Int(walk * 100))%"
        jogPercentLabel.text = "\(Int(jog * 100))%"
        runPercentLabel.text = "\(Int(run * 100))%"
        
        // 🆕 UPDATE: Calculate distances if we have an active route
        let routeDistance = totalRouteDistance / 1609.34  // Convert meters to miles
        
        // Update pace order array
        if paceOrder.isEmpty {
            paceOrder = [
                PaceSegmentConfig(paceType: .walk, percentage: walk, distance: walk * routeDistance),
                PaceSegmentConfig(paceType: .jog, percentage: jog, distance: jog * routeDistance),
                PaceSegmentConfig(paceType: .run, percentage: run, distance: run * routeDistance)
            ]
        } else {
            for i in 0..<paceOrder.count {
                switch paceOrder[i].paceType {
                case .walk:
                    paceOrder[i].percentage = walk
                    paceOrder[i].distance = walk * routeDistance
                case .jog:
                    paceOrder[i].percentage = jog
                    paceOrder[i].distance = jog * routeDistance
                case .run:
                    paceOrder[i].percentage = run
                    paceOrder[i].distance = run * routeDistance
                }
            }
        }
        
        print("Walk: \(Int(walk * 100))%, Jog: \(Int(jog * 100))%, Run: \(Int(run * 100))%")
        
        updatePaceChips()
        
        //  Redraw route with new pacing if route exists
        if !currentRouteCoordinates.isEmpty && totalRouteDistance > 0 {
            let pacedSegments = applyPaceToRoute(coordinates: currentRouteCoordinates, totalDistance: totalRouteDistance)
            mapView.removeOverlays(mapView.overlays)
            pacedSegments.forEach { mapView.addOverlay($0) }
            refreshDisplayedRouteInfo()
        }
    }
    
    private func updatePaceChips() {
        let currentOrder = paceOrder.map { $0.paceType }
        
        // CHECK 1: Is this the first time? Build from scratch
        if paceChipsContainer.arrangedSubviews.isEmpty {
            rebuildPaceChips()
            lastPaceOrder = currentOrder
            return
        }
        
        // CHECK 2: Did the ORDER change? (tap/drag to swap)
        if currentOrder != lastPaceOrder {
            // Order changed - rebuild with animation
            rebuildPaceChipsAnimated()
            lastPaceOrder = currentOrder
            return
        }
        
        // CHECK 3: Only PERCENTAGES changed (slider moved)
        // Just update the text labels - no rebuilding!
        for (i, pace) in paceOrder.enumerated() {
            guard i < pacePercentLabels.count else { continue }
            let label = pacePercentLabels[i]
            let newText = "\(Int(pace.percentage * 100))%"
            
            if label.text != newText {
                crossfadeText(label: label, to: newText)
            }
        }
    }
    
    private func rebuildPaceChips() {
        paceChipsContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        pacePercentLabels.removeAll()
        
        for (index, pace) in paceOrder.enumerated() {
            let chip = createPaceChip(pace: pace, index: index)
            
            if let percentLabel = chip.subviews.compactMap({ $0 as? UILabel }).last {
                pacePercentLabels.append(percentLabel)
            } else {
                let fallback = UILabel()
                fallback.font = .systemFont(ofSize: 10, weight: .bold)
                fallback.textAlignment = .center
                fallback.textColor = pace.color
                fallback.text = "\(Int(pace.percentage * 100))%"
                fallback.translatesAutoresizingMaskIntoConstraints = false
                chip.addSubview(fallback)
                NSLayoutConstraint.activate([
                    fallback.centerXAnchor.constraint(equalTo: chip.centerXAnchor),
                    fallback.bottomAnchor.constraint(equalTo: chip.bottomAnchor, constant: -6)
                ])
                pacePercentLabels.append(fallback)
            }
            
            paceChipsContainer.addArrangedSubview(chip)
        }
    }
    
    private func rebuildPaceChipsAnimated() {
        // Fade out old chips
        UIView.animate(withDuration: 0.15, animations: {
            self.paceChipsContainer.alpha = 0
        }) { _ in
            self.rebuildPaceChips()
            
            // Fade in new chips
            UIView.animate(withDuration: 0.15) {
                self.paceChipsContainer.alpha = 1
            }
        }
    }
    
    // animation
    private func crossfadeText(label: UILabel, to newText: String) {
        UIView.transition(with: label, duration: 0.12, options: .transitionCrossDissolve, animations: {
            label.text = newText
        }, completion: nil)
    }
    // animation
    private func pop(label: UILabel) {
        UIView.animate(withDuration: 0.08, animations: {
            label.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
        }) { _ in
            UIView.animate(withDuration: 0.08) {
                label.transform = .identity
            }
        }
    }
    
    private func createPaceChip(pace: PaceSegmentConfig, index: Int) -> UIView {
        let chip = UIView()
        chip.backgroundColor = pace.color.withAlphaComponent(0.2)
        chip.layer.cornerRadius = 8
        chip.layer.borderWidth = 2
        chip.layer.borderColor = pace.color.cgColor
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: pace.symbolName)
        iconImageView.tintColor = pace.color
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        chip.addSubview(iconImageView)
        
        let percentLabel = UILabel()
        percentLabel.text = "\(Int(pace.percentage * 100))%"
        percentLabel.font = .systemFont(ofSize: 10, weight: .bold)
        percentLabel.textAlignment = .center
        percentLabel.textColor = pace.color
        percentLabel.translatesAutoresizingMaskIntoConstraints = false
        chip.addSubview(percentLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: chip.centerXAnchor),
            iconImageView.topAnchor.constraint(equalTo: chip.topAnchor, constant: 10),
            iconImageView.widthAnchor.constraint(equalToConstant: 26),
            iconImageView.heightAnchor.constraint(equalToConstant: 26),
            
            percentLabel.centerXAnchor.constraint(equalTo: chip.centerXAnchor),
            percentLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 2)
        ])
        
        // Add tap gesture to swap positions
        chip.tag = index
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(paceChipTapped(_:)))
        chip.addGestureRecognizer(tapGesture)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleChipDrag(_:)))
        chip.addGestureRecognizer(panGesture)
        chip.isUserInteractionEnabled = true
        
        return chip
    }
    
    @objc private func paceChipTapped(_ gesture: UITapGestureRecognizer) {
        guard let chip = gesture.view else { return }
        let index = chip.tag
        
        // Simple interaction: swap with next chip (cycles around)
        let nextIndex = (index + 1) % paceOrder.count
        paceOrder.swapAt(index, nextIndex)
        
        updatePaceChips()
        redrawCurrentPacedRouteIfNeeded()
        
        print("🔄 New pace order: \(paceOrder.map { $0.paceType.rawValue }.joined(separator: " → "))")
    }
    
    @objc private func handleChipDrag(_ gesture: UIPanGestureRecognizer) {
        guard let draggedChip = gesture.view else { return }
        let translation = gesture.translation(in: paceChipsContainer)
        
        switch gesture.state {
        case .began:
            paceChipsContainer.bringSubviewToFront(draggedChip)
            UIView.animate(withDuration: 0.2) {
                draggedChip.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                draggedChip.alpha = 0.8
            }
            
        case .changed:
            draggedChip.center.x += translation.x
            gesture.setTranslation(.zero, in: paceChipsContainer)
            
            let draggedIndex = draggedChip.tag
            let chips = paceChipsContainer.arrangedSubviews
            
            for (i, otherChip) in chips.enumerated() where i != draggedIndex {
                if draggedChip.frame.midX > otherChip.frame.minX &&
                    draggedChip.frame.midX < otherChip.frame.maxX {
                    paceOrder.swapAt(draggedIndex, i)
                    paceChipsContainer.removeArrangedSubview(draggedChip)
                    draggedChip.removeFromSuperview()
                    paceChipsContainer.insertArrangedSubview(draggedChip, at: i)
                    
                    for (updatedIndex, chip) in paceChipsContainer.arrangedSubviews.enumerated() {
                        chip.tag = updatedIndex
                    }
                    
                    lastPaceOrder = paceOrder.map { $0.paceType }
                    
                    UIView.animate(withDuration: 0.2) {
                        self.paceChipsContainer.layoutIfNeeded()
                    }
                    
                    break
                }
            }
            
        case .ended, .cancelled:
            UIView.animate(withDuration: 0.3) {
                draggedChip.transform = .identity
                draggedChip.alpha = 1.0
                self.paceChipsContainer.layoutIfNeeded()
            }
            
            print("🔄 New pace order: \(paceOrder.map { $0.paceType.rawValue }.joined(separator: " → "))")
            
            // Redraw route with new pace order
            if !self.currentRouteCoordinates.isEmpty && self.totalRouteDistance > 0 {
                self.redrawCurrentPacedRouteIfNeeded()
            }
            
        default:
            break
        }
    }
    
    @objc private func randomizePacePercentages() {
        let walk = Double.random(in: 0.1...1.0)
        let jog = Double.random(in: 0.1...1.0)
        let run = Double.random(in: 0.1...1.0)
        let total = walk + jog + run
        
        walkSlider.value = Float(walk / total)
        jogSlider.value = Float(jog / total)
        runSlider.value = Float(run / total)
        
        updatePaceConfiguration()
        
        print("🎲 Randomized: Walk \(Int((walk / total) * 100))%, Jog \(Int((jog / total) * 100))%, Run \(Int((run / total) * 100))%")
    }
    
    @objc private func shufflePaceOrder() {
        paceOrder.shuffle()
        updatePaceChips()
        redrawCurrentPacedRouteIfNeeded()
        print("🔀 Shuffled order: \(paceOrder.map { $0.paceType.rawValue }.joined(separator: " → "))")
    }
}

// MARK: - Speed Learning
extension ViewController {
    private func updateSpeedAverages(speed: CLLocationSpeed) {
        guard speed > 0 else { return }
        
        let learnedPaceType: PaceType?
        if isActivelyWalkingRoute {
            learnedPaceType = paceType(at: traveledDistance)
        } else {
            learnedPaceType = nil
        }
        
        switch learnedPaceType {
        case .walk?:
            avgWalkingSpeed = ((avgWalkingSpeed * Double(walkSampleCount)) + speed) / Double(walkSampleCount + 1)
            walkSampleCount += 1
            logSpeedLearningUpdate(paceType: .walk, sampledSpeed: speed)
        case .jog?:
            avgJoggingSpeed = ((avgJoggingSpeed * Double(jogSampleCount)) + speed) / Double(jogSampleCount + 1)
            jogSampleCount += 1
            logSpeedLearningUpdate(paceType: .jog, sampledSpeed: speed)
        case .run?:
            avgRunningSpeed = ((avgRunningSpeed * Double(runSampleCount)) + speed) / Double(runSampleCount + 1)
            runSampleCount += 1
            logSpeedLearningUpdate(paceType: .run, sampledSpeed: speed)
        case nil:
            switch speed {
            case ..<2.0:
                avgWalkingSpeed = ((avgWalkingSpeed * Double(walkSampleCount)) + speed) / Double(walkSampleCount + 1)
                walkSampleCount += 1
                logSpeedLearningUpdate(paceType: .walk, sampledSpeed: speed, source: "threshold")
            case 2.0..<3.5:
                avgJoggingSpeed = ((avgJoggingSpeed * Double(jogSampleCount)) + speed) / Double(jogSampleCount + 1)
                jogSampleCount += 1
                logSpeedLearningUpdate(paceType: .jog, sampledSpeed: speed, source: "threshold")
            default:
                avgRunningSpeed = ((avgRunningSpeed * Double(runSampleCount)) + speed) / Double(runSampleCount + 1)
                runSampleCount += 1
                logSpeedLearningUpdate(paceType: .run, sampledSpeed: speed, source: "threshold")
            }
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
    
    private func printSpeedAverages() {
        let currentPace = paceType(at: traveledDistance)?.rawValue ?? "None"
        print(
            """
            📊 Speed averages
            - Current pace segment: \(currentPace)
            - Walk: \(String(format: "%.2f", avgWalkingSpeed)) m/s (\(walkSampleCount) samples)
            - Jog: \(String(format: "%.2f", avgJoggingSpeed)) m/s (\(jogSampleCount) samples)
            - Run: \(String(format: "%.2f", avgRunningSpeed)) m/s (\(runSampleCount) samples)
            """
        )
    }
    
    private func logSpeedLearningUpdate(paceType: PaceType, sampledSpeed: CLLocationSpeed, source: String = "pace segment") {
        let updatedAverage: Double
        let sampleCount: Int
        
        switch paceType {
        case .walk:
            updatedAverage = avgWalkingSpeed
            sampleCount = walkSampleCount
        case .jog:
            updatedAverage = avgJoggingSpeed
            sampleCount = jogSampleCount
        case .run:
            updatedAverage = avgRunningSpeed
            sampleCount = runSampleCount
        }
        
        print(
            "📈 Updated \(paceType.rawValue) average via \(source): " +
            String(format: "sample %.2f m/s -> avg %.2f m/s (%d samples)",
                   sampledSpeed, updatedAverage, sampleCount)
        )
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
            
            if let paceType = styled.paceType {
                       // Color based on pace
                       switch paceType {
                       case .walk:
                           renderer.strokeColor = .systemGreen
                           renderer.lineWidth = 6
                       case .jog:
                           renderer.strokeColor = .systemOrange
                           renderer.lineWidth = 6
                       case .run:
                           renderer.strokeColor = .systemRed
                           renderer.lineWidth = 6
                       }
                       return renderer
                   }
            
            
            switch styled.kind {
            case .walked:
                renderer.strokeColor = UIColor.black.withAlphaComponent(0.28)
                renderer.lineWidth = 9
                renderer.lineCap = .round
                renderer.lineJoin = .round
            case .remaining:
                renderer.strokeColor = .clear
                renderer.lineWidth = 0
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
        searchCompleter.region = mapView.region
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

extension ViewController: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        deactivateSpokenGuidanceAudioSessionIfIdle()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        deactivateSpokenGuidanceAudioSessionIfIdle()
    }
}

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pulseOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let value = pulseOptions[row]
        return value == 1 ? "Off" : "\(value) segments"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        applyPulseSegmentCount(pulseOptions[row])
    }
}

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
        let routeName = route.name ?? "Route #\(route.routeNumber)"
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
        // Step 1: Get the search text and trim whitespace
                // .trimmingCharacters removes spaces from start/end
                let searchText = searchText.trimmingCharacters(in: .whitespaces)
                
                // Step 2: Apply both search AND filters together
                applySearchAndFilters(searchText: searchText)
            }
            
            // Called when user taps the search button on keyboard
            func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
                searchBar.resignFirstResponder()  // Dismiss keyboard
            }
            
            // Called when user taps Cancel button (if visible)
            func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
                searchBar.text = ""
                searchBar.resignFirstResponder()
                applySearchAndFilters(searchText: "")
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
        // marks that we are remaking a route not making a new one
        isReloadingExistingRoute = true
        // clear existing routes
        clearAllRoutes()
        
        // decode waypoints
        guard let waypointsData = route.waypointsData,
              let waypoints = CoreDataManager.shared.decodeCoordinates(waypointsData) else {showErrorAlert(title: "", message: "Could not load route waypoints")
            return
        }
        
        // set up UI to match route settings
        routeTypeSelector.selectedSegmentIndex = Int(route.routeType)
        lastRouteTypeSelection = Int(route.routeType)
        useScenicRouting = route.isScenicMode
        setRouteDisplayName(route.name ?? "Route #\(route.routeNumber)")
        
        // store waypoints
        selectedCoordinates = waypoints

        // Restore pace configuration
        if let paceData = route.paceOrderData,
           let savedPaceConfig = CoreDataManager.shared.decodePaceConfig(paceData) {
            paceOrder = savedPaceConfig.segments
            pulseSegmentCount = savedPaceConfig.pulseSegmentCount
            updatePulseButtonTitle()
            
            if let walkPace = paceOrder.first(where: { $0.paceType == .walk }) {
                walkSlider.value = Float(walkPace.percentage)
            }
            if let jogPace = paceOrder.first(where: { $0.paceType == .jog }) {
                jogSlider.value = Float(jogPace.percentage)
            }
            if let runPace = paceOrder.first(where: { $0.paceType == .run }) {
                runSlider.value = Float(runPace.percentage)
            }
            
            updatePaceConfiguration()
        }
        
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
    
    private func applySearchAndFilters(searchText: String) {
        // STEP 1: Start with all routes from database
        var results = savedRoutes
        
        // STEP 2: Apply search filter (if search text exists)
        if !searchText.isEmpty {
            results = results.filter { route in
                // Get route name (or default if unnamed)
                let routeName = (route.name ?? "Route #\(route.routeNumber)").lowercased()
                
                // Get route type as text
                let routeType: String
                switch route.routeType {
                case 0: routeType = "one-way oneway"
                case 1: routeType = "out back outandback"
                case 2: routeType = "loop"
                default: routeType = ""
                }
                
                // Get distance as text
                let distance = String(format: "%.2f", route.targetDistance)
                
                // Get mode
                let mode = route.isScenicMode ? "scenic" : "fastest"
                
                // Get favorite status
                let favoriteText = route.isFavorite ? "favorite starred" : ""
                
                // Combine all searchable fields into one string
                let searchableText = "\(routeName) \(routeType) \(distance) \(mode) \(favoriteText)"
                
                // Check if the search text appears anywhere in searchable text
                // .lowercased() makes search case-insensitive
                return searchableText.contains(searchText.lowercased())
            }
        }
        
        // STEP 3: Apply "show only favorites" filter
        if showOnlyFavorites {
            results = results.filter { $0.isFavorite == true }
        }
        
        // STEP 4: Apply "route type" filter
        if let typeFilter = filterByRouteType {
            results = results.filter { $0.routeType == typeFilter }
        }
        
        // STEP 5: Apply "route vibe" filter
        if let vibeFilter = filterByScenicMode {
            results = results.filter { $0.isScenicMode == vibeFilter }
        }
        
        // STEP 6: Sort the remaining routes
        switch sortOption {
        case .none:
            // No sorting - keep database order
            break
            
        case .newestFirst:
            results.sort { route1, route2 in
                guard let date1 = route1.createdDate, let date2 = route2.createdDate else { return false }
                return date1 > date2
            }
            
        case .oldestFirst:
            results.sort { route1, route2 in
                guard let date1 = route1.createdDate, let date2 = route2.createdDate else { return false }
                return date1 < date2
            }
            
        case .shortestDistance:
            results.sort { route1, route2 in
                return route1.targetDistance < route2.targetDistance
            }
            
        case .longestDistance:
            results.sort { route1, route2 in
                return route1.targetDistance > route2.targetDistance
            }
            
        case .shortestTime:
            results.sort { route1, route2 in
                let speedMPH = walkSampleCount >= 10 ? avgWalkingSpeed * 2.23694 : 3.5
                let time1 = (route1.targetDistance / speedMPH) * 60
                let time2 = (route2.targetDistance / speedMPH) * 60
                return time1 < time2
            }
            
        case .longestTime:
            results.sort { route1, route2 in
                let speedMPH = walkSampleCount >= 10 ? avgWalkingSpeed * 2.23694 : 3.5
                let time1 = (route1.targetDistance / speedMPH) * 60
                let time2 = (route2.targetDistance / speedMPH) * 60
                return time1 > time2
            }
            
        case .nameAZ:
            results.sort { route1, route2 in
                let name1 = route1.name ?? "Route #\(route1.routeNumber)"
                let name2 = route2.name ?? "Route #\(route2.routeNumber)"
                return name1 < name2
            }
            
        case .nameZA:
            results.sort { route1, route2 in
                let name1 = route1.name ?? "Route #\(route1.routeNumber)"
                let name2 = route2.name ?? "Route #\(route2.routeNumber)"
                return name1 > name2
            }
        }
        
        // STEP 7: Update what table displays
        filteredRoutes = results
        
        // STEP 8: Refresh table to display new stuff
        routesTableView.reloadData()
        
        // STEP 9: Rebuild menu to update checkmarks
        setupFilterMenu()
        
        // Debug: show what happened
        if searchText.isEmpty {
            print("🎯 Applied filters: \(results.count) routes match")
        } else {
            print("🔍 Search: '\(searchText)' with filters → \(results.count) routes match")
        }
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
    
    private func confirmClearAllData() {
        let alert = UIAlertController(
            title: "Clear All Routes?",
            message: "This will permanently delete ALL \(savedRoutes.count) saved routes AND reset route numbering to start from #1 again. This cannot be undone.",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let deleteAction = UIAlertAction(title: "Delete All & Reset", style: .destructive) { [weak self] _ in
            self?.clearAllRoutesAndResetCounter()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        present(alert, animated: true)
    }
    
    private func confirmResetEverything() {
        let alert = UIAlertController(
            title: "Reset Everything?",
            message: "This will delete ALL routes, reset route counter, AND reset speed data. This is a complete fresh start and cannot be undone.",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let resetAction = UIAlertAction(title: "Reset Everything", style: .destructive) { [weak self] _ in
            self?.resetEverythingToDefaults()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(resetAction)
        
        present(alert, animated: true)
    }
    
    private func clearAllRoutesAndResetCounter() {
        // Delete all routes from Core Data
        for route in savedRoutes {
            CoreDataManager.shared.deleteRoute(route)
        }
        
        // Reset route counter
        CoreDataManager.shared.resetRouteCounter()
        
        // Clear arrays
        savedRoutes.removeAll()
        filteredRoutes.removeAll()
        
        // Reload table
        routesTableView.reloadData()
        
        print("🗑️ All routes cleared and counter reset")
        showInfoAlert(message: "All routes deleted. Next route will be Route #1")
    }
    
    private func resetEverythingToDefaults() {
        // Clear all routes and reset counter
        clearAllRoutesAndResetCounter()
        
        // Reset speed data
        resetSpeedData()
        
        print("♻️ Everything reset to defaults")
        showInfoAlert(message: "Everything reset! Fresh start.")
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
        
        print("🗑️ All routes cleared (counter NOT reset)")
    }
    
    private func applyFiltersAndSort()
    {
        // Get current search text (if any)
        let searchText = routesSearchBar.text?.trimmingCharacters(in: .whitespaces) ?? ""
        
        // Apply both search and filters together
        applySearchAndFilters(searchText: searchText)
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

 
    This week:
        Figure out test cases
    
        Pacing pattern implemenation
 
        Think about ada compliance.
 
 
ISSUE: 3/31/2026
 Walked route breaks colro stuff. See if only drawing over user has walked is possible on top layer onstead of redrawing evertime a new segment is done.
 Breaks means that the pacing colors get overidden by the walked on route colors where it is blue where not walked and green at the moment for walked. Probably change it to an opaic grey/black.
 
 
More stuff I'd like to do: :
    I added color themes for later use, but I would also like to make darkmode versions for all of the themes I got. 4/2/2026 done (partial)
 
    whenver clear is hit also clear out the route info label up top. 4/2/2026 Done
 
    Make it to when the app is completely closed out it stops widget use.
    
    Make go to into more of a google search thing not lat and long for locations. 4/3/2026 Partially done need to add auto complete but priamary funcanality is there.
 
    Make it to where settings actually does settings things:
        1. allow user to pick color theme
        2. allow user to turn off and on talking and vibrations
        3. allow user to reset there average speeds for each pace (allow to reset individually) and this would also be the place that they can see there average speeds for each pace.
        4. F.A.Q. thing or maybe a way to contact me if issue occurs (maybe)
    
    Make a tutorial that happens on first launch of the app that goes around and does the "Spotlight" walkthrough i'll call it where it only lets you click certain things while having what needs to be clicked brightly with a text box that shows up expalining what stuff does.
    
    when the user is on a route have it to where if center on user button on whatever direction the user is walking is north (that way left and rights don't get confusing)
    
    Add animaitons to just about everthing to make it feel more professional.
 
 
 Way in the future additions:
 add apple watch compatability
 */
