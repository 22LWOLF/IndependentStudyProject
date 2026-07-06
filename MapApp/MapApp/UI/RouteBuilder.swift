//
//  RouteBuilder.swift
//  MapApp
//
//  Turns a route request into real MapKit walking directions.
//  Auto mode: random waypoints from RouteGeometry, retried until the total
//  distance lands near the target. Manual mode: routes through user pins.
//

import Foundation
import CoreLocation
import MapKit

enum RouteBuildError: LocalizedError {
    case needMorePins
    case noRouteFound

    var errorDescription: String? {
        switch self {
        case .needMorePins:
            return "Drop at least two pins on the map to build a manual route."
        case .noRouteFound:
            return "Couldn't find a walkable route here. Try again or adjust the target."
        }
    }
}

/// One pace-colored stretch of the final route.
struct PaceRun {
    var pace: PaceType?
    var coords: [CLLocationCoordinate2D]
}

/// A fully generated route ready to display and walk.
struct BuiltRoute {
    var coordinates: [CLLocationCoordinate2D]
    var waypoints: [CLLocationCoordinate2D]
    var totalMeters: CLLocationDistance
    var paceSegments: [PaceSegmentConfig]
    var coloredSegments: [PaceRun]
    var estimatedMinutes: Double

    var totalMiles: Double { totalMeters / 1609.34 }
}

enum RouteBuilder {

    struct Request {
        var start: CLLocationCoordinate2D
        var type: RouteConfig.RouteType
        var targetMeters: CLLocationDistance
        var direction: String            // compass token or "random"
        var loopPointCount: Int
        var manualPins: [CLLocationCoordinate2D]?
    }

    /// Accept routes within ±15% of the target distance.
    static let acceptableError = 0.15
    private static let maxAttempts = 4

    static func build(_ request: Request) async throws
        -> (coords: [CLLocationCoordinate2D], meters: CLLocationDistance, waypoints: [CLLocationCoordinate2D]) {

        if let pins = request.manualPins {
            return try await buildManual(pins: pins, type: request.type)
        }
        return try await buildRandom(request)
    }

    // MARK: - Manual (pin-to-pin)

    private static func buildManual(pins: [CLLocationCoordinate2D], type: RouteConfig.RouteType) async throws
        -> (coords: [CLLocationCoordinate2D], meters: CLLocationDistance, waypoints: [CLLocationCoordinate2D]) {

        guard pins.count >= 2 else { throw RouteBuildError.needMorePins }

        var stops = pins
        if type == .loop, let first = pins.first {
            stops.append(first)
        }

        var (coords, meters) = try await routeThrough(stops)
        if type == .outAndBack {
            coords += coords.reversed()
            meters *= 2
        }
        return (coords, meters, pins)
    }

    // MARK: - Random (target-seeking)

    private static func buildRandom(_ request: Request) async throws
        -> (coords: [CLLocationCoordinate2D], meters: CLLocationDistance, waypoints: [CLLocationCoordinate2D]) {

        var radius = initialRadius(for: request)
        var best: (coords: [CLLocationCoordinate2D], meters: CLLocationDistance, waypoints: [CLLocationCoordinate2D])?
        var bestError = Double.infinity

        for attempt in 0..<maxAttempts {
            let waypoints = candidateWaypoints(for: request, radius: radius)
            do {
                var stops = waypoints
                if request.type == .loop {
                    stops.append(request.start)
                }

                var (coords, meters) = try await routeThrough(stops)
                if request.type == .outAndBack {
                    coords += coords.reversed()
                    meters *= 2
                }

                let error = abs(meters - request.targetMeters) / request.targetMeters
                if error < bestError {
                    best = (coords, meters, waypoints)
                    bestError = error
                }
                if error <= acceptableError { break }

                // Rescale the search radius toward the target and roll again.
                let ratio = request.targetMeters / meters
                radius *= min(max(ratio, 0.4), 2.5)
            } catch {
                // A leg failed (water, unroutable area) — shrink and reroll.
                radius *= 0.85
            }

            if attempt < maxAttempts - 1 {
                // Be gentle with MKDirections throttling.
                try? await Task.sleep(nanoseconds: 250_000_000)
            }
        }

        guard let result = best else { throw RouteBuildError.noRouteFound }
        return result
    }

    private static func initialRadius(for request: Request) -> CLLocationDistance {
        switch request.type {
        case .oneWay, .outAndBack:
            return RouteGeometry.initialEndpointRadius(
                targetMiles: request.targetMeters / 1609.34,
                routeType: request.type
            )
        case .loop:
            // Perimeter of k points on a circle of radius r ≈ 2·k·r·sin(π/k);
            // pad because roads never run straight between points.
            let k = Double(max(3, request.loopPointCount))
            let polygonPerimeter = 2 * k * sin(.pi / k)
            return max(120, request.targetMeters / (polygonPerimeter * 1.25))
        }
    }

    private static func candidateWaypoints(for request: Request, radius: CLLocationDistance) -> [CLLocationCoordinate2D] {
        switch request.type {
        case .oneWay, .outAndBack:
            let end = RouteGeometry.generateRandomCoordinate(
                around: request.start, radius: radius, direction: request.direction
            )
            return [request.start, end]
        case .loop:
            return RouteGeometry.generateLoopPoints(
                count: max(3, request.loopPointCount),
                center: request.start,
                averageRadius: radius,
                direction: request.direction
            )
        }
    }

    // MARK: - Legs

    private static func routeThrough(_ stops: [CLLocationCoordinate2D]) async throws
        -> (coords: [CLLocationCoordinate2D], meters: CLLocationDistance) {

        var coords: [CLLocationCoordinate2D] = []
        var meters: CLLocationDistance = 0

        for i in 0..<(stops.count - 1) {
            let route = try await leg(from: stops[i], to: stops[i + 1])
            let legCoords = route.polyline.coordinateArray
            coords += coords.isEmpty ? legCoords : Array(legCoords.dropFirst())
            meters += route.distance
        }

        guard coords.count > 1 else { throw RouteBuildError.noRouteFound }
        return (coords, meters)
    }

    private static func leg(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) async throws -> MKRoute {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: from))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: to))
        request.transportType = .walking

        let response = try await MKDirections(request: request).calculate()
        guard let route = response.routes.first else { throw RouteBuildError.noRouteFound }
        return route
    }

    // MARK: - Pace coloring

    /// Split a route's coordinates into pace-colored runs, interpolating the
    /// exact boundary point where one pace hands off to the next.
    static func coloredSegments(
        coords: [CLLocationCoordinate2D],
        totalMeters: CLLocationDistance,
        segments: [PaceSegmentConfig]
    ) -> [PaceRun] {
        guard coords.count > 1 else { return [] }
        guard totalMeters > 0, !segments.isEmpty else {
            return [PaceRun(pace: nil, coords: coords)]
        }

        // Cumulative end-distance for each pace segment.
        var boundaries: [(pace: PaceType, end: CLLocationDistance)] = []
        var running: CLLocationDistance = 0
        for (index, segment) in segments.enumerated() {
            running = index == segments.count - 1
                ? totalMeters
                : min(totalMeters, running + segment.percentage * totalMeters)
            boundaries.append((segment.paceType, running))
        }

        var result: [PaceRun] = []
        var current: [CLLocationCoordinate2D] = [coords[0]]
        var boundaryIndex = 0
        var traveled: CLLocationDistance = 0

        for i in 1..<coords.count {
            var from = coords[i - 1]
            let to = coords[i]
            var edge = distance(from, to)

            while boundaryIndex < boundaries.count - 1, traveled + edge >= boundaries[boundaryIndex].end {
                let need = boundaries[boundaryIndex].end - traveled
                let t = edge > 0 ? need / edge : 0
                let cut = CLLocationCoordinate2D(
                    latitude: from.latitude + (to.latitude - from.latitude) * t,
                    longitude: from.longitude + (to.longitude - from.longitude) * t
                )
                current.append(cut)
                result.append(PaceRun(pace: boundaries[boundaryIndex].pace, coords: current))
                current = [cut]
                traveled += need
                edge -= need
                from = cut
                boundaryIndex += 1
            }

            current.append(to)
            traveled += edge
        }

        if current.count > 1 {
            result.append(PaceRun(
                pace: boundaries[min(boundaryIndex, boundaries.count - 1)].pace,
                coords: current
            ))
        }
        return result
    }

    // MARK: - Geometry helpers

    static func distance(_ a: CLLocationCoordinate2D, _ b: CLLocationCoordinate2D) -> CLLocationDistance {
        CLLocation(latitude: a.latitude, longitude: a.longitude)
            .distance(from: CLLocation(latitude: b.latitude, longitude: b.longitude))
    }

    static func pathLength(_ coords: [CLLocationCoordinate2D]) -> CLLocationDistance {
        guard coords.count > 1 else { return 0 }
        var total: CLLocationDistance = 0
        for i in 1..<coords.count {
            total += distance(coords[i - 1], coords[i])
        }
        return total
    }
}

extension MKPolyline {
    var coordinateArray: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](
            repeating: kCLLocationCoordinate2DInvalid,
            count: pointCount
        )
        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))
        return coords
    }
}
