//
//  AppModel.swift
//  MapApp
//
//  Shared app state: route configuration, the built route, live tracking,
//  tab selection, and location. Views read/write this; RouteBuilder,
//  RouteTracking and RouteEngine do the math.
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

/// Live progress along the built route.
struct RouteProgress: Equatable {
    var traveledMeters: CLLocationDistance
    var deviationMeters: CLLocationDistance
    var fraction: Double
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
    @Published var activeRouteName: String?

    // MARK: - Live session

    @Published var isLive = false
    @Published var routeCompleted = false
    @Published var progress: RouteProgress?
    @Published var currentPace: PaceType?
    @Published var nextCue: NavigationCue?
    @Published var liveStartDate: Date?

    /// Cue distances (rounded meters) already spoken this session.
    private var announcedCues: Set<Int> = []
    private var lastActivityPush = Date.distantPast

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
        #if DEBUG
        handleDebugAutomation()
        #endif
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

    /// Estimated minutes remaining, honoring live progress when available.
    func remainingMinutes(for route: BuiltRoute) -> Double {
        PaceMath.estimatedRouteMinutes(
            totalDistance: route.totalMeters,
            traveledDistance: progress?.traveledMeters ?? 0,
            paceOrder: paceMixConfigs,
            pulseSegmentCount: pulseCount,
            speedStore: speedStore
        )
    }

    func remainingMiles(for route: BuiltRoute) -> Double {
        max(0, route.totalMeters - (progress?.traveledMeters ?? 0)) / 1609.34
    }

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
        if isLive { endRoute() }
        buildError = nil
        routeSaved = false
        routeCompleted = false
        activeRouteName = nil

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
            let raw = try await RouteBuilder.build(request)
            builtRoute = makeBuiltRoute(from: raw)
        } catch {
            buildError = (error as? LocalizedError)?.errorDescription
                ?? "Route generation failed. Give it another shot."
        }
    }

    private func makeBuiltRoute(from raw: RouteBuilder.RawRoute) -> BuiltRoute {
        let cumulative = RouteTracking.cumulativeDistances(raw.coords)
        // Use the polyline's own length as the canonical total so live progress,
        // pace boundaries, and completion checks all agree.
        let meters = cumulative.last ?? raw.meters
        let returnStart = raw.returnStartMeters.map { $0 * (meters / max(raw.meters, 1)) }

        let segments = PaceMath.effectivePaceSegments(
            paceOrder: paceMixConfigs,
            totalDistance: meters,
            pulseSegmentCount: pulseCount
        )
        return BuiltRoute(
            coordinates: raw.coords,
            waypoints: raw.waypoints,
            totalMeters: meters,
            paceSegments: segments,
            coloredSegments: RouteBuilder.coloredSegments(
                coords: raw.coords,
                totalMeters: meters,
                segments: segments,
                extraBoundaries: returnStart.map { [$0] } ?? []
            ),
            estimatedMinutes: PaceMath.estimatedRouteMinutes(
                totalDistance: meters,
                paceOrder: paceMixConfigs,
                pulseSegmentCount: pulseCount,
                speedStore: speedStore
            ),
            cues: raw.cues,
            cumulativeMeters: cumulative,
            returnStartMeters: returnStart
        )
    }

    func clearRoute() {
        if isLive { endRoute() }
        builtRoute = nil
        buildError = nil
        routeSaved = false
        routeCompleted = false
        activeRouteName = nil
        progress = nil
        currentPace = nil
        nextCue = nil
        liveStartDate = nil
    }

    // MARK: - Live session

    func startRoute() {
        guard let route = builtRoute else { return }
        isLive = true
        routeCompleted = false
        progress = nil
        currentPace = nil
        nextCue = route.cues.first
        announcedCues = []
        liveStartDate = Date()
        lastActivityPush = .distantPast

        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.pausesLocationUpdatesAutomatically = false

        FeedbackManager.shared.sessionBegan()
        LiveActivityManager.startRouteActivity(
            initialState: activityState(route: route, traveled: 0)
        )
    }

    func endRoute(completed: Bool = false) {
        isLive = false
        routeCompleted = completed

        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.showsBackgroundLocationIndicator = false
        locationManager.pausesLocationUpdatesAutomatically = true

        FeedbackManager.shared.sessionEnded(completed: completed)
        LiveActivityManager.requestEndAllRouteActivities(using: UIApplication.shared)

        if !completed {
            progress = nil
            currentPace = nil
            nextCue = nil
            liveStartDate = nil
        }
    }

    private func handleLiveUpdate(_ location: CLLocation, route: BuiltRoute) {
        let snap = RouteTracking.snap(
            location.coordinate,
            route: route.coordinates,
            cumulative: route.cumulativeMeters,
            lastTraveled: progress?.traveledMeters ?? 0
        )
        progress = RouteProgress(
            traveledMeters: snap.traveledMeters,
            deviationMeters: snap.deviationMeters,
            fraction: route.totalMeters > 0 ? snap.traveledMeters / route.totalMeters : 0
        )

        // Pace transitions.
        let pace = PaceMath.paceType(
            at: snap.traveledMeters,
            totalDistance: route.totalMeters,
            segments: route.paceSegments
        )
        if let pace, pace != currentPace {
            if currentPace != nil {
                FeedbackManager.shared.paceChanged(to: pace)
            }
            currentPace = pace
        }

        // Learn real speeds while on route (and reasonably on the line).
        if location.speed > 0.3, snap.deviationMeters < 30 {
            speedStore.recordSample(speed: location.speed, paceType: currentPace)
        }

        // Turn-by-turn cues.
        updateCues(route: route, traveled: snap.traveledMeters, speed: max(location.speed, 1))

        // Live Activity: heartbeat always, content push throttled to 2s.
        LiveActivityManager.markRouteActivityHeartbeat()
        if Date().timeIntervalSince(lastActivityPush) >= 2 {
            lastActivityPush = Date()
            LiveActivityManager.updateRouteActivity(
                activityState(route: route, traveled: snap.traveledMeters)
            )
        }

        // Completion: at the end of the line and nearly all of it covered.
        if snap.traveledMeters >= route.totalMeters - 25, (progress?.fraction ?? 0) > 0.9 {
            endRoute(completed: true)
        }
    }

    private func updateCues(route: BuiltRoute, traveled: CLLocationDistance, speed: Double) {
        nextCue = route.cues.first { $0.meters >= traveled - 8 }

        guard let cue = nextCue else { return }
        let lead = max(25, speed * 12)   // announce ~12s ahead, minimum 25 m
        let key = Int(cue.meters)
        if cue.meters - traveled <= lead, !announcedCues.contains(key) {
            announcedCues.insert(key)
            FeedbackManager.shared.announceCue(cue.instruction, metersAway: max(0, cue.meters - traveled))
        }
    }

    private func activityState(route: BuiltRoute, traveled: CLLocationDistance) -> MapAppRouteActivityAttributes.ContentState {
        MapAppRouteActivityAttributes.ContentState(
            routeName: activeRouteName ?? "StepOut Route",
            remainingMiles: max(0, (route.totalMeters - traveled) / 1609.34),
            remainingMinutes: Int(remainingMinutes(for: route).rounded()),
            nextInstruction: nextCue?.instruction ?? "Follow the route",
            currentPaceType: (currentPace ?? paceOrder.first ?? .walk).rawValue
        )
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
        if isLive { endRoute() }
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
        routeCompleted = false

        if let data = saved.fullRouteData,
           let coords = CoreDataManager.shared.decodeCoordinates(data),
           coords.count > 1 {
            let waypoints = saved.waypointsData.flatMap { CoreDataManager.shared.decodeCoordinates($0) } ?? []
            let meters = RouteBuilder.pathLength(coords)
            // Saved out-and-backs mirror at the halfway point; cues aren't stored.
            let returnStart: CLLocationDistance? = routeType == .outAndBack ? meters / 2 : nil
            builtRoute = makeBuiltRoute(from: RouteBuilder.RawRoute(
                coords: coords,
                meters: meters,
                waypoints: waypoints,
                cues: returnStart.map {
                    [NavigationCue(meters: $0, instruction: "Turn around and head back the way you came")]
                } ?? [],
                returnStartMeters: returnStart
            ))
        } else {
            builtRoute = nil
        }
        routeSaved = true
        activeRouteName = saved.name?.isEmpty == false ? saved.name : "Route #\(saved.routeNumber)"
        selectedTab = .build
    }

    private func currentCoordinate() -> CLLocationCoordinate2D? {
        lastKnownLocation ?? locationManager.location?.coordinate
    }

    // MARK: - Debug automation (simulator verification only)

    #if DEBUG
    /// Launch with SIMCTL_CHILD_STEPOUT_AUTOBUILD=oneWay|outAndBack|loop to
    /// auto-build a route, and SIMCTL_CHILD_STEPOUT_AUTOSTART=1 to also start
    /// it on the Active tab. Dumps route coords to Documents/debug_route.json.
    private func handleDebugAutomation() {
        let env = ProcessInfo.processInfo.environment
        guard let token = env["STEPOUT_AUTOBUILD"] else { return }

        let type: RouteConfig.RouteType
        switch token {
        case "oneWay":     type = .oneWay
        case "outAndBack": type = .outAndBack
        default:           type = .loop
        }

        Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(for: .seconds(3))   // wait for a location fix
            self.routeType = type
            await self.build()

            if let route = self.builtRoute,
               let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let pairs = route.coordinates.map { [$0.latitude, $0.longitude] }
                if let data = try? JSONSerialization.data(withJSONObject: pairs) {
                    try? data.write(to: docs.appendingPathComponent("debug_route.json"))
                }
            }

            if env["STEPOUT_AUTOSTART"] == "1", self.builtRoute != nil {
                self.selectedTab = .active
                self.startRoute()
            }
        }
    }
    #endif
}

// MARK: - Location updates

extension AppModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        lastKnownLocation = latest.coordinate

        if isLive, let route = builtRoute {
            handleLiveUpdate(latest, route: route)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Ignore transient failures; the Build flow surfaces missing location.
    }
}
