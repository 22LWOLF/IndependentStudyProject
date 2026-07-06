//
//  AppModel.swift
//  MapApp
//
//  Shared app state: route configuration, the built route, tab selection,
//  and location. Views read/write this; RouteBuilder and RouteEngine do the math.
//

import SwiftUI
import Combine
import CoreLocation
import MapKit

enum AppTab: Hashable { case build, active, routes, you }
enum BuildMode { case auto, manual }
enum TargetKind: Int { case time, distance }

extension PaceType: CaseIterable {
    public static var allCases: [PaceType] { [.walk, .jog, .run] }
}

@MainActor
final class AppModel: NSObject, ObservableObject {

    // MARK: - Tabs

    @Published var selectedTab: AppTab = .build

    // MARK: - Route configuration

    @Published var routeType: RouteConfig.RouteType = .loop
    @Published var targetKind: TargetKind = .time
    @Published var targetMinutes: Double = 30
    @Published var targetMiles: Double = 1.5
    @Published var direction: String? = nil          // nil = any direction
    @Published var isScenic = false
    @Published var pulseCount = 1
    @Published var loopPointCount = 4

    /// Pace order along the route; shares always sum to 1.
    @Published var paceOrder: [PaceType] = [.walk, .jog, .run]
    @Published var paceShares: [PaceType: Double] = [.walk: 0.6, .jog: 0.4, .run: 0]

    // MARK: - Build mode & pins

    @Published var buildMode: BuildMode = .auto
    @Published var manualPins: [CLLocationCoordinate2D] = []

    // MARK: - Result

    @Published var builtRoute: BuiltRoute?
    @Published var isBuilding = false
    @Published var buildError: String?
    @Published var routeSaved = false

    // MARK: - Active session (skeleton — real GPS tracking lands next pass)

    @Published var isLive = false

    // MARK: - Services

    let speedStore = SpeedLearningStore()
    private let locationManager = CLLocationManager()
    @Published var lastKnownLocation: CLLocationCoordinate2D?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    // MARK: - Derived state

    var paceMixConfigs: [PaceSegmentConfig] {
        paceOrder.map {
            PaceSegmentConfig(paceType: $0, percentage: paceShares[$0] ?? 0, distance: 0)
        }
    }

    var targetMeters: CLLocationDistance {
        switch targetKind {
        case .distance:
            return targetMiles * 1609.34
        case .time:
            return PaceMath.targetDistanceMeters(
                forTargetMinutes: targetMinutes,
                paceOrder: paceMixConfigs,
                speedStore: speedStore
            )
        }
    }

    var expectedMiles: Double { targetMeters / 1609.34 }

    var paceMixSummary: String {
        let active = paceOrder.filter { (paceShares[$0] ?? 0) >= 0.01 }
        guard !active.isEmpty else { return "No pace set" }
        return active
            .map { "\(Int(((paceShares[$0] ?? 0) * 100).rounded()))% \($0.rawValue.lowercased())" }
            .joined(separator: " · ")
    }

    var directionSummary: String { direction.map { "Bias \($0)" } ?? "Any direction" }

    // MARK: - Target selection

    func selectMinutes(_ minutes: Double) {
        targetMinutes = minutes
        targetKind = .time
        buildMode = .auto
    }

    func selectMiles(_ miles: Double) {
        targetMiles = miles
        targetKind = .distance
        buildMode = .auto
    }

    // MARK: - Pace mix editing

    /// Set one pace's share and proportionally rebalance the others so the mix sums to 100%.
    func setShare(_ pace: PaceType, to newValue: Double) {
        let value = min(max(newValue, 0), 1)
        let others = PaceType.allCases.filter { $0 != pace }
        let oldOthers = others.reduce(0) { $0 + (paceShares[$1] ?? 0) }
        let newOthers = 1 - value

        var shares = paceShares
        shares[pace] = value
        if oldOthers > 0.0001 {
            for other in others {
                shares[other] = (paceShares[other] ?? 0) * newOthers / oldOthers
            }
        } else {
            for other in others {
                shares[other] = newOthers / Double(others.count)
            }
        }
        paceShares = shares
    }

    /// Move a pace one position earlier in the route order.
    func promotePace(_ pace: PaceType) {
        guard let index = paceOrder.firstIndex(of: pace), index > 0 else { return }
        paceOrder.swapAt(index, index - 1)
    }

    func randomizeShares() {
        let raw = PaceType.allCases.map { _ in Double.random(in: 0.05...1) }
        let total = raw.reduce(0, +)
        var shares: [PaceType: Double] = [:]
        for (index, pace) in PaceType.allCases.enumerated() {
            shares[pace] = raw[index] / total
        }
        paceShares = shares
    }

    func resetShares() {
        paceShares = [.walk: 0.6, .jog: 0.4, .run: 0]
        paceOrder = [.walk, .jog, .run]
    }

    // MARK: - Manual pins

    func addManualPin(_ coordinate: CLLocationCoordinate2D) {
        manualPins.append(coordinate)
        buildMode = .manual
    }

    func movePin(at index: Int, to coordinate: CLLocationCoordinate2D) {
        guard manualPins.indices.contains(index) else { return }
        manualPins[index] = coordinate
    }

    func clearPins() {
        manualPins.removeAll()
        buildMode = .auto
    }

    // MARK: - Build

    func build() async {
        buildError = nil
        routeSaved = false
        isLive = false

        if buildMode == .manual && manualPins.count < 2 {
            buildError = RouteBuildError.needMorePins.errorDescription
            return
        }
        guard let start = buildMode == .manual ? manualPins.first : currentCoordinate() else {
            buildError = "Still waiting for your location. Check that StepOut has location access."
            return
        }

        isBuilding = true
        defer { isBuilding = false }

        let request = RouteBuilder.Request(
            start: start,
            type: routeType,
            targetMeters: targetMeters,
            direction: direction ?? "random",
            loopPointCount: loopPointCount,
            manualPins: buildMode == .manual ? manualPins : nil
        )

        do {
            let result = try await RouteBuilder.build(request)
            builtRoute = makeBuiltRoute(
                coords: result.coords, meters: result.meters, waypoints: result.waypoints
            )
        } catch {
            buildError = (error as? LocalizedError)?.errorDescription
                ?? "Route generation failed. Give it another shot."
        }
    }

    private func makeBuiltRoute(
        coords: [CLLocationCoordinate2D],
        meters: CLLocationDistance,
        waypoints: [CLLocationCoordinate2D]
    ) -> BuiltRoute {
        let segments = PaceMath.effectivePaceSegments(
            paceOrder: paceMixConfigs,
            totalDistance: meters,
            pulseSegmentCount: pulseCount
        )
        return BuiltRoute(
            coordinates: coords,
            waypoints: waypoints,
            totalMeters: meters,
            paceSegments: segments,
            coloredSegments: RouteBuilder.coloredSegments(
                coords: coords, totalMeters: meters, segments: segments
            ),
            estimatedMinutes: PaceMath.estimatedRouteMinutes(
                totalDistance: meters,
                paceOrder: paceMixConfigs,
                pulseSegmentCount: pulseCount,
                speedStore: speedStore
            )
        )
    }

    func clearRoute() {
        builtRoute = nil
        buildError = nil
        routeSaved = false
        isLive = false
    }

    // MARK: - Persistence

    func saveCurrentRoute() {
        guard let route = builtRoute else { return }
        CoreDataManager.shared.saveRoute(
            routeType: routeType.rawValue,
            isScenicMode: isScenic,
            targetDistance: route.totalMiles,
            direction: direction,
            waypoints: route.waypoints,
            fullRoute: route.coordinates,
            paceConfig: paceMixConfigs,
            pulseSegmentCount: pulseCount
        )
        routeSaved = true
    }

    func load(_ saved: SavedRoute) {
        routeType = RouteConfig.RouteType(rawValue: Int(saved.routeType)) ?? .loop
        isScenic = saved.isScenicMode
        direction = saved.direction
        targetKind = .distance
        targetMiles = saved.targetDistance

        if let data = saved.paceOrderData,
           let decoded = CoreDataManager.shared.decodePaceConfig(data) {
            pulseCount = decoded.pulseSegmentCount
            var order: [PaceType] = []
            var shares: [PaceType: Double] = [.walk: 0, .jog: 0, .run: 0]
            for segment in decoded.segments where !order.contains(segment.paceType) {
                order.append(segment.paceType)
                shares[segment.paceType] = segment.percentage
            }
            for pace in PaceType.allCases where !order.contains(pace) {
                order.append(pace)
            }
            paceOrder = order
            paceShares = shares
        }

        buildMode = .auto
        manualPins.removeAll()

        if let data = saved.fullRouteData,
           let coords = CoreDataManager.shared.decodeCoordinates(data),
           coords.count > 1 {
            let waypoints = saved.waypointsData.flatMap { CoreDataManager.shared.decodeCoordinates($0) } ?? []
            builtRoute = makeBuiltRoute(
                coords: coords,
                meters: RouteBuilder.pathLength(coords),
                waypoints: waypoints
            )
        } else {
            builtRoute = nil
        }
        routeSaved = true
        selectedTab = .build
    }

    private func currentCoordinate() -> CLLocationCoordinate2D? {
        lastKnownLocation ?? locationManager.location?.coordinate
    }
}

// MARK: - Location updates

extension AppModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        lastKnownLocation = latest.coordinate
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Ignore transient failures; the Build flow surfaces missing location.
    }
}
