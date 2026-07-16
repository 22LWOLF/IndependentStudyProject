//
//  RouteTracking.swift
//  MapApp
//
//  Pure math for live tracking: projecting the user's GPS fix onto the route
//  polyline ("snap to route") and slicing the walked portion for the overlay.
//
//  Snapping prefers progress near the previous fix, which is what makes
//  out-and-back routes work: the same physical street maps to two different
//  route distances, and the window keeps us on the correct leg.
//

import Foundation
import CoreLocation
import MapKit

enum RouteTracking {

    struct Snap {
        var traveledMeters: CLLocationDistance
        var deviationMeters: CLLocationDistance
        var coordinate: CLLocationCoordinate2D
    }

    /// How far off the route (meters) a windowed match may be before we
    /// fall back to searching the whole polyline.
    private static let windowTrustLimit: CLLocationDistance = 50

    static func cumulativeDistances(_ coords: [CLLocationCoordinate2D]) -> [CLLocationDistance] {
        guard !coords.isEmpty else { return [] }
        var result: [CLLocationDistance] = [0]
        result.reserveCapacity(coords.count)
        for i in 1..<coords.count {
            result.append(result[i - 1] + RouteBuilder.distance(coords[i - 1], coords[i]))
        }
        return result
    }

    /// Project a location onto the route, preferring matches just ahead of
    /// `lastTraveled` so overlapping legs resolve to the correct one.
    static func snap(
        _ target: CLLocationCoordinate2D,
        route: [CLLocationCoordinate2D],
        cumulative: [CLLocationDistance],
        lastTraveled: CLLocationDistance
    ) -> Snap {
        guard route.count > 1, cumulative.count == route.count else {
            return Snap(traveledMeters: lastTraveled, deviationMeters: 0, coordinate: target)
        }

        let window = segmentWindow(cumulative: cumulative, around: lastTraveled)
        if let near = bestProjection(of: target, route: route, cumulative: cumulative, segments: window),
           near.deviationMeters <= windowTrustLimit {
            return near
        }
        return bestProjection(
            of: target, route: route, cumulative: cumulative,
            segments: 0..<(route.count - 1)
        ) ?? Snap(traveledMeters: lastTraveled, deviationMeters: 0, coordinate: target)
    }

    /// Route coordinates from the start up to `traveled` meters, with an
    /// interpolated endpoint — the walked portion for the map overlay.
    static func walkedPath(
        route: [CLLocationCoordinate2D],
        cumulative: [CLLocationDistance],
        traveled: CLLocationDistance
    ) -> [CLLocationCoordinate2D] {
        guard traveled > 0, route.count > 1, cumulative.count == route.count else { return [] }
        guard let total = cumulative.last, traveled < total else { return route }

        var index = 0
        while index + 1 < cumulative.count && cumulative[index + 1] <= traveled {
            index += 1
        }

        var path = Array(route[0...index])
        let segmentLength = cumulative[index + 1] - cumulative[index]
        if segmentLength > 0 {
            let t = (traveled - cumulative[index]) / segmentLength
            let a = route[index], b = route[index + 1]
            path.append(CLLocationCoordinate2D(
                latitude: a.latitude + (b.latitude - a.latitude) * t,
                longitude: a.longitude + (b.longitude - a.longitude) * t
            ))
        }
        return path
    }

    // MARK: - Internals

    private static func segmentWindow(
        cumulative: [CLLocationDistance],
        around traveled: CLLocationDistance
    ) -> Range<Int> {
        let lowTarget = traveled - 40
        let highTarget = traveled + 200

        var low = 0
        while low + 1 < cumulative.count && cumulative[low + 1] < lowTarget {
            low += 1
        }
        var high = low
        while high + 1 < cumulative.count && cumulative[high] < highTarget {
            high += 1
        }
        return low..<max(high, low + 1)
    }

    private static func bestProjection(
        of target: CLLocationCoordinate2D,
        route: [CLLocationCoordinate2D],
        cumulative: [CLLocationDistance],
        segments: Range<Int>
    ) -> Snap? {
        let point = MKMapPoint(target)
        var best: Snap?

        for i in segments where i + 1 < route.count {
            let a = MKMapPoint(route[i])
            let b = MKMapPoint(route[i + 1])
            let abx = b.x - a.x
            let aby = b.y - a.y
            let lengthSquared = abx * abx + aby * aby

            let t: Double
            if lengthSquared > 0 {
                t = min(max(((point.x - a.x) * abx + (point.y - a.y) * aby) / lengthSquared, 0), 1)
            } else {
                t = 0
            }

            let projected = MKMapPoint(x: a.x + abx * t, y: a.y + aby * t)
            let deviation = point.distance(to: projected)

            if deviation < (best?.deviationMeters ?? .infinity) {
                best = Snap(
                    traveledMeters: cumulative[i] + (cumulative[i + 1] - cumulative[i]) * t,
                    deviationMeters: deviation,
                    coordinate: projected.coordinate
                )
            }
        }
        return best
    }
}
