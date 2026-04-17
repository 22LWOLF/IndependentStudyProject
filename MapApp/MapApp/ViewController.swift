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
import AudioToolbox

// MARK: - Color Scheme
struct AppPalette {
    let primary: UIColor
    let secondary: UIColor
    let background: UIColor
    let floatingButtonBackground: UIColor
    let floatingButtonForeground: UIColor
    let sidePanelBackground: UIColor
}

private enum ThemeAppearance {
    static var usesDarkVariant = false
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

    // MARK: Sunrise Route
    case sunriseRoute

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
        case .sunriseRoute: return "Sunrise Route"
        }
    }

    private var lightPalette: AppPalette {
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
        case .sunriseRoute:
            return AppPalette(
                primary: UIColor(hex: "#7FB8D6"),
                secondary: UIColor(hex: "#F5C84B"),
                background: UIColor(hex: "#071426"),
                floatingButtonBackground: UIColor(hex: "#F5C84B"),
                floatingButtonForeground: UIColor(hex: "#071426"),
                sidePanelBackground: UIColor(hex: "#EAF4F8")
            )
        }
    }

    private var darkPalette: AppPalette {
        switch self {
        case .wildflowerTrail:
            return AppPalette(
                primary: UIColor(hex: "#92A573"),
                secondary: UIColor(hex: "#B7849E"),
                background: UIColor(hex: "#171116"),
                floatingButtonBackground: UIColor(hex: "#231B20"),
                floatingButtonForeground: UIColor(hex: "#F8F3F5"),
                sidePanelBackground: UIColor(hex: "#221920")
            )
        case .coastalMorning:
            return AppPalette(
                primary: UIColor(hex: "#84A8CC"),
                secondary: UIColor(hex: "#F0B79A"),
                background: UIColor(hex: "#0F1821"),
                floatingButtonBackground: UIColor(hex: "#18222E"),
                floatingButtonForeground: UIColor(hex: "#F5FAFF"),
                sidePanelBackground: UIColor(hex: "#17212C")
            )
        case .canyonPath:
            return AppPalette(
                primary: UIColor(hex: "#DB8F73"),
                secondary: UIColor(hex: "#9DB694"),
                background: UIColor(hex: "#181210"),
                floatingButtonBackground: UIColor(hex: "#261D19"),
                floatingButtonForeground: UIColor(hex: "#FFF5EF"),
                sidePanelBackground: UIColor(hex: "#211915")
            )
        case .earlyFrost:
            return AppPalette(
                primary: UIColor(hex: "#9DCDC0"),
                secondary: UIColor(hex: "#B7AAD0"),
                background: UIColor(hex: "#121B1A"),
                floatingButtonBackground: UIColor(hex: "#1A2624"),
                floatingButtonForeground: UIColor(hex: "#F1F8F6"),
                sidePanelBackground: UIColor(hex: "#182321")
            )
        case .urbanFog:
            return AppPalette(
                primary: UIColor(hex: "#99A3AA"),
                secondary: UIColor(hex: "#E0C17B"),
                background: UIColor(hex: "#121416"),
                floatingButtonBackground: UIColor(hex: "#1B1E21"),
                floatingButtonForeground: UIColor(hex: "#F7F8F9"),
                sidePanelBackground: UIColor(hex: "#1B1E20")
            )
        case .eveningStroll:
            return AppPalette(
                primary: UIColor(hex: "#D9A0A0"),
                secondary: UIColor(hex: "#E0B47A"),
                background: UIColor(hex: "#180F13"),
                floatingButtonBackground: UIColor(hex: "#26161A"),
                floatingButtonForeground: UIColor(hex: "#FFF2F2"),
                sidePanelBackground: UIColor(hex: "#221419")
            )
        case .sunriseRoute:
            return AppPalette(
                primary: UIColor(hex: "#87C8EA"),
                secondary: UIColor(hex: "#FFD15A"),
                background: UIColor(hex: "#04101E"),
                floatingButtonBackground: UIColor(hex: "#102B45"),
                floatingButtonForeground: UIColor(hex: "#F8D76A"),
                sidePanelBackground: UIColor(hex: "#0C2237")
            )
        }
    }

    var palette: AppPalette {
        ThemeAppearance.usesDarkVariant ? darkPalette : lightPalette
    }
}

extension UIColor {
    static var activeTheme: AppTheme = .sunriseRoute
    static var activeThemeIndex: Int {
        get { activeTheme.index }
        set { activeTheme = AppTheme(index: newValue) }
    }
    static var usesDarkThemeVariant: Bool {
        get { ThemeAppearance.usesDarkVariant }
        set { ThemeAppearance.usesDarkVariant = newValue }
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
        case .sunriseRoute:
            return darkColor
                .blended(withFraction: 0.32, of: appPrimary)
                .blended(withFraction: 0.12, of: compColor)
                .withAlphaComponent(0.60)
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
        case .sunriseRoute:
            return darkColor
                .blended(withFraction: 0.32, of: appPrimary)
                .blended(withFraction: 0.12, of: compColor)
                .withAlphaComponent(0.60)
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
        case .sunriseRoute:
            return sidePanelBackground.blended(withFraction: 0.18, of: appPrimary)
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
        case .sunriseRoute:
            return sidePanelBackground.blended(withFraction: 0.16, of: compColor)
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
        case .sunriseRoute:
            return sidePanelBackground.blended(withFraction: 0.22, of: appPrimary)
        }
    }
    static var dividerColor: UIColor { compColor.withAlphaComponent(0.32) }
    static var panelNeutralButtonBackground: UIColor { sidePanelBackground.blended(withFraction: 0.18, of: darkColor) }
    static var panelNeutralButtonForeground: UIColor { activeTheme.palette.floatingButtonForeground }
    static var activeCenterButtonTint: UIColor {
        activeTheme == .sunriseRoute ? UIColor(hex: "#071426") : floatingButtonForeground
    }
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

private struct TutorialStep {
    let title: String
    let message: String
    let prepare: (ViewController) -> Void
    let highlightRect: (ViewController) -> CGRect?
}

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

final class PlaceSearchViewController: UIViewController {
    var onSelection: ((MKMapItem, MKCoordinateRegion?) -> Void)?

    private let searchBar = UISearchBar()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let completer = MKLocalSearchCompleter()
    private var completions: [MKLocalSearchCompletion] = []
    private var currentSearch: MKLocalSearch?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search Destination"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(closeTapped)
        )

        setupSearchBar()
        setupTableView()
        setupCompleter()
    }

    private func setupSearchBar() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Search for a place or address"
        searchBar.returnKeyType = .search
        searchBar.autocapitalizationType = .words
        searchBar.delegate = self
        view.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlaceResultCell")
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupCompleter() {
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest, .query]
    }

    private func updateSearchResults(for query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            completions = []
            tableView.reloadData()
            return
        }

        completer.queryFragment = trimmedQuery
    }

    private func resolveCompletion(_ completion: MKLocalSearchCompletion) {
        let request = MKLocalSearch.Request(completion: completion)
        executeSearch(request: request)
    }

    private func executeNaturalLanguageSearch(_ query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = trimmedQuery
        executeSearch(request: request)
    }

    private func executeSearch(request: MKLocalSearch.Request) {
        request.resultTypes = .address
        currentSearch?.cancel()

        let search = MKLocalSearch(request: request)
        currentSearch = search

        search.start { [weak self] response, error in
            guard let self else { return }

            if let error {
                self.presentError(message: error.localizedDescription)
                return
            }

            guard let response, let mapItem = response.mapItems.first else {
                self.presentError(message: "No matching locations were found.")
                return
            }

            self.onSelection?(mapItem, response.boundingRegion)
            self.dismiss(animated: true)
        }
    }

    private func presentError(message: String) {
        let alert = UIAlertController(title: "Search Failed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

extension PlaceSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateSearchResults(for: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        executeNaturalLanguageSearch(searchBar.text ?? "")
    }
}

extension PlaceSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        completions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceResultCell", for: indexPath)
        let completion = completions[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = completion.title
        content.secondaryText = completion.subtitle
        content.textProperties.numberOfLines = 2
        content.secondaryTextProperties.numberOfLines = 2
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator

        return cell
    }
}

extension PlaceSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        resolveCompletion(completions[indexPath.row])
    }
}

extension PlaceSearchViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completions = completer.results
        tableView.reloadData()
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        completions = []
        tableView.reloadData()
        print("Place autocomplete failed: \(error.localizedDescription)")
    }
}

final class SettingsViewController: UIViewController {
    struct SpeedStat {
        let title: String
        let metersPerSecond: Double
        let sampleCount: Int
    }

    var selectedThemeIndex: Int = 0
    var isVoiceGuidanceEnabled: Bool = true
    var isHapticsEnabled: Bool = true
    var speedStats: [SpeedStat] = []
    var onThemeSelected: ((Int) -> Void)?
    var onVoiceGuidanceChanged: ((Bool) -> Void)?
    var onHapticsChanged: ((Bool) -> Void)?
    var onResetSpeed: ((Int) -> Void)?
    var onReplayTutorial: (() -> Void)?

    private let scrollView = UIScrollView()
    private let contentView = UIStackView()
    private let voiceToggle = UISwitch()
    private let hapticsToggle = UISwitch()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemGroupedBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Help",
            style: .plain,
            target: self,
            action: #selector(helpTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(closeTapped)
        )

        setupLayout()
        renderSections()
    }

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.axis = .vertical
        contentView.spacing = 18

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            contentView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24)
        ])
    }

    func renderSections() {
        contentView.arrangedSubviews.forEach { view in
            contentView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        contentView.addArrangedSubview(makeThemeSection())
        contentView.addArrangedSubview(makeNavigationSection())
        contentView.addArrangedSubview(makeSpeedSection())
        contentView.addArrangedSubview(makeSupportSection())
    }

    private func makeSectionCard(title: String) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 14
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
        stack.backgroundColor = .secondarySystemGroupedBackground
        stack.layer.cornerRadius = 18

        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .secondaryLabel
        stack.addArrangedSubview(label)

        return stack
    }

    private func makeThemeSection() -> UIView {
        let section = makeSectionCard(title: "THEME")

        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        row.distribution = .fill

        let themeButton = UIButton(type: .system)
        themeButton.configuration = .filled()
        themeButton.configuration?.title = AppTheme(index: selectedThemeIndex).displayName
        themeButton.configuration?.image = UIImage(systemName: "chevron.up.chevron.down")
        themeButton.configuration?.imagePlacement = .trailing
        themeButton.configuration?.imagePadding = 8
        themeButton.configuration?.baseBackgroundColor = .systemPink
        themeButton.configuration?.baseForegroundColor = .white
        themeButton.configuration?.cornerStyle = .capsule

        let actions = AppTheme.allCases.enumerated().map { index, theme in
            UIAction(
                title: theme.displayName,
                state: index == selectedThemeIndex ? .on : .off
            ) { [weak self] _ in
                self?.selectedThemeIndex = index
                self?.onThemeSelected?(index)
                self?.renderSections()
            }
        }
        themeButton.menu = UIMenu(title: "Choose Theme", options: .displayInline, children: actions)
        themeButton.showsMenuAsPrimaryAction = true
        themeButton.translatesAutoresizingMaskIntoConstraints = false
        themeButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 180).isActive = true

        let swatchRow = makeThemeSwatchRow(theme: AppTheme(index: selectedThemeIndex))

        row.addArrangedSubview(themeButton)
        row.addArrangedSubview(swatchRow)
        section.addArrangedSubview(row)
        return section
    }

    private func makeThemeSwatchRow(theme: AppTheme) -> UIView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center

        let colors = [
            theme.palette.primary,
            theme.palette.secondary,
            theme.palette.background
        ]

        for color in colors {
            let swatch = UIView()
            swatch.translatesAutoresizingMaskIntoConstraints = false
            swatch.backgroundColor = color
            swatch.layer.cornerRadius = 8
            swatch.layer.borderWidth = 1
            swatch.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
            NSLayoutConstraint.activate([
                swatch.widthAnchor.constraint(equalToConstant: 24),
                swatch.heightAnchor.constraint(equalToConstant: 24)
            ])
            stack.addArrangedSubview(swatch)
        }

        return stack
    }

    private func makeNavigationSection() -> UIView {
        let section = makeSectionCard(title: "NAVIGATION")
        voiceToggle.isOn = isVoiceGuidanceEnabled
        hapticsToggle.isOn = isHapticsEnabled
        voiceToggle.addTarget(self, action: #selector(voiceChanged(_:)), for: .valueChanged)
        hapticsToggle.addTarget(self, action: #selector(hapticsChanged(_:)), for: .valueChanged)

        section.addArrangedSubview(makeToggleRow(title: "Voice Directions", subtitle: "Spoken turn cues and pace prompts", toggle: voiceToggle))
        section.addArrangedSubview(makeDivider())
        section.addArrangedSubview(makeToggleRow(title: "Vibrations", subtitle: "Pace transition haptics", toggle: hapticsToggle))
        return section
    }

    private func makeSpeedSection() -> UIView {
        let section = makeSectionCard(title: "PACE STATS")

        for (index, stat) in speedStats.enumerated() {
            section.addArrangedSubview(makeSpeedRow(stat: stat, index: index))
            if index < speedStats.count - 1 {
                section.addArrangedSubview(makeDivider())
            }
        }

        return section
    }

    private func makeSupportSection() -> UIView {
        let section = makeSectionCard(title: "HELP")

        let faqLabel = UILabel()
        faqLabel.numberOfLines = 0
        faqLabel.font = .systemFont(ofSize: 15)
        faqLabel.textColor = .label
        faqLabel.text = "FAQ: Use Go To to search places, Generate to build a route, and tap the location button to follow yourself on-map."
        section.addArrangedSubview(faqLabel)

        let contactButton = UIButton(type: .system)
        contactButton.configuration = .filled()
        contactButton.configuration?.title = "Contact Support"
        contactButton.configuration?.baseBackgroundColor = .systemOrange
        contactButton.configuration?.baseForegroundColor = .white
        contactButton.configuration?.cornerStyle = .capsule
        contactButton.addTarget(self, action: #selector(contactSupportTapped), for: .touchUpInside)
        section.addArrangedSubview(contactButton)

        let tutorialButton = UIButton(type: .system)
        tutorialButton.configuration = .filled()
        tutorialButton.configuration?.title = "Replay Tutorial"
        tutorialButton.configuration?.baseBackgroundColor = .systemTeal
        tutorialButton.configuration?.baseForegroundColor = .white
        tutorialButton.configuration?.cornerStyle = .capsule
        tutorialButton.addTarget(self, action: #selector(replayTutorialTapped), for: .touchUpInside)
        section.addArrangedSubview(tutorialButton)

        return section
    }

    private func makeToggleRow(title: String, subtitle: String, toggle: UISwitch) -> UIView {
        let container = UIView()
        let titleLabel = UILabel()
        let subtitleLabel = UILabel()

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        toggle.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0

        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)
        container.addSubview(toggle)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),

            subtitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: toggle.leadingAnchor, constant: -12),

            toggle.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            toggle.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        return container
    }

    private func makeSpeedRow(stat: SpeedStat, index: Int) -> UIView {
        let container = UIView()
        let titleLabel = UILabel()
        let detailLabel = UILabel()
        let resetButton = UIButton(type: .system)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        resetButton.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = stat.title
        titleLabel.font = .systemFont(ofSize: 17, weight: .medium)

        let mph = stat.metersPerSecond * 2.23694
        detailLabel.text = String(format: "%.2f m/s • %.2f mph • %d samples", stat.metersPerSecond, mph, stat.sampleCount)
        detailLabel.font = .systemFont(ofSize: 13)
        detailLabel.textColor = .secondaryLabel
        detailLabel.numberOfLines = 0

        resetButton.setTitle("Reset", for: .normal)
        resetButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        resetButton.configuration = .tinted()
        resetButton.configuration?.baseForegroundColor = .systemRed
        resetButton.configuration?.cornerStyle = .capsule
        resetButton.tag = index
        resetButton.addTarget(self, action: #selector(resetSpeedTapped(_:)), for: .touchUpInside)

        container.addSubview(titleLabel)
        container.addSubview(detailLabel)
        container.addSubview(resetButton)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),

            detailLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            detailLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: resetButton.leadingAnchor, constant: -12),

            resetButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            resetButton.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        return container
    }

    private func makeDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = .separator
        divider.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
        return divider
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func helpTapped() {
        let alert = UIAlertController(
            title: "How To Use StepOut",
            message: """
            Go To: search for a destination.
            Generate: build a route from your current pins or random settings.
            Clear/Cancel: remove the active route and stop navigation.
            Center button: follow your location on the map.
            Pace button: set walk, jog, and run segments.
            Route settings button: open random generation and route options.
            Settings: themes, voice, haptics, and pace stats.
            """,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func voiceChanged(_ sender: UISwitch) {
        onVoiceGuidanceChanged?(sender.isOn)
    }

    @objc private func hapticsChanged(_ sender: UISwitch) {
        onHapticsChanged?(sender.isOn)
    }

    @objc private func resetSpeedTapped(_ sender: UIButton) {
        onResetSpeed?(sender.tag)
    }

    @objc private func contactSupportTapped() {
        let email = "mailto:stepout.support@example.com?subject=StepOut%20Issue"
        if let url = URL(string: email), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            let alert = UIAlertController(
                title: "Contact Support",
                message: "Email stepout.support@example.com with a description of the issue.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    @objc private func replayTutorialTapped() {
        dismiss(animated: true) {
            self.onReplayTutorial?()
        }
    }
}

final class SpotlightTutorialView: UIView {
    struct Content {
        let title: String
        let message: String
        let stepText: String
        let highlightRect: CGRect
        let showsBack: Bool
        let isLastStep: Bool
    }

    var onNext: (() -> Void)?
    var onBack: (() -> Void)?
    var onSkip: (() -> Void)?

    private let dimLayer = CAShapeLayer()
    private let highlightRingLayer = CAShapeLayer()
    private let cardView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let stepLabel = UILabel()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let buttonStack = UIStackView()
    private let backButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let skipButton = UIButton(type: .system)
    private var currentHighlightRect: CGRect = .zero

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func render(_ content: Content) {
        currentHighlightRect = content.highlightRect
        stepLabel.text = content.stepText
        titleLabel.text = content.title
        messageLabel.text = content.message
        backButton.isHidden = !content.showsBack
        nextButton.setTitle(content.isLastStep ? "Done" : "Next", for: .normal)
        setNeedsLayout()
        layoutIfNeeded()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        dimLayer.frame = bounds
        highlightRingLayer.frame = bounds

        let paddedRect = currentHighlightRect.insetBy(dx: -12, dy: -12)
        let holePath = UIBezierPath(rect: bounds)
        let roundedHighlight = UIBezierPath(roundedRect: paddedRect, cornerRadius: 18)
        holePath.append(roundedHighlight)
        dimLayer.path = holePath.cgPath

        highlightRingLayer.path = UIBezierPath(roundedRect: paddedRect, cornerRadius: 18).cgPath

        let horizontalInset: CGFloat = 20
        let cardWidth = min(bounds.width - (horizontalInset * 2), 320)
        let preferredSize = cardView.systemLayoutSizeFitting(
            CGSize(width: cardWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        let spaceAbove = paddedRect.minY - safeAreaInsets.top
        let spaceBelow = bounds.maxY - safeAreaInsets.bottom - paddedRect.maxY
        let placeBelow = spaceBelow >= max(preferredSize.height + 24, 180) || spaceBelow >= spaceAbove
        let cardY: CGFloat

        if placeBelow {
            cardY = min(bounds.height - safeAreaInsets.bottom - preferredSize.height - 16, paddedRect.maxY + 18)
        } else {
            cardY = max(safeAreaInsets.top + 16, paddedRect.minY - preferredSize.height - 18)
        }

        let cardX = min(
            max(horizontalInset, paddedRect.midX - (cardWidth / 2)),
            bounds.width - horizontalInset - cardWidth
        )

        cardView.frame = CGRect(x: cardX, y: cardY, width: cardWidth, height: preferredSize.height)
    }

    private func setupView() {
        backgroundColor = .clear

        dimLayer.fillRule = .evenOdd
        dimLayer.fillColor = UIColor.black.withAlphaComponent(0.68).cgColor
        layer.addSublayer(dimLayer)

        highlightRingLayer.strokeColor = UIColor.white.withAlphaComponent(0.88).cgColor
        highlightRingLayer.fillColor = UIColor.clear.cgColor
        highlightRingLayer.lineWidth = 2
        layer.addSublayer(highlightRingLayer)

        cardView.layer.cornerRadius = 22
        cardView.layer.masksToBounds = true
        addSubview(cardView)

        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        cardView.contentView.addSubview(contentStack)

        stepLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        stepLabel.textColor = UIColor.white.withAlphaComponent(0.72)

        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0

        messageLabel.font = .systemFont(ofSize: 15, weight: .regular)
        messageLabel.textColor = UIColor.white.withAlphaComponent(0.92)
        messageLabel.numberOfLines = 0

        buttonStack.axis = .horizontal
        buttonStack.spacing = 10
        buttonStack.distribution = .fillEqually

        configureTutorialButton(backButton, title: "Back", backgroundColor: UIColor.white.withAlphaComponent(0.12))
        configureTutorialButton(nextButton, title: "Next", backgroundColor: UIColor.systemPink.withAlphaComponent(0.92))
        configureTutorialButton(skipButton, title: "Skip", backgroundColor: UIColor.white.withAlphaComponent(0.12))

        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)

        buttonStack.addArrangedSubview(backButton)
        buttonStack.addArrangedSubview(nextButton)
        buttonStack.addArrangedSubview(skipButton)

        contentStack.addArrangedSubview(stepLabel)
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(messageLabel)
        contentStack.addArrangedSubview(buttonStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: cardView.contentView.topAnchor, constant: 18),
            contentStack.leadingAnchor.constraint(equalTo: cardView.contentView.leadingAnchor, constant: 18),
            contentStack.trailingAnchor.constraint(equalTo: cardView.contentView.trailingAnchor, constant: -18),
            contentStack.bottomAnchor.constraint(equalTo: cardView.contentView.bottomAnchor, constant: -18),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            nextButton.heightAnchor.constraint(equalToConstant: 40),
            skipButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func configureTutorialButton(_ button: UIButton, title: String, backgroundColor: UIColor) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 12
    }

    @objc private func nextTapped() {
        onNext?()
    }

    @objc private func backTapped() {
        onBack?()
    }

    @objc private func skipTapped() {
        onSkip?()
    }
}

final class RouteSplashView: UIView {
    private struct StepMarker {
        let center: CGPoint
        let angle: CGFloat
        let isLeft: Bool
    }

    private enum SplashColors {
        static let routeYellow = UIColor(red: 1.00, green: 0.80, blue: 0.28, alpha: 1.0)
    }

    private let backdropLayer = CAGradientLayer()
    private let ambientGlowLayer = CAGradientLayer()
    private let pathShadowLayer = CAShapeLayer()
    private let pathLineLayer = CAShapeLayer()
    private let destinationRingLayer = CAShapeLayer()
    private let travelPulseLayer = CAShapeLayer()

    private let brandHaloView = UIView()
    private let sunClipView = UIView()
    private let brandDiskView = UIView()
    private let horizonLineView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    private var stepLayers: [CAShapeLayer] = []
    private var hasBuiltLayers = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backdropLayer.frame = bounds
        ambientGlowLayer.frame = bounds
        layoutBrandViews()

        if !hasBuiltLayers {
            buildArtwork()
            hasBuiltLayers = true
        } else {
            updateArtworkPaths()
        }
    }

    func playAnimation(completion: @escaping () -> Void) {
        layoutIfNeeded()
        alpha = 1
        transform = .identity

        pathShadowLayer.strokeEnd = 0
        pathShadowLayer.opacity = 0.22
        pathLineLayer.strokeEnd = 0
        pathLineLayer.opacity = 0.15
        destinationRingLayer.opacity = 0
        travelPulseLayer.opacity = 0

        for stepLayer in stepLayers {
            stepLayer.opacity = 0
            stepLayer.transform = CATransform3DMakeScale(0.72, 0.72, 1)
        }

        brandHaloView.alpha = 0
        sunClipView.alpha = 0
        brandDiskView.alpha = 0
        horizonLineView.alpha = 0
        brandDiskView.transform = CGAffineTransform(translationX: 0, y: max(1, brandDiskView.bounds.height / 2))
        titleLabel.alpha = 0
        subtitleLabel.alpha = 0
        titleLabel.transform = CGAffineTransform(translationX: 0, y: 16)
        subtitleLabel.transform = CGAffineTransform(translationX: 0, y: 14)

        UIView.animate(withDuration: 0.46, delay: 0.05, options: [.curveEaseOut]) {
            self.brandHaloView.alpha = 1
            self.sunClipView.alpha = 1
            self.brandDiskView.alpha = 1
            self.horizonLineView.alpha = 1
            self.titleLabel.alpha = 1
            self.subtitleLabel.alpha = 0.92
            self.titleLabel.transform = .identity
            self.subtitleLabel.transform = .identity
        }

        UIView.animate(withDuration: 1.1, delay: 0.18, options: [.curveEaseInOut]) {
            self.brandDiskView.transform = .identity
        }

        let shadowDraw = CABasicAnimation(keyPath: "strokeEnd")
        shadowDraw.fromValue = 0
        shadowDraw.toValue = 1
        shadowDraw.duration = 1.05
        shadowDraw.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        shadowDraw.fillMode = .forwards
        shadowDraw.isRemovedOnCompletion = false
        pathShadowLayer.add(shadowDraw, forKey: "drawShadowPath")
        pathShadowLayer.strokeEnd = 1

        let lineDraw = CABasicAnimation(keyPath: "strokeEnd")
        lineDraw.fromValue = 0
        lineDraw.toValue = 1
        lineDraw.duration = 1.2
        lineDraw.beginTime = CACurrentMediaTime() + 0.12
        lineDraw.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        lineDraw.fillMode = .forwards
        lineDraw.isRemovedOnCompletion = false
        pathLineLayer.add(lineDraw, forKey: "drawMainPath")
        pathLineLayer.strokeEnd = 1

        let lineFade = CABasicAnimation(keyPath: "opacity")
        lineFade.fromValue = 0.15
        lineFade.toValue = 1
        lineFade.duration = 0.5
        lineFade.beginTime = CACurrentMediaTime() + 0.12
        lineFade.fillMode = .forwards
        lineFade.isRemovedOnCompletion = false
        pathLineLayer.add(lineFade, forKey: "fadeMainPath")
        pathLineLayer.opacity = 1

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            self.travelPulseLayer.opacity = 1

            let travel = CAKeyframeAnimation(keyPath: "position")
            travel.path = self.pathLineLayer.path
            travel.duration = 1.35
            travel.calculationMode = .paced
            travel.rotationMode = .rotateAuto
            travel.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            travel.fillMode = .forwards
            travel.isRemovedOnCompletion = false
            self.travelPulseLayer.add(travel, forKey: "travelPulse")
        }

        for (index, stepLayer) in stepLayers.enumerated() {
            let delay = 0.42 + (Double(index) * 0.13)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                UIView.animate(withDuration: 0.28, delay: 0, options: [.curveEaseOut]) {
                    stepLayer.opacity = index == self.stepLayers.count - 1 ? 0.9 : 0.72
                    stepLayer.transform = CATransform3DIdentity
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.12) {
            let ringAppear = CABasicAnimation(keyPath: "opacity")
            ringAppear.fromValue = 0
            ringAppear.toValue = 1
            ringAppear.duration = 0.22
            ringAppear.fillMode = .forwards
            ringAppear.isRemovedOnCompletion = false
            self.destinationRingLayer.add(ringAppear, forKey: "ringAppear")
            self.destinationRingLayer.opacity = 1

            let ringPulse = CAKeyframeAnimation(keyPath: "transform.scale")
            ringPulse.values = [0.92, 1.10, 1.04, 1.0]
            ringPulse.keyTimes = [0.0, 0.48, 0.78, 1.0]
            ringPulse.duration = 0.82
            ringPulse.timingFunctions = [
                CAMediaTimingFunction(name: .easeOut),
                CAMediaTimingFunction(name: .easeInEaseOut),
                CAMediaTimingFunction(name: .easeInEaseOut)
            ]
            self.destinationRingLayer.add(ringPulse, forKey: "ringPulse")

        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.34) {
            UIView.animate(withDuration: 0.36, delay: 0, options: [.curveEaseInOut]) {
                self.brandHaloView.transform = CGAffineTransform(scaleX: 1.18, y: 1.18)
                self.brandDiskView.transform = CGAffineTransform(scaleX: 1.06, y: 1.06)
                self.horizonLineView.transform = CGAffineTransform(scaleX: 1.08, y: 1.0)
            } completion: { _ in
                UIView.animate(withDuration: 0.42, delay: 0, options: [.curveEaseInOut]) {
                    self.brandHaloView.transform = .identity
                    self.brandDiskView.transform = .identity
                    self.horizonLineView.transform = .identity
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.55) {
            UIView.animate(withDuration: 0.46, delay: 0, options: [.curveEaseInOut]) {
                self.alpha = 0
                self.transform = CGAffineTransform(scaleX: 1.018, y: 1.018)
            } completion: { _ in
                self.removeFromSuperview()
                completion()
            }
        }
    }

    private func setupView() {
        isUserInteractionEnabled = false
        backgroundColor = UIColor(red: 0.04, green: 0.05, blue: 0.11, alpha: 1.0)

        backdropLayer.colors = [
            UIColor(red: 0.04, green: 0.05, blue: 0.11, alpha: 1.0).cgColor,
            UIColor(red: 0.09, green: 0.11, blue: 0.23, alpha: 1.0).cgColor,
            UIColor(red: 0.03, green: 0.07, blue: 0.14, alpha: 1.0).cgColor
        ]
        backdropLayer.locations = [0.0, 0.58, 1.0]
        backdropLayer.startPoint = CGPoint(x: 0.08, y: 0.02)
        backdropLayer.endPoint = CGPoint(x: 0.92, y: 1.0)
        layer.addSublayer(backdropLayer)

        ambientGlowLayer.colors = [
            UIColor(red: 1.00, green: 0.77, blue: 0.28, alpha: 0.44).cgColor,
            UIColor(red: 0.39, green: 1.00, blue: 0.78, alpha: 0.18).cgColor,
            UIColor.clear.cgColor
        ]
        ambientGlowLayer.type = .radial
        ambientGlowLayer.locations = [0.0, 0.34, 0.92]
        ambientGlowLayer.startPoint = CGPoint(x: 0.28, y: 0.74)
        ambientGlowLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        layer.addSublayer(ambientGlowLayer)

        pathShadowLayer.fillColor = UIColor.clear.cgColor
        pathShadowLayer.strokeColor = UIColor.white.withAlphaComponent(0.18).cgColor
        pathShadowLayer.lineWidth = 16
        pathShadowLayer.lineCap = .round
        pathShadowLayer.lineJoin = .round
        layer.addSublayer(pathShadowLayer)

        pathLineLayer.fillColor = UIColor.clear.cgColor
        pathLineLayer.strokeColor = UIColor(red: 0.83, green: 1.00, blue: 0.86, alpha: 1.0).cgColor
        pathLineLayer.lineWidth = 6
        pathLineLayer.lineCap = .round
        pathLineLayer.lineJoin = .round
        layer.addSublayer(pathLineLayer)

        destinationRingLayer.fillColor = UIColor.clear.cgColor
        destinationRingLayer.strokeColor = SplashColors.routeYellow.cgColor
        destinationRingLayer.lineWidth = 3
        destinationRingLayer.opacity = 0
        layer.addSublayer(destinationRingLayer)

        travelPulseLayer.fillColor = SplashColors.routeYellow.cgColor
        travelPulseLayer.strokeColor = UIColor.white.withAlphaComponent(0.72).cgColor
        travelPulseLayer.lineWidth = 2
        layer.addSublayer(travelPulseLayer)

        brandHaloView.backgroundColor = UIColor(red: 1.00, green: 0.80, blue: 0.28, alpha: 0.12)
        addSubview(brandHaloView)

        sunClipView.clipsToBounds = true
        sunClipView.backgroundColor = .clear
        addSubview(sunClipView)

        brandDiskView.backgroundColor = SplashColors.routeYellow
        brandDiskView.layer.borderWidth = 2
        brandDiskView.layer.borderColor = UIColor.white.withAlphaComponent(0.42).cgColor
        sunClipView.addSubview(brandDiskView)

        horizonLineView.backgroundColor = UIColor.white.withAlphaComponent(0.78)
        horizonLineView.layer.shadowColor = SplashColors.routeYellow.cgColor
        horizonLineView.layer.shadowOpacity = 0.32
        horizonLineView.layer.shadowRadius = 8
        horizonLineView.layer.shadowOffset = .zero
        addSubview(horizonLineView)

        titleLabel.text = "STEP OUT"
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.96)
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .black)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.75
        addSubview(titleLabel)

        subtitleLabel.text = "Comfort zones. Bedrooms. Offices. and more..."
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.74)
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        addSubview(subtitleLabel)
    }

    private func layoutBrandViews() {
        let badgeCenter = CGPoint(x: bounds.width * 0.50, y: bounds.height * 0.27)
        let diskSize = min(bounds.width, bounds.height) * 0.16
        let haloSize = diskSize * 1.78
        let horizonY = badgeCenter.y + (diskSize / 2)
        let sunClipWidth = diskSize * 1.32
        let sunClipHeight = diskSize * 1.18

        brandHaloView.bounds = CGRect(x: 0, y: 0, width: haloSize, height: haloSize)
        brandHaloView.center = badgeCenter
        brandHaloView.layer.cornerRadius = haloSize / 2

        sunClipView.frame = CGRect(
            x: badgeCenter.x - (sunClipWidth / 2),
            y: horizonY - sunClipHeight,
            width: sunClipWidth,
            height: sunClipHeight
        )

        brandDiskView.bounds = CGRect(x: 0, y: 0, width: diskSize, height: diskSize)
        brandDiskView.center = CGPoint(x: sunClipView.bounds.midX, y: sunClipView.bounds.maxY - (diskSize / 2))
        brandDiskView.layer.cornerRadius = diskSize / 2

        horizonLineView.frame = CGRect(
            x: badgeCenter.x - (diskSize * 0.78),
            y: horizonY - 1.5,
            width: diskSize * 1.56,
            height: 3
        )
        horizonLineView.layer.cornerRadius = horizonLineView.bounds.height / 2

        titleLabel.frame = CGRect(
            x: 32,
            y: horizonLineView.frame.maxY + 18,
            width: bounds.width - 64,
            height: 40
        )
        subtitleLabel.frame = CGRect(
            x: 24,
            y: titleLabel.frame.maxY + 4,
            width: bounds.width - 48,
            height: 22
        )
    }

    private func buildArtwork() {
        for _ in 0..<6 {
            let stepLayer = CAShapeLayer()
            stepLayer.fillColor = SplashColors.routeYellow.cgColor
            stepLayer.strokeColor = UIColor.white.withAlphaComponent(0.22).cgColor
            stepLayer.lineWidth = 1
            stepLayer.shadowColor = UIColor(red: 0.39, green: 1.00, blue: 0.78, alpha: 0.65).cgColor
            stepLayer.shadowOpacity = 0.22
            stepLayer.shadowRadius = 7
            stepLayer.shadowOffset = .zero
            layer.addSublayer(stepLayer)
            stepLayers.append(stepLayer)
        }

        updateArtworkPaths()
    }

    private func updateArtworkPaths() {
        let travelPath = steppingPath()
        pathShadowLayer.path = travelPath.cgPath
        pathLineLayer.path = travelPath.cgPath

        let pulseDotSize = min(bounds.width, bounds.height) * 0.034
        travelPulseLayer.path = UIBezierPath(
            ovalIn: CGRect(x: -pulseDotSize / 2, y: -pulseDotSize / 2, width: pulseDotSize, height: pulseDotSize)
        ).cgPath

        let markers = stepMarkers()
        for (index, marker) in markers.enumerated() where index < stepLayers.count {
            let size = stepSize(for: index)
            stepLayers[index].path = footprintClusterPath(center: marker.center, size: size, angle: marker.angle, isLeft: marker.isLeft).cgPath
        }

        let destinationCenter = destinationPoint()
        let ringSize = min(bounds.width, bounds.height) * 0.084
        destinationRingLayer.path = UIBezierPath(
            ovalIn: CGRect(
                x: destinationCenter.x - (ringSize / 2),
                y: destinationCenter.y - (ringSize / 2),
                width: ringSize,
                height: ringSize
            )
        ).cgPath

    }

    private func steppingPath() -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.width * 0.32, y: bounds.height * 0.84))
        path.addCurve(
            to: CGPoint(x: bounds.width * 0.45, y: bounds.height * 0.74),
            controlPoint1: CGPoint(x: bounds.width * 0.33, y: bounds.height * 0.81),
            controlPoint2: CGPoint(x: bounds.width * 0.39, y: bounds.height * 0.77)
        )
        path.addCurve(
            to: CGPoint(x: bounds.width * 0.60, y: bounds.height * 0.64),
            controlPoint1: CGPoint(x: bounds.width * 0.50, y: bounds.height * 0.71),
            controlPoint2: CGPoint(x: bounds.width * 0.56, y: bounds.height * 0.67)
        )
        path.addCurve(
            to: CGPoint(x: bounds.width * 0.76, y: bounds.height * 0.50),
            controlPoint1: CGPoint(x: bounds.width * 0.64, y: bounds.height * 0.59),
            controlPoint2: CGPoint(x: bounds.width * 0.71, y: bounds.height * 0.53)
        )
        return path
    }

    private func destinationPoint() -> CGPoint {
        CGPoint(x: bounds.width * 0.76, y: bounds.height * 0.50)
    }

    private func stepMarkers() -> [StepMarker] {
        let routeFlowAngle: CGFloat = 0
        return [
            StepMarker(center: CGPoint(x: bounds.width * 0.32, y: bounds.height * 0.84), angle: routeFlowAngle, isLeft: true),
            StepMarker(center: CGPoint(x: bounds.width * 0.38, y: bounds.height * 0.79), angle: routeFlowAngle, isLeft: true),
            StepMarker(center: CGPoint(x: bounds.width * 0.45, y: bounds.height * 0.74), angle: routeFlowAngle, isLeft: true),
            StepMarker(center: CGPoint(x: bounds.width * 0.53, y: bounds.height * 0.69), angle: routeFlowAngle, isLeft: true),
            StepMarker(center: CGPoint(x: bounds.width * 0.61, y: bounds.height * 0.63), angle: routeFlowAngle, isLeft: true),
            StepMarker(center: CGPoint(x: bounds.width * 0.69, y: bounds.height * 0.56), angle: routeFlowAngle, isLeft: true)
        ]
    }

    private func stepSize(for index: Int) -> CGSize {
        let baseWidth = bounds.width * 0.072
        let baseHeight = baseWidth * 1.46
        let scale = 1.0 - (CGFloat(index) * 0.03)
        return CGSize(width: baseWidth * scale, height: baseHeight * scale)
    }

    private func footprintClusterPath(center: CGPoint, size: CGSize, angle: CGFloat, isLeft: Bool) -> UIBezierPath {
        let path = UIBezierPath()
        let direction: CGFloat = isLeft ? -1 : 1
        let radiusBase = size.width * 0.18
        let circles: [(offset: CGPoint, radius: CGFloat)] = [
            (CGPoint(x: -size.width * 0.22 * direction, y: -size.height * 0.30), radiusBase * 0.72),
            (CGPoint(x: 0, y: -size.height * 0.06), radiusBase * 0.92),
            (CGPoint(x: size.width * 0.20 * direction, y: size.height * 0.22), radiusBase * 1.18)
        ]

        for circle in circles {
            let circleCenter = CGPoint(
                x: center.x + circle.offset.x,
                y: center.y + circle.offset.y
            )
            path.append(
                UIBezierPath(
                    ovalIn: CGRect(
                        x: circleCenter.x - circle.radius,
                        y: circleCenter.y - circle.radius,
                        width: circle.radius * 2,
                        height: circle.radius * 2
                    )
                )
            )
        }

        let transform = CGAffineTransform(translationX: center.x, y: center.y)
            .rotated(by: angle)
            .translatedBy(x: -center.x, y: -center.y)
        path.apply(transform)
        return path
    }
}

// MARK: - ViewController
class ViewController: UIViewController {
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
        let symbolName: String
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
    private var randomGenerationToggle: UISwitch?
    private var randomGenerationSectionViews: [UIView] = []
    private var randomDirectionButtons: [UIButton] = []
    private var loopPointStepper: UIStepper?
    private var loopPointLabel: UILabel?
    private var timeToggle: UISwitch?
    private var routeVibeControl: UISegmentedControl?
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
    private var isRandomGenerationEnabled = false
    private var useTimeInput = false
    private var selectedDirection = "random"
    private var selectedLoopPoints = 3
    private var isVoiceGuidanceEnabled = true
    private var isHapticsEnabled = true
    
    // MARK: - Route History
    private var savedRoutes: [SavedRoute] = []
    private var filteredRoutes: [SavedRoute] = []

    // MARK: - Location
    private var locationManager: CLLocationManager!
    private var userLocation: CLLocationCoordinate2D?
    
    // MARK: - Go To search completer
    // MARK: - Route Tracking
    private var currentRouteCoordinates: [CLLocationCoordinate2D] = []
    private var totalRouteDistance: CLLocationDistance = 0
    private var traveledDistance: CLLocationDistance = 0
    private var routeSegments: [CLLocationCoordinate2D] = []
    private var cumulativeSegmentLengths: [CLLocationDistance] = []
    private var currentRouteType: RouteConfig.RouteType = .oneWay
    private var currentRouteDisplayName = "Manual Mode On"
    private var usesRouteModeDisplayName = true
    private var lastRouteTypeSelection = 0
    private var pendingRouteSave: PendingRouteSave?
    private var speechSynthesizer = AVSpeechSynthesizer()
    private let walkPaceSoundID: SystemSoundID = 1110
    private let jogPaceSoundID: SystemSoundID = 1111
    private let runPaceSoundID: SystemSoundID = 1112
    private let tutorialSeenDefaultsKey = "hasSeenStepOutTutorial"
    private var navigationCues: [NavigationCue] = []
    private var nextNavigationCueIndex = 0
    private var displayNavigationCueIndex = 0
    private var routeLiveActivity: Activity<MapAppRouteActivityAttributes>?
    private var lastLiveActivityUpdateDate: Date?
    private var lastLoggedPaceType: PaceType?
    private var hasAttemptedDebugLiveActivityStart = false
    private let liveActivityStaleInterval: TimeInterval = 20
    private var latestUserHeading: CLLocationDirection?
    private var followCameraDistance: CLLocationDistance = 3000
    private var isUpdatingFollowCamera = false
    private var hasPlayedRouteSplash = false
    private var hasEvaluatedFirstLaunchTutorial = false
    private var tutorialOverlayView: SpotlightTutorialView?
    private var tutorialSteps: [TutorialStep] = []
    private var tutorialStepIndex = 0
    private var hasShownRouteEditingHint = false
    private var routeSplashView: RouteSplashView?
    private let walkPaceFeedback = UIImpactFeedbackGenerator(style: .heavy)
    private let jogPaceFeedback = UIImpactFeedbackGenerator(style: .rigid)
    private let runPaceFeedback = UIImpactFeedbackGenerator(style: .heavy)

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
        installRouteSplashIfNeeded()
        setStartupInterfaceHidden(true)
        speechSynthesizer.delegate = self
        configureSpokenGuidanceAudioSession()
        preparePaceHaptics()
        loadThemePreference()
        loadVoiceGuidancePreference()
        loadHapticsPreference()
        setupMap()
        setupLocation()
        setupUI()
        loadSavedSpeeds()
        setupRouteHistorySheet()
        setupPacePanel()
        CoreDataManager.shared.migrateExistingRoutes()
        lastRouteTypeSelection = routeTypeSelector.selectedSegmentIndex
        routeNameLabel?.text = currentRouteDisplayName
        if let routeSplashView {
            view.bringSubviewToFront(routeSplashView)
        }
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playRouteSplashIfNeeded()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle else { return }
        applyTheme()
    }

}

// MARK: - Setup Methods
extension ViewController {
    private func startTutorialIfNeeded() {
        guard !hasEvaluatedFirstLaunchTutorial else { return }
        hasEvaluatedFirstLaunchTutorial = true

        guard !UserDefaults.standard.bool(forKey: tutorialSeenDefaultsKey) else { return }
        startTutorial(forceReplay: false)
    }

    private func startTutorial(forceReplay: Bool) {
        if !forceReplay {
            UserDefaults.standard.set(true, forKey: tutorialSeenDefaultsKey)
        }

        tutorialSteps = buildTutorialSteps()
        tutorialStepIndex = 0

        if tutorialOverlayView == nil {
            let overlay = SpotlightTutorialView(frame: view.bounds)
            overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            overlay.onNext = { [weak self] in self?.advanceTutorial() }
            overlay.onBack = { [weak self] in self?.retreatTutorial() }
            overlay.onSkip = { [weak self] in self?.finishTutorial() }
            tutorialOverlayView = overlay
        }

        prepareTutorialInterface(routeSettingsOpen: false, paceOpen: false, historyExpanded: false)

        if let tutorialOverlayView, tutorialOverlayView.superview == nil {
            view.addSubview(tutorialOverlayView)
        }

        if let routeSplashView {
            view.bringSubviewToFront(routeSplashView)
        }
        if let tutorialOverlayView {
            view.bringSubviewToFront(tutorialOverlayView)
        }

        showTutorialStep()
    }

    private func advanceTutorial() {
        if tutorialStepIndex >= tutorialSteps.count - 1 {
            finishTutorial()
            return
        }

        tutorialStepIndex += 1
        showTutorialStep()
    }

    private func retreatTutorial() {
        guard tutorialStepIndex > 0 else { return }
        tutorialStepIndex -= 1
        showTutorialStep()
    }

    private func finishTutorial() {
        tutorialOverlayView?.removeFromSuperview()
        prepareTutorialInterface(routeSettingsOpen: false, paceOpen: false, historyExpanded: false)
    }

    private func showTutorialStep() {
        guard tutorialSteps.indices.contains(tutorialStepIndex),
              tutorialOverlayView != nil else { return }

        let step = tutorialSteps[tutorialStepIndex]
        step.prepare(self)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            guard let self,
                  let tutorialOverlayView = self.tutorialOverlayView,
                  self.tutorialSteps.indices.contains(self.tutorialStepIndex) else { return }

            let activeStep = self.tutorialSteps[self.tutorialStepIndex]
            let rect = activeStep.highlightRect(self) ?? CGRect(x: self.view.bounds.midX - 70, y: self.view.bounds.midY - 35, width: 140, height: 70)
            tutorialOverlayView.render(
                .init(
                    title: activeStep.title,
                    message: activeStep.message,
                    stepText: "Step \(self.tutorialStepIndex + 1) of \(self.tutorialSteps.count)",
                    highlightRect: rect,
                    showsBack: self.tutorialStepIndex > 0,
                    isLastStep: self.tutorialStepIndex == self.tutorialSteps.count - 1
                )
            )
            self.view.bringSubviewToFront(tutorialOverlayView)
        }
    }

    private func buildTutorialSteps() -> [TutorialStep] {
        [
            TutorialStep(
                title: "Settings",
                message: "Use Settings to change themes, turn voice or vibrations on and off, review pace stats, reset learned speeds, and replay this tutorial later.",
                prepare: { controller in
                    controller.prepareTutorialInterface(routeSettingsOpen: false, paceOpen: false, historyExpanded: false)
                },
                highlightRect: { controller in
                    controller.highlightRect(for: controller.settingsButton)
                }
            ),
            TutorialStep(
                title: "Go To Search",
                message: "Go To is the quick search tool for finding a place or address and dropping a point there before you build a route.",
                prepare: { controller in
                    controller.prepareTutorialInterface(routeSettingsOpen: false, paceOpen: false, historyExpanded: false)
                },
                highlightRect: { controller in
                    controller.highlightRect(for: controller.goToButton)
                }
            ),
            TutorialStep(
                title: "Route Settings",
                message: "This button opens route settings. That panel lets you turn random route generation on or off and adjust how the next route is built.",
                prepare: { controller in
                    controller.prepareTutorialInterface(routeSettingsOpen: false, paceOpen: false, historyExpanded: false)
                },
                highlightRect: { controller in
                    controller.highlightRect(for: controller.routeSettingsButton)
                }
            ),
            TutorialStep(
                title: "Random And Direction Options",
                message: "Inside route settings, use the Random Route Generation switch to choose manual versus random building. The compass-style direction buttons bias the route toward a general heading when random generation is on.",
                prepare: { controller in
                    controller.prepareTutorialInterface(routeSettingsOpen: true, paceOpen: false, historyExpanded: false)
                },
                highlightRect: { controller in
                    controller.highlightRect(for: controller.slidePanel)
                }
            ),
            TutorialStep(
                title: "Route Style",
                message: "Use the route style controls to choose how the path is built. Fastest behaves like a normal direct route, while Scenic tries to take a longer or more interesting path between the same points.",
                prepare: { controller in
                    controller.prepareTutorialInterface(routeSettingsOpen: true, paceOpen: false, historyExpanded: false)
                },
                highlightRect: { controller in
                    controller.highlightRect(for: controller.routeVibeControl)
                }
            ),
            TutorialStep(
                title: "Pace Panel",
                message: "This button opens the pace panel. It is where you decide how the route should be divided between walking, jogging, and running.",
                prepare: { controller in
                    controller.prepareTutorialInterface(routeSettingsOpen: false, paceOpen: false, historyExpanded: false)
                },
                highlightRect: { controller in
                    controller.highlightRect(for: controller.pacePatternButton)
                }
            ),
            TutorialStep(
                title: "How Pace Pattern Works",
                message: "The sliders set how much of the full route belongs to each pace type. For example, a route could be mostly walking with a smaller jogging or running section mixed in.",
                prepare: { controller in
                    controller.prepareTutorialInterface(routeSettingsOpen: false, paceOpen: true, historyExpanded: false)
                },
                highlightRect: { controller in
                    controller.highlightRect(for: controller.pacePanel)
                }
            ),
            TutorialStep(
                title: "Order And Pulse",
                message: "Drag the pace cards to alter the order the route uses them. Pulse mode repeats the pace pattern in cycles instead of applying each pace in one long block.",
                prepare: { controller in
                    controller.prepareTutorialInterface(routeSettingsOpen: false, paceOpen: true, historyExpanded: false)
                },
                highlightRect: { controller in
                    controller.highlightRect(for: controller.pacePanel)
                }
            ),
            TutorialStep(
                title: "Center And Follow",
                message: "The center button recenters on you. If it is on before you place a route, your exact current location becomes the starting point.",
                prepare: { controller in
                    controller.prepareTutorialInterface(routeSettingsOpen: false, paceOpen: false, historyExpanded: false)
                },
                highlightRect: { controller in
                    controller.highlightRect(for: controller.recenterButton)
                }
            ),
            TutorialStep(
                title: "Route History",
                message: "Swipe this bottom tab up to open route history. From there you can reload routes, search, filter, and review what you have saved.",
                prepare: { controller in
                    controller.prepareTutorialInterface(routeSettingsOpen: false, paceOpen: false, historyExpanded: false)
                },
                highlightRect: { controller in
                    controller.highlightRect(for: controller.routeHistorySheet)
                }
            ),
            TutorialStep(
                title: "Saved Route Actions",
                message: "When the history sheet is open, tap the ellipsis button on a saved route to reveal edit and delete actions.",
                prepare: { controller in
                    controller.prepareTutorialInterface(routeSettingsOpen: false, paceOpen: false, historyExpanded: true)
                },
                highlightRect: { controller in
                    controller.firstRouteHistoryActionRect() ?? controller.highlightRect(for: controller.routeHistorySheet)
                }
            )
        ]
    }

    private func prepareTutorialInterface(routeSettingsOpen: Bool, paceOpen: Bool, historyExpanded: Bool) {
        if routeSettingsOpen {
            if !isPanelOpen { openPanel() }
        } else if isPanelOpen {
            closePanel()
        }

        if paceOpen {
            if !isPacePanelOpen { openPacePanel() }
        } else if isPacePanelOpen {
            closePacePanel()
        }

        if historyExpanded {
            expandRouteSheet()
        } else {
            collapseRouteSheet()
        }
    }

    private func highlightRect(for view: UIView?, inset: CGFloat = -10) -> CGRect? {
        guard let view else { return nil }
        let rect = view.convert(view.bounds, to: self.view)
        return rect.insetBy(dx: inset, dy: inset)
    }

    private func firstRouteHistoryActionRect() -> CGRect? {
        guard !filteredRoutes.isEmpty else { return nil }
        let indexPath = IndexPath(row: 0, section: 0)
        routesTableView.layoutIfNeeded()
        guard let cell = routesTableView.cellForRow(at: indexPath) as? RouteTableViewCell else { return nil }
        let rect = cell.moreButton.convert(cell.moreButton.bounds, to: view)
        return rect.insetBy(dx: -10, dy: -10)
    }

    private func presentSettingsScreen() {
        let settingsViewController = SettingsViewController()
        settingsViewController.selectedThemeIndex = UIColor.activeThemeIndex
        settingsViewController.isVoiceGuidanceEnabled = isVoiceGuidanceEnabled
        settingsViewController.isHapticsEnabled = isHapticsEnabled
        settingsViewController.speedStats = [
            .init(title: "Walk", metersPerSecond: avgWalkingSpeed, sampleCount: walkSampleCount),
            .init(title: "Jog", metersPerSecond: avgJoggingSpeed, sampleCount: jogSampleCount),
            .init(title: "Run", metersPerSecond: avgRunningSpeed, sampleCount: runSampleCount)
        ]

        settingsViewController.onThemeSelected = { [weak self] selectedIndex in
            self?.saveThemePreference(index: selectedIndex)
            self?.applyTheme(themeIndex: selectedIndex)
        }
        settingsViewController.onVoiceGuidanceChanged = { [weak self] isEnabled in
            self?.isVoiceGuidanceEnabled = isEnabled
            UserDefaults.standard.set(isEnabled, forKey: "isVoiceGuidanceEnabled")
        }
        settingsViewController.onHapticsChanged = { [weak self] isEnabled in
            self?.isHapticsEnabled = isEnabled
            UserDefaults.standard.set(isEnabled, forKey: "isHapticsEnabled")
        }
        settingsViewController.onResetSpeed = { [weak self, weak settingsViewController] index in
            self?.resetSpeedData(for: index)
            settingsViewController?.speedStats = [
                .init(title: "Walk", metersPerSecond: self?.avgWalkingSpeed ?? 1.4, sampleCount: self?.walkSampleCount ?? 0),
                .init(title: "Jog", metersPerSecond: self?.avgJoggingSpeed ?? 2.7, sampleCount: self?.jogSampleCount ?? 0),
                .init(title: "Run", metersPerSecond: self?.avgRunningSpeed ?? 4.0, sampleCount: self?.runSampleCount ?? 0)
            ]
            settingsViewController?.renderSections()
        }
        settingsViewController.onReplayTutorial = { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self?.startTutorial(forceReplay: true)
            }
        }

        let navigationController = UINavigationController(rootViewController: settingsViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }

    private func playRouteSplashIfNeeded() {
        guard !hasPlayedRouteSplash else { return }
        guard view.window != nil else { return }
        guard let routeSplashView else { return }

        hasPlayedRouteSplash = true
        view.bringSubviewToFront(routeSplashView)
        routeSplashView.playAnimation { [weak self] in
            self?.setStartupInterfaceHidden(false)
            self?.routeSplashView = nil
            self?.startTutorialIfNeeded()
        }
    }

    private func installRouteSplashIfNeeded() {
        guard routeSplashView == nil else { return }

        let splashView = RouteSplashView(frame: view.bounds)
        splashView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(splashView)
        routeSplashView = splashView
    }

    private func setStartupInterfaceHidden(_ isHidden: Bool) {
        let alpha: CGFloat = isHidden ? 0 : 1

        if isHidden {
            mapView.alpha = 0
            headerBox.alpha = 0
            bottomTabContainer.alpha = 0
            routeHistorySheet.alpha = 0
            filterButton.alpha = 0
            routesSearchBar.alpha = 0
            routesTableView.alpha = 0
            saveRoutePillButton?.alpha = 0
            return
        }

        UIView.animate(withDuration: 0.24, delay: 0.05, options: [.curveEaseOut]) {
            self.mapView.alpha = alpha
            self.headerBox.alpha = alpha
            self.bottomTabContainer.alpha = alpha
            self.routeHistorySheet.alpha = alpha
            self.filterButton.alpha = alpha
            self.routesSearchBar.alpha = alpha
            self.routesTableView.alpha = alpha
            self.saveRoutePillButton?.alpha = alpha
        }
    }

    private func setupMap() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        mapView.isZoomEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap))
        mapView.addGestureRecognizer(tapGesture)
    }

    private func setupLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        locationManager.headingFilter = 5
        locationManager.distanceFilter = 5.0
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    private func updateLocationManagerForRouteTracking() {
        guard locationManager != nil else { return }

        let shouldTrackInBackground = isActivelyWalkingRoute
        locationManager.pausesLocationUpdatesAutomatically = !shouldTrackInBackground
        locationManager.allowsBackgroundLocationUpdates = shouldTrackInBackground
        locationManager.distanceFilter = (shouldTrackInBackground && isFollowingUser) ? 2.0 : 5.0

        if isFollowingUser && isActivelyWalkingRoute, CLLocationManager.headingAvailable() {
            locationManager.startUpdatingHeading()
        } else {
            locationManager.stopUpdatingHeading()
        }
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

        UIColor.usesDarkThemeVariant = traitCollection.userInterfaceStyle == .dark

        view.backgroundColor = .darkColor
        headerBox.backgroundColor = .headerBG
        bottomTabContainer.backgroundColor = .bottomBG
        let isRouteSheetCollapsed = routeHistorySheet.frame.height <= (routeSheetCollapsedHeight + 1)
        routeHistorySheet.backgroundColor = isRouteSheetCollapsed ? .clear : .elevatedPanelSurface
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

        if button === recenterButton {
            applyRecenterButtonStyle(to: button)
        }
    }

    private func applyRecenterButtonStyle(to button: UIButton) {
        let backgroundColor: UIColor = isFollowingUser ? .compColor : .floatingButtonBackground
        let foregroundColor: UIColor = isFollowingUser ? .activeCenterButtonTint : .floatingButtonForeground
        button.backgroundColor = backgroundColor
        button.tintColor = foregroundColor

        if var configuration = button.configuration {
            configuration.baseBackgroundColor = backgroundColor
            configuration.baseForegroundColor = foregroundColor
            configuration.background.strokeColor = foregroundColor.withAlphaComponent(isFollowingUser ? 0.55 : 0.35)
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
        currentY = addRandomGenerationToggle(to: container, y: currentY, width: fieldWidth, padding: padding)
        currentY = addDistanceInput(to: container, y: currentY, width: fieldWidth, padding: padding)
        currentY = addTimeToggle(to: container, y: currentY, width: fieldWidth, padding: padding)
        currentY = addDirectionGrid(to: container, y: currentY, width: fieldWidth)
        currentY = addDivider(to: container, y: currentY, width: fieldWidth, padding: padding)

        currentY = addSectionHeader(to: container, text: "LOOP OPTIONS", y: currentY, width: fieldWidth, padding: padding)
        currentY = addLoopPointControls(to: container, y: currentY, width: fieldWidth, padding: padding)

        panelScrollView.contentSize = CGSize(width: slidePanel.frame.width, height: currentY + 20)
        updateRandomGenerationControlsState()
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
        routeVibeControl = control
        return y + 45
    }

    private func addDistanceInput(to container: UIView, y: CGFloat, width: CGFloat, padding: CGFloat) -> CGFloat {
        var currentY = y
        let label = UILabel(frame: CGRect(x: padding, y: currentY, width: width, height: 20))
        label.text = "Distance (miles)"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .panelBodyTextColor
        container.addSubview(label)
        randomGenerationSectionViews.append(label)
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
        randomGenerationSectionViews.append(field)
        distanceTextField = field
        return currentY + 45
    }

    private func addTimeToggle(to container: UIView, y: CGFloat, width: CGFloat, padding: CGFloat) -> CGFloat {
        let label = UILabel(frame: CGRect(x: padding, y: y, width: width - 50, height: 20))
        label.text = "Use Time Instead"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .panelBodyTextColor
        container.addSubview(label)
        randomGenerationSectionViews.append(label)
        let toggle = UISwitch(frame: CGRect(x: width + padding - 51, y: y - 4, width: 51, height: 31))
        toggle.isOn = useTimeInput
        toggle.addTarget(self, action: #selector(timeToggleChanged(_:)), for: .valueChanged)
        container.addSubview(toggle)
        randomGenerationSectionViews.append(toggle)
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
        randomGenerationSectionViews.append(label)
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
                    randomDirectionButtons.append(button)
                }
                container.addSubview(button)
                randomGenerationSectionViews.append(button)
            }
        }
        return currentY + 150
    }

    private func addRandomGenerationToggle(to container: UIView, y: CGFloat, width: CGFloat, padding: CGFloat) -> CGFloat {
        let label = UILabel(frame: CGRect(x: padding, y: y, width: width - 60, height: 20))
        label.text = "Random Mode"
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .panelBodyTextColor
        container.addSubview(label)

        let toggle = UISwitch(frame: CGRect(x: width + padding - 51, y: y - 4, width: 51, height: 31))
        toggle.isOn = isRandomGenerationEnabled
        toggle.addTarget(self, action: #selector(randomGenerationToggleChanged(_:)), for: .valueChanged)
        container.addSubview(toggle)
        randomGenerationToggle = toggle

        return y + 40
    }

    private func updateRandomGenerationControlsState() {
        let alpha: CGFloat = isRandomGenerationEnabled ? 1.0 : 0.35

        randomGenerationSectionViews.forEach { view in
            view.alpha = alpha
        }

        distanceTextField?.isEnabled = isRandomGenerationEnabled
        timeToggle?.isEnabled = isRandomGenerationEnabled

        for button in randomDirectionButtons {
            button.isEnabled = isRandomGenerationEnabled
            if !isRandomGenerationEnabled {
                button.backgroundColor = .panelNeutralButtonBackground
                button.setTitleColor(.panelBodyTextColor, for: .normal)
            }
        }
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

        let paceOrderHint = UILabel(frame: CGRect(x: padding, y: currentY, width: pacePanel.frame.width - (padding * 2), height: 16))
        paceOrderHint.text = "Drag to alter order"
        paceOrderHint.font = .systemFont(ofSize: 11, weight: .medium)
        paceOrderHint.textAlignment = .center
        paceOrderHint.textColor = .secondaryTextColor
        pacePanel.addSubview(paceOrderHint)
        currentY += 20
        
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
        
        currentY += 31
        
        // Shuffle order button
        let shuffleOrderButton = createPaceButton(
            symbolName: "shuffle",
            color: .compColor,
            y: currentY,
            action: #selector(shufflePaceOrder)
        )
        pacePanel.addSubview(shuffleOrderButton)
        
        currentY += 31
        
        let pulseButton = createPaceButton(
            title: "Pulse: Off",
            color: .systemTeal,
            y: currentY,
            action: #selector(showPulsePicker)
        )
        pulseButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
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
        button.frame = CGRect(x: 12, y: y, width: pacePanel.frame.width - 24, height: 27)
        if let title {
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        }
        if let symbolName {
            button.setImage(UIImage(systemName: symbolName), for: .normal)
            button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold), forImageIn: .normal)
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
    @IBAction func showCoordinateEntry(_ sender: Any) {
        if let button = sender as? UIButton {
            animateActionButtonTap(button)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            self.goToButtonTapped()
        }
    }
    
    

    @IBAction func settingsBTN(_ sender: UIButton) {
        animateActionButtonTap(sender)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            self.presentSettingsScreen()
        }
    }

    @IBAction func generateRouteBTN(_ sender: UIButton) {
        animateActionButtonTap(sender, scale: 0.92, overshoot: 1.04)
        let config = buildRouteConfig()
        setRouteDisplayName(nil)
        if let targetMiles = config.targetDistance {
            generateRandomRoute(config: config, targetMiles: targetMiles)
        } else {
            generateManualRoute(config: config)
        }
    }
    @IBAction func clearRouteBTN(_ sender: UIButton) {
        animateActionButtonTap(sender, scale: 0.9, overshoot: 1.02)
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

    @IBAction func recenterBTN(_ sender: UIButton) {
        animateActionButtonTap(sender)
        toggleFollowUser(button: sender)
    }

    @IBAction func routeSettingsBTNTapped(_ sender: UIButton) {
        animateSettingsCog(sender)
        isPanelOpen ? closePanel() : openPanel()}
        
    @IBAction func paceSettingsButtonTapped(_ sender: UIButton) {
        animatePaceHare(sender)
        isPacePanelOpen ? closePacePanel() : openPacePanel()
        }
    }

// MARK: - Route Building
extension ViewController {
    private func buildRouteConfig() -> RouteConfig {
        let type = RouteConfig.RouteType(rawValue: routeTypeSelector.selectedSegmentIndex) ?? .oneWay
        let targetDistance = isRandomGenerationEnabled ? getUserInputMiles() : nil
        let direction = isRandomGenerationEnabled ? selectedDirection : "random"
        return RouteConfig(type: type, isScenic: useScenicRouting, waypoints: selectedCoordinates, targetDistance: targetDistance, direction: direction)
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
            let radius = initialEndpointRadius(targetMiles: targetMiles, routeType: config.type)
            let endpoint = generateRandomCoordinate(around: center, radius: radius, direction: config.direction ?? "random")
            return [center, endpoint]
        case .loop:
            let targetMeters = targetMiles * 1609.34
            let averageRadius = targetMeters / (Double(selectedLoopPoints) * 1.8)
            return generateLoopPoints(count: selectedLoopPoints, center: center, averageRadius: averageRadius, direction: config.direction ?? "random")
        }
    }

    private func calculateRadius(targetMiles: Double, windingFactor: Double) -> Double { (targetMiles * 1609.34) / (2 * .pi * windingFactor) }

    private func initialEndpointRadius(targetMiles: Double, routeType: RouteConfig.RouteType) -> CLLocationDistance {
        let targetMeters = targetMiles * 1609.34
        let legTargetMeters = routeType == .outAndBack ? targetMeters / 2.0 : targetMeters
        return max(150, legTargetMeters * 0.7)
    }
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
            if retryCount < 6 {
                let ratio: Double?
                if self.useTimeInput, let targetSeconds = self.getUserInputMinutes().map({ $0 * 60.0 }), targetSeconds > 0 {
                    let actualDistance = isOutAndBack ? selectedRoute.distance * 2 : selectedRoute.distance
                    let actualSeconds = self.estimatedRouteMinutes(totalDistance: actualDistance) * 60.0
                    ratio = actualSeconds / targetSeconds
                } else if let targetMiles = targetMiles {
                    let actualDistance = isOutAndBack ? selectedRoute.distance * 2 : selectedRoute.distance
                    let targetMeters = targetMiles * 1609.34
                    ratio = targetMeters > 0 ? (actualDistance / targetMeters) : nil
                } else {
                    ratio = nil
                }

                let tolerance = self.useTimeInput ? 0.12 : 0.20
                if let ratio, ratio.isFinite, ratio > 0, abs(ratio - 1.0) > tolerance {
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
                        announcementLeadDistance: 20,
                        symbolName: "arrow.uturn.backward"
                    )
                )
            }
            self.finishRouteGeneration(coordinates: allCoords, totalDistance: totalDistance, totalTime: totalTime, config: config, navigationCues: cues)
        }
    }

    private func syncSingleLegEndpointAnnotation(with coordinates: [CLLocationCoordinate2D], isOutAndBack: Bool) {
        guard let actualEndpoint = coordinates.last, selectedCoordinates.count > 1 else { return }
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
                if retryCount < 6 {
                    let ratio: Double?
                    if self.useTimeInput, let targetSeconds = self.getUserInputMinutes().map({ $0 * 60.0 }), targetSeconds > 0 {
                        let actualSeconds = self.estimatedRouteMinutes(totalDistance: totalDistance) * 60.0
                        ratio = actualSeconds / targetSeconds
                    } else if let targetMiles = targetMiles {
                        let actualMiles = totalDistance / 1609.34
                        ratio = actualMiles / targetMiles
                    } else {
                        ratio = nil
                    }
                    
                    let tolerance = self.useTimeInput ? 0.12 : 0.20
                    if let ratio, ratio.isFinite, ratio > 0, abs(ratio - 1.0) > tolerance {
                        print("Loop retry \(retryCount + 1): ratio \(String(format: "%.2f", ratio))")
                        
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
        updateLocationManagerForRouteTracking()
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

        showRouteEditingHintIfNeeded()
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
        let longStretchThreshold: CLLocationDistance = 304.8
        let nearTurnLeadDistance: CLLocationDistance = 30.48
        var previousStepDistance: CLLocationDistance = 0
        
        for step in steps {
            let instruction = step.instructions.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !instruction.isEmpty else {
                accumulatedDistance += step.distance
                previousStepDistance = step.distance
                continue
            }

            let cueDistance = accumulatedDistance
            let symbolName = directionSymbolName(for: instruction)

            if previousStepDistance >= longStretchThreshold {
                cues.append(
                    NavigationCue(
                        triggerDistance: cueDistance,
                        instruction: instruction,
                        announcementLeadDistance: previousStepDistance / 2,
                        symbolName: symbolName
                    )
                )
                cues.append(
                    NavigationCue(
                        triggerDistance: cueDistance,
                        instruction: instruction,
                        announcementLeadDistance: nearTurnLeadDistance,
                        symbolName: symbolName
                    )
                )
                accumulatedDistance += step.distance
                previousStepDistance = step.distance
                continue
            }

            let leadDistance: CLLocationDistance
            switch previousStepDistance {
            case 120...:
                leadDistance = 120
            default:
                leadDistance = cueDistance <= distanceOffset ? 0 : 45
            }
            cues.append(
                NavigationCue(
                    triggerDistance: cueDistance,
                    instruction: instruction,
                    announcementLeadDistance: leadDistance,
                    symbolName: symbolName
                )
            )
            accumulatedDistance += step.distance
            previousStepDistance = step.distance
        }
        
        return cues
    }
    
    private func beginNavigationCues(_ cues: [NavigationCue]) {
        navigationCues = cues.sorted {
            if $0.triggerDistance == $1.triggerDistance {
                return $0.announcementLeadDistance > $1.announcementLeadDistance
            }
            return $0.triggerDistance < $1.triggerDistance
        }
        nextNavigationCueIndex = 0
        displayNavigationCueIndex = 0
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

    private func directionSymbolName(for instruction: String) -> String {
        let lowered = instruction.lowercased()
        if lowered.contains("turn around") || lowered.contains("u-turn") {
            return "arrow.uturn.backward"
        }
        if lowered.contains("slight left") {
            return "arrow.up.left"
        }
        if lowered.contains("slight right") {
            return "arrow.up.right"
        }
        if lowered.contains("sharp left") {
            return "arrowshape.turn.up.left"
        }
        if lowered.contains("sharp right") {
            return "arrowshape.turn.up.right"
        }
        if lowered.contains("left") {
            return "arrowshape.turn.up.left"
        }
        if lowered.contains("right") {
            return "arrowshape.turn.up.right"
        }
        if lowered.contains("straight") || lowered.contains("continue") || lowered.contains("head") {
            return "arrow.up"
        }
        return "location.fill"
    }

    private func updateRouteInfoLabel(distance: CLLocationDistance, time: TimeInterval) {
        let miles = distance / 1609.34
        let minutes = estimatedRouteMinutes(totalDistance: distance)
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
        guard displayNavigationCueIndex < navigationCues.count else { return "" }
        return navigationCues[displayNavigationCueIndex].instruction
    }
    
    private func nextNavigationInstructionDistanceFeet() -> Int {
        guard displayNavigationCueIndex < navigationCues.count else { return 0 }
        let remainingDistance = max(0, navigationCues[displayNavigationCueIndex].triggerDistance - traveledDistance)
        return Int((remainingDistance * 3.28084).rounded())
    }

    private func nextNavigationInstructionSymbolName() -> String {
        guard displayNavigationCueIndex < navigationCues.count else { return "" }
        return navigationCues[displayNavigationCueIndex].symbolName
    }
    
    private func currentPaceTypeForRouteState() -> PaceType {
        if let livePace = paceType(at: traveledDistance) {
            return livePace
        }
        return paceOrder.first?.paceType ?? .walk
    }
    
    private func liveActivityContentState() -> MapAppRouteActivityAttributes.ContentState {
        MapAppRouteActivityAttributes.ContentState(
            routeName: currentRouteNameForWidget(),
            remainingMiles: max(0, totalRouteDistance - traveledDistance) / 1609.34,
            remainingMinutes: Int(estimatedRouteMinutes(totalDistance: totalRouteDistance, traveledDistance: traveledDistance).rounded()),
            nextInstruction: nextNavigationInstructionText(),
            nextInstructionDistanceFeet: nextNavigationInstructionDistanceFeet(),
            nextInstructionSymbolName: nextNavigationInstructionSymbolName(),
            currentPaceType: currentPaceTypeForRouteState().rawValue
        )
    }

    private func currentLiveActivityContent() -> ActivityContent<MapAppRouteActivityAttributes.ContentState> {
        ActivityContent(
            state: liveActivityContentState(),
            staleDate: Date().addingTimeInterval(liveActivityStaleInterval),
            relevanceScore: 100
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
        let content = currentLiveActivityContent()
        
        Task {
            do {
                await LiveActivityManager.endAllRouteActivities()
                routeLiveActivity = try Activity.request(attributes: attributes, content: content, pushType: nil)
                lastLiveActivityUpdateDate = Date()
                LiveActivityManager.markRouteActivityStarted()
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
                nextInstructionSymbolName: "arrow.up",
                currentPaceType: PaceType.walk.rawValue
            ),
            staleDate: Date().addingTimeInterval(liveActivityStaleInterval),
            relevanceScore: 100
        )
        
        Task {
            do {
                await LiveActivityManager.endAllRouteActivities()
                routeLiveActivity = try Activity.request(attributes: attributes, content: content, pushType: nil)
                lastLiveActivityUpdateDate = Date()
                LiveActivityManager.markRouteActivityStarted()
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
            staleDate: now.addingTimeInterval(liveActivityStaleInterval),
            relevanceScore: 100
        )
        
        Task {
            await routeLiveActivity?.update(content)
        }
        lastLiveActivityUpdateDate = now
        LiveActivityManager.markRouteActivityHeartbeat()
    }
    
    private func endLiveActivity() {
        guard #available(iOS 16.1, *) else { return }
        
        Task {
            await LiveActivityManager.endAllRouteActivities()
            routeLiveActivity = nil
            lastLiveActivityUpdateDate = nil
            print("Live Activity ended")
        }
    }
    
    private func setRouteDisplayName(_ name: String?) {
        let trimmedName = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        usesRouteModeDisplayName = trimmedName?.isEmpty != false
        currentRouteDisplayName = (trimmedName?.isEmpty == false) ? trimmedName! : defaultRouteDisplayName()
        routeNameLabel?.text = currentRouteDisplayName
    }

    private func defaultRouteDisplayName() -> String {
        isRandomGenerationEnabled ? "Random Mode On" : "Manual Mode On"
    }

    private func refreshRouteDisplayNameIfNeeded() {
        guard usesRouteModeDisplayName else { return }
        currentRouteDisplayName = defaultRouteDisplayName()
        routeNameLabel?.text = currentRouteDisplayName
    }

    private func currentRouteNameForWidget() -> String {
        guard !usesRouteModeDisplayName else { return "Current Route" }
        let trimmedName = currentRouteDisplayName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedName.isEmpty ? "Current Route" : trimmedName
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
            advanceDisplayedNavigationCueIfNeeded()
        }
        updateWalkedOverlay()
        updateLiveRouteInfo()
    }
    
    private func speakNextNavigationCueIfNeeded() {
        guard nextNavigationCueIndex < navigationCues.count else { return }
        var cueToSpeak: NavigationCue?

        while nextNavigationCueIndex < navigationCues.count {
            let cue = navigationCues[nextNavigationCueIndex]
            guard traveledDistance + cue.announcementLeadDistance >= cue.triggerDistance else { break }
            cueToSpeak = cue
            nextNavigationCueIndex += 1
        }
        
        guard let cue = cueToSpeak else { return }
        
        let remainingDistance = max(0, cue.triggerDistance - traveledDistance)
        speakTurnInstruction(cue.instruction, remainingDistance: remainingDistance)
        scheduleLiveActivityUpdateIfNeeded(force: true)
    }

    private func advanceDisplayedNavigationCueIfNeeded() {
        guard displayNavigationCueIndex < navigationCues.count else { return }

        let currentTriggerDistance = navigationCues[displayNavigationCueIndex].triggerDistance
        let legCompletionThreshold: CLLocationDistance = 8
        guard traveledDistance >= currentTriggerDistance - legCompletionThreshold else { return }

        var nextIndex = displayNavigationCueIndex + 1
        while nextIndex < navigationCues.count &&
                abs(navigationCues[nextIndex].triggerDistance - currentTriggerDistance) < 1 {
            nextIndex += 1
        }

        guard nextIndex != displayNavigationCueIndex else { return }
        displayNavigationCueIndex = nextIndex
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

        let roundedFeet = max(50, Int((distance * 3.28084 / 50).rounded() * 50))
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        let spokenFeet = formatter.string(from: NSNumber(value: roundedFeet)) ?? "\(roundedFeet)"
        return "In \(spokenFeet) feet"
    }
    
    private func logPaceTransitionIfNeeded() {
        guard let currentPace = paceType(at: traveledDistance) else { return }
        guard currentPace != lastLoggedPaceType else { return }
        
        lastLoggedPaceType = currentPace
        playPaceTransitionHaptic(for: currentPace)
        playPaceTransitionSound(for: currentPace)
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
        guard isHapticsEnabled else { return }

        switch paceType {
        case .walk:
            walkPaceFeedback.impactOccurred(intensity: 1.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                self.walkPaceFeedback.impactOccurred(intensity: 1.0)
                self.walkPaceFeedback.prepare()
            }
        case .jog:
            jogPaceFeedback.impactOccurred(intensity: 1.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) {
                self.jogPaceFeedback.impactOccurred(intensity: 1.0)
                self.jogPaceFeedback.prepare()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
                self.jogPaceFeedback.impactOccurred(intensity: 1.0)
                self.jogPaceFeedback.prepare()
            }
        case .run:
            runPaceFeedback.impactOccurred(intensity: 1.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                self.runPaceFeedback.impactOccurred(intensity: 1.0)
                self.runPaceFeedback.prepare()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
                self.runPaceFeedback.impactOccurred(intensity: 1.0)
                self.runPaceFeedback.prepare()
            }
        }
        preparePaceHaptics()
    }

    private func playPaceTransitionSound(for paceType: PaceType) {
        let soundID: SystemSoundID
        switch paceType {
        case .walk:
            soundID = walkPaceSoundID
        case .jog:
            soundID = jogPaceSoundID
        case .run:
            soundID = runPaceSoundID
        }

        activateSpokenGuidanceAudioSession()
        AudioServicesPlaySystemSoundWithCompletion(soundID) { [weak self] in
            self?.deactivateSpokenGuidanceAudioSessionIfIdle()
        }
    }
    
    private func speakGuidance(_ message: String, interruptCurrent: Bool) {
        guard !message.isEmpty else { return }
        guard isVoiceGuidanceEnabled else { return }
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
        
        let overlayStartDistance: CLLocationDistance
        if currentRouteType == .outAndBack && traveledDistance >= (totalRouteDistance / 2) {
            overlayStartDistance = totalRouteDistance / 2
        } else {
            overlayStartDistance = 0
        }

        let walkedCoords = routeSliceCoordinates(
            from: overlayStartDistance,
            to: traveledDistance
        )
        guard walkedCoords.count > 1 else { return }
        
        let walkedLine = StyledPolyline(coordinates: walkedCoords, count: walkedCoords.count)
        walkedLine.kind = .walked

        DispatchQueue.main.async {
            self.mapView.addOverlay(walkedLine)
        }
    }

    private func routeSliceCoordinates(from startDistance: CLLocationDistance, to endDistance: CLLocationDistance) -> [CLLocationCoordinate2D] {
        guard currentRouteCoordinates.count > 1 else { return [] }

        let clampedStart = max(0, min(startDistance, totalRouteDistance))
        let clampedEnd = max(clampedStart, min(endDistance, totalRouteDistance))
        guard clampedEnd > clampedStart else { return [] }

        var slice: [CLLocationCoordinate2D] = []
        let startCoordinate = coordinateAlongCurrentRoute(at: clampedStart)
        let endCoordinate = coordinateAlongCurrentRoute(at: clampedEnd)
        slice.append(startCoordinate)

        for (index, distance) in cumulativeSegmentLengths.enumerated() where distance > clampedStart && distance < clampedEnd {
            slice.append(currentRouteCoordinates[index])
        }

        if slice.last?.latitude != endCoordinate.latitude || slice.last?.longitude != endCoordinate.longitude {
            slice.append(endCoordinate)
        }

        return slice
    }

    private func coordinateAlongCurrentRoute(at distance: CLLocationDistance) -> CLLocationCoordinate2D {
        guard let first = currentRouteCoordinates.first else {
            return kCLLocationCoordinate2DInvalid
        }
        guard currentRouteCoordinates.count > 1 else { return first }

        let clampedDistance = max(0, min(distance, totalRouteDistance))
        if clampedDistance <= 0 {
            return first
        }
        if clampedDistance >= totalRouteDistance {
            return currentRouteCoordinates.last ?? first
        }

        for index in 1..<currentRouteCoordinates.count {
            let segmentEndDistance = cumulativeSegmentLengths[index]
            guard segmentEndDistance >= clampedDistance else { continue }

            let segmentStartDistance = cumulativeSegmentLengths[index - 1]
            let segmentLength = segmentEndDistance - segmentStartDistance
            guard segmentLength > 0 else { return currentRouteCoordinates[index] }

            let progress = (clampedDistance - segmentStartDistance) / segmentLength
            return interpolatedCoordinate(
                from: currentRouteCoordinates[index - 1],
                to: currentRouteCoordinates[index],
                progress: progress
            )
        }

        return currentRouteCoordinates.last ?? first
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
        if isPanelOpen { closePanel() }
        if isPacePanelOpen { closePacePanel() }
        selectedCoordinates.removeAll()
        isGeneratingRoute = false
        isActivelyWalkingRoute = false
        updateLocationManagerForRouteTracking()
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
        annotation.subtitle = "Press and drag to adjust this route pin"
        annotation.index = index
        mapView.addAnnotation(annotation)
    }

    private func safelyCenterMap(on coordinate: CLLocationCoordinate2D, distance: CLLocationDistance = 10000) {
        let camera = MKMapCamera(lookingAtCenter: coordinate, fromDistance: max(100, distance), pitch: 0, heading: 0)
        mapView.setCamera(camera, animated: true)
    }

    private func coordinate(from origin: CLLocationCoordinate2D, distanceMeters: CLLocationDistance, heading: CLLocationDirection) -> CLLocationCoordinate2D {
        let earthRadius = 6_378_137.0
        let angularDistance = distanceMeters / earthRadius
        let headingRadians = heading * .pi / 180
        let originLatitude = origin.latitude * .pi / 180
        let originLongitude = origin.longitude * .pi / 180

        let destinationLatitude = asin(
            sin(originLatitude) * cos(angularDistance) +
            cos(originLatitude) * sin(angularDistance) * cos(headingRadians)
        )

        let destinationLongitude = originLongitude + atan2(
            sin(headingRadians) * sin(angularDistance) * cos(originLatitude),
            cos(angularDistance) - sin(originLatitude) * sin(destinationLatitude)
        )

        return CLLocationCoordinate2D(
            latitude: destinationLatitude * 180 / .pi,
            longitude: destinationLongitude * 180 / .pi
        )
    }

    private func effectiveHeading(for location: CLLocation) -> CLLocationDirection? {
        if location.course >= 0, location.speed > 0.5 {
            return location.course
        }

        if let latestUserHeading {
            return latestUserHeading
        }

        return nil
    }

    private func updateMapInteractionModeForFollowState() {
        mapView.isScrollEnabled = !isFollowingUser
        mapView.isZoomEnabled = true
        mapView.isRotateEnabled = !isFollowingUser
        mapView.isPitchEnabled = !isFollowingUser
    }

    private func updateFollowCamera(with location: CLLocation, animated: Bool) {
        guard isFollowingUser else { return }

        let distance = max(300, followCameraDistance)
        guard isActivelyWalkingRoute, let heading = effectiveHeading(for: location) else {
            safelyCenterMap(on: location.coordinate, distance: distance)
            return
        }

        let camera = MKMapCamera(
            lookingAtCenter: location.coordinate,
            fromDistance: distance,
            pitch: 0,
            heading: heading
        )

        isUpdatingFollowCamera = true
        UIView.animate(
            withDuration: animated ? 0.55 : 0.0,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseOut, .allowUserInteraction]
        ) {
            self.mapView.camera = camera
        } completion: { _ in
            self.isUpdatingFollowCamera = false
        }
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
        updateMapInteractionModeForFollowState()
        updateLocationManagerForRouteTracking()
        if isFollowingUser {
            button.setImage(UIImage(systemName: "location.fill"), for: .normal)
            followCameraDistance = max(300, mapView.camera.centerCoordinateDistance)
            if let userLocation {
                let location = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
                updateFollowCamera(with: location, animated: true)
            }
        } else {
            button.setImage(UIImage(systemName: "location"), for: .normal)
        }
        applyRecenterButtonStyle(to: button)
    }

    private func animateSettingsCog(_ button: UIButton, clockwise: Bool = true) {
        let rotation = clockwise ? CGFloat.pi : -CGFloat.pi
        UIView.animate(withDuration: 0.3) {
            button.transform = CGAffineTransform(rotationAngle: rotation)
        } completion: { _ in
            button.transform = .identity
        }
    }

    private func animateActionButtonTap(_ button: UIButton, scale: CGFloat = 0.94, overshoot: CGFloat = 1.0) {
        button.layer.removeAnimation(forKey: "actionButtonPress")
        button.transform = .identity
        button.alpha = 1

        UIView.animate(
            withDuration: 0.08,
            delay: 0,
            options: [.beginFromCurrentState, .allowUserInteraction, .curveEaseOut]
        ) {
            button.transform = CGAffineTransform(scaleX: scale, y: scale)
            button.alpha = 0.9
        } completion: { _ in
            UIView.animate(
                withDuration: 0.28,
                delay: 0,
                usingSpringWithDamping: 0.72,
                initialSpringVelocity: 0.55,
                options: [.beginFromCurrentState, .allowUserInteraction]
            ) {
                button.transform = CGAffineTransform(scaleX: overshoot, y: overshoot)
                button.alpha = 1
            } completion: { _ in
                UIView.animate(
                    withDuration: 0.12,
                    delay: 0,
                    options: [.beginFromCurrentState, .allowUserInteraction, .curveEaseOut]
                ) {
                    button.transform = .identity
                }
            }
        }
    }

    private func animatePaceHare(_ button: UIButton) {
        guard let imageView = button.imageView else { return }

        imageView.layer.removeAllAnimations()
        imageView.transform = .identity

        UIView.animateKeyframes(
            withDuration: 0.42,
            delay: 0,
            options: [.calculationModeCubic, .allowUserInteraction]
        ) {
            UIView.addKeyframe(withRelativeStartTime: 0.00, relativeDuration: 0.22) {
                imageView.transform = CGAffineTransform(translationX: 5, y: -2)
                    .scaledBy(x: 1.16, y: 0.88)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.22, relativeDuration: 0.24) {
                imageView.transform = CGAffineTransform(translationX: -2, y: 2)
                    .scaledBy(x: 0.92, y: 1.08)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.46, relativeDuration: 0.24) {
                imageView.transform = CGAffineTransform(translationX: 6, y: -1)
                    .scaledBy(x: 1.10, y: 0.94)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.70, relativeDuration: 0.30) {
                imageView.transform = .identity
            }
        } completion: { _ in
            imageView.transform = .identity
        }
    }

    private func openPanel() { UIView.animate(withDuration: 0.3) { self.slidePanel.frame.origin.x = self.view.bounds.width - 184 }; isPanelOpen = true }
    private func closePanel() { UIView.animate(withDuration: 0.3) { self.slidePanel.frame.origin.x = self.view.bounds.width }; isPanelOpen = false }
}

// MARK: - Input Helpers
extension ViewController {
    private func getUserInputMinutes() -> Double? {
        guard useTimeInput,
              let text = distanceTextField?.text,
              !text.isEmpty,
              let value = Double(text) else { return nil }
        return value
    }

    private func getUserInputMiles() -> Double? {
        guard let text = distanceTextField?.text, !text.isEmpty, let value = Double(text) else { return nil }
        if useTimeInput {
            return targetDistanceMeters(forTargetMinutes: value) / 1609.34
        }
        return value
    }

    private func targetDistanceMeters(forTargetMinutes minutes: Double) -> CLLocationDistance {
        let targetSeconds = minutes * 60.0
        let activePaces = paceOrder.filter { $0.percentage >= 0.01 }
        guard !activePaces.isEmpty else {
            return targetSeconds * learnedSpeed(for: .walk)
        }

        let totalPercentage = activePaces.reduce(0.0) { $0 + $1.percentage }
        guard totalPercentage > 0 else {
            return targetSeconds * learnedSpeed(for: .walk)
        }

        let secondsPerMeter = activePaces.reduce(0.0) { partial, pace in
            let normalizedPercentage = pace.percentage / totalPercentage
            return partial + (normalizedPercentage / learnedSpeed(for: pace.paceType))
        }

        guard secondsPerMeter > 0 else {
            return targetSeconds * learnedSpeed(for: .walk)
        }

        return targetSeconds / secondsPerMeter
    }
    
    
}


// MARK: - @objc Handlers     TEMPORARY NEED TO ADD SECTION FOR EACH AREA
extension ViewController {
    @objc private func handleMapTap(_ gesture: UITapGestureRecognizer) {
        let coordinate = mapView.convert(gesture.location(in: mapView), toCoordinateFrom: mapView)
        let routeType = RouteConfig.RouteType(rawValue: routeTypeSelector.selectedSegmentIndex) ?? .oneWay
        if isFollowingUser && selectedCoordinates.isEmpty, let userLoc = userLocation { selectedCoordinates.append(userLoc); addAnnotation(at: userLoc, title: "Start", index: 0) }
        if routeType != .loop && selectedCoordinates.count >= 2 {
            showInfoAlert(
                title: "Adjust Existing Route",
                message: "This route already has its pins placed. Press and hold a pin, then drag it to change the route, or tap Clear to start over."
            )
            return
        }
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

    @objc private func randomGenerationToggleChanged(_ sender: UISwitch) {
        isRandomGenerationEnabled = sender.isOn

        guard !sender.isOn else {
            refreshRouteDisplayNameIfNeeded()
            updateRandomGenerationControlsState()
            return
        }

        distanceTextField?.text = ""
        selectedDirectionButton?.backgroundColor = .panelNeutralButtonBackground
        selectedDirectionButton?.setTitleColor(.panelBodyTextColor, for: .normal)
        selectedDirectionButton = nil
        selectedDirection = "random"
        useTimeInput = false
        distanceOrTimeLabel?.text = "Distance (miles)"
        distanceTextField?.placeholder = "e.g. 3.1"
        timeToggle?.setOn(false, animated: true)

        refreshRouteDisplayNameIfNeeded()
        updateRandomGenerationControlsState()
    }

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
        updateRandomGenerationControlsState()
    }

    @objc private func dismissKeyboard() { view.endEditing(true); closePanel() }
    
    @objc private func goToButtonTapped() {
        let searchController = PlaceSearchViewController()
        searchController.onSelection = { [weak self] mapItem, region in
            self?.displayGoToResult(mapItem, preferredRegion: region)
        }

        let navigationController = UINavigationController(rootViewController: searchController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
    @objc private func saveRoutePillTapped() {
        guard pendingRouteSave != nil else { return }
        presentSaveRouteDialog()
    }
    private func displayGoToResult(_ mapItem: MKMapItem, preferredRegion: MKCoordinateRegion?) {
        let coordinate = mapItem.placemark.coordinate
        let name = mapItem.name ?? "Unknown Location"
        let address = mapItem.placemark.title ?? ""

        print("Found: \(name) at \(address)")

        let existingAnnotations = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(existingAnnotations)

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = name
        annotation.subtitle = address
        mapView.addAnnotation(annotation)

        let suggestedDistance: CLLocationDistance
        if let preferredRegion {
            let latMeters = preferredRegion.span.latitudeDelta * 111_000
            let lonMeters = preferredRegion.span.longitudeDelta * 111_000 * cos(coordinate.latitude * .pi / 180)
            suggestedDistance = max(600, min(max(latMeters, lonMeters) * 1.2, 12_000))
        } else {
            suggestedDistance = 1_800
        }

        safelyCenterMap(on: coordinate, distance: suggestedDistance)

        mapView.selectAnnotation(annotation, animated: true)
    }

    private func presentSaveRouteDialog() {
        guard let pendingRouteSave else { return }
        
        let alert = UIAlertController(title: "Save Route", message: "Give this route a name.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Route name"
            textField.text = self.usesRouteModeDisplayName ? "" : self.currentRouteNameForWidget()
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
        
        //  UPDATE: Calculate distances if we have an active route
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
        chip.layer.cornerRadius = 10
        chip.layer.borderWidth = 2
        chip.layer.borderColor = pace.color.cgColor
        chip.layer.shadowColor = UIColor.black.cgColor
        chip.layer.shadowOpacity = 0.16
        chip.layer.shadowOffset = CGSize(width: 0, height: 3)
        chip.layer.shadowRadius = 6
        
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

        let dragHandle = UIImageView()
        dragHandle.image = UIImage(systemName: "line.3.horizontal")
        dragHandle.tintColor = pace.color.withAlphaComponent(0.9)
        dragHandle.contentMode = .scaleAspectFit
        dragHandle.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        dragHandle.translatesAutoresizingMaskIntoConstraints = false
        chip.addSubview(dragHandle)
        
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: chip.centerXAnchor),
            iconImageView.topAnchor.constraint(equalTo: chip.topAnchor, constant: 8),
            iconImageView.widthAnchor.constraint(equalToConstant: 26),
            iconImageView.heightAnchor.constraint(equalToConstant: 26),
            
            percentLabel.centerXAnchor.constraint(equalTo: chip.centerXAnchor),
            percentLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 2),

            dragHandle.centerXAnchor.constraint(equalTo: chip.centerXAnchor),
            dragHandle.topAnchor.constraint(equalTo: percentLabel.bottomAnchor, constant: 2),
            dragHandle.widthAnchor.constraint(equalToConstant: 18),
            dragHandle.heightAnchor.constraint(equalToConstant: 10)
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
            
            print("New pace order: \(paceOrder.map { $0.paceType.rawValue }.joined(separator: " → "))")
            
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
        
        print("Randomized: Walk \(Int((walk / total) * 100))%, Jog \(Int((jog / total) * 100))%, Run \(Int((run / total) * 100))%")
    }
    
    @objc private func shufflePaceOrder() {
        paceOrder.shuffle()
        updatePaceChips()
        redrawCurrentPacedRouteIfNeeded()
        print("Shuffled order: \(paceOrder.map { $0.paceType.rawValue }.joined(separator: " → "))")
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

    private func loadVoiceGuidancePreference() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "isVoiceGuidanceEnabled") == nil {
            isVoiceGuidanceEnabled = true
        } else {
            isVoiceGuidanceEnabled = defaults.bool(forKey: "isVoiceGuidanceEnabled")
        }
    }

    private func loadHapticsPreference() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "isHapticsEnabled") == nil {
            isHapticsEnabled = true
        } else {
            isHapticsEnabled = defaults.bool(forKey: "isHapticsEnabled")
        }
    }

    private func loadThemePreference() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "selectedThemeIndex") == nil {
            UIColor.activeThemeIndex = AppTheme.sunriseRoute.index
        } else {
            UIColor.activeThemeIndex = defaults.integer(forKey: "selectedThemeIndex")
        }
    }

    private func saveThemePreference(index: Int) {
        UserDefaults.standard.set(index, forKey: "selectedThemeIndex")
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

    private func resetSpeedData(for paceIndex: Int) {
        switch paceIndex {
        case 0:
            avgWalkingSpeed = 1.4
            walkSampleCount = 50
        case 1:
            avgJoggingSpeed = 2.7
            jogSampleCount = 50
        case 2:
            avgRunningSpeed = 4.0
            runSampleCount = 50
        default:
            return
        }

        saveSpeeds()
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

    private func showRouteEditingHintIfNeeded(force: Bool = false) {
        guard selectedCoordinates.count > 1 else { return }
        guard force || !hasShownRouteEditingHint else { return }

        hasShownRouteEditingHint = true
        showInfoAlert(
            title: "Adjust Route",
            message: "Press and hold any route pin, then drag it to reshape the route without starting over."
        )
    }
}

// MARK: - MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        guard isFollowingUser, !isUpdatingFollowCamera else { return }
        followCameraDistance = max(300, mapView.camera.centerCoordinateDistance)
    }

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

        if let markerView = view, annotation is RouteAnnotation {
            markerView.markerTintColor = .appPrimary
            markerView.glyphImage = UIImage(systemName: "hand.draw.fill")

            let hintLabel = UILabel()
            hintLabel.text = "Hold and drag to reshape"
            hintLabel.font = .systemFont(ofSize: 12, weight: .medium)
            hintLabel.textColor = .secondaryLabel
            hintLabel.numberOfLines = 1
            hintLabel.sizeToFit()
            markerView.detailCalloutAccessoryView = hintLabel
        }

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
        else if isFollowingUser { updateFollowCamera(with: location, animated: true) }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            updateLocationManagerForRouteTracking()
            locationManager.startUpdatingLocation()
        case .denied, .restricted: showInfoAlert(message: "Location access denied - using default location")
        default: break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let heading = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
        guard heading >= 0 else { return }
        latestUserHeading = heading

        guard isFollowingUser, isActivelyWalkingRoute, let userLocation else { return }
        let location = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        updateFollowCamera(with: location, animated: false)
    }

    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        false
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
        setRouteDisplayName(route.name)
        
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
        print("Route \(status)")
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
            
            //otherwise let it pan (touching pill, search bar, or bg)
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
 Walked route breaks color stuff. See if only drawing over user has walked is possible on top layer onstead of redrawing evertime a new segment is done. DONE
 Breaks means that the pacing colors get overidden by the walked on route colors where it is blue where not walked and green at the moment for walked. Probably change it to an opaic grey/black. DONE
 
 
More stuff I'd like to do: :
    I added color themes for later use, but I would also like to make darkmode versions for all of the themes I got. 4/2/2026 done (partial)
 
    whenver clear is hit also clear out the route info label up top. 4/2/2026 Done
 
    Make it to when the app is completely closed out it stops widget use.
        MAYBE FIXED HAVE TO TEST 4/6/2026 last attempt didn't work trying new fix. 4/7/2026 Working way better now so DONE
    
    Make go to into more of a google search thing not lat and long for locations. 4/6/2026 DONE
 
    Make it to where settings actually does settings things:       4/7/2026 Mostly done just need to set up email and test.
        1. allow user to pick color theme
        2. allow user to turn off and on talking and vibrations
        3. allow user to reset there average speeds for each pace (allow to reset individually) and this would also be the place that they can see there average speeds for each pace.
        4. F.A.Q. thing or maybe a way to contact me if issue occurs (maybe)
    
    Make a tutorial that happens on first launch of the app that goes around and does the "Spotlight" walkthrough i'll call it where it only lets you click certain things while having what needs to be clicked brightly with a text box that shows up expalining what stuff does. 4/14/2026 done
    
    when the user is on a route have it to where if center on user button on whatever direction the user is walking is north (that way left and rights don't get confusing)
            4/6/2026 DONE
    
    Add animaitons to just about everthing to make it feel more professional. 4/14/2026 done
 
    add a loading screen on launch. 4/6/2026 Paritally implemented needs refinement. 4/14/2026 Final version done.
 
    fix out and back route type random and just in general. 4/7/2026 NEED TO TEST TO MAKE SURE
 
 
 reflection, including user feedback   4/14/2026 started
 
 Come up with list of tasks for users to try  record feedback. 4/14/2026 done
 
 poster
 
 whenever I get to done testing with people do a github repo push with beta version.
 
 
 Way in the future additions:
 
 add apple watch compatability
 
 look for api's to make "fake email"
 */
