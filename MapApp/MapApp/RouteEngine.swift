//
//  RouteEngine.swift
//  MapApp
//
//  Pure-logic engine extracted from the original ViewController.
//  Contains shared types, pace math, speed learning, and random route geometry.
//  No UIKit view dependencies — safe to consume from either UIKit or SwiftUI.
//

import Foundation
import CoreLocation
import MapKit

// MARK: - Models

enum PaceType: String {
    case walk = "Walk"
    case jog = "Jog"
    case run = "Run"
}

struct RouteConfig {
    enum RouteType: Int { case oneWay = 0, outAndBack = 1, loop = 2 }
    var type: RouteType
    var isScenic: Bool
    var waypoints: [CLLocationCoordinate2D]
    var targetDistance: Double?   // miles
    var direction: String?
}

struct PaceSegmentConfig {
    let paceType: PaceType
    var percentage: Double
    var distance: Double

    var symbolName: String {
        switch paceType {
        case .walk: return "tortoise.fill"
        case .jog:  return "figure.run"
        case .run:  return "hare.fill"
        }
    }
}

// MARK: - Map Models

class RouteAnnotation: MKPointAnnotation {
    var index: Int = 0
}

class StyledPolyline: MKPolyline {
    enum Kind { case forward, backward, walked, remaining }
    enum Mode { case fastest, scenic }
    var kind: Kind = .forward
    var legIndex: Int = 0
    var mode: Mode = .fastest
    var paceType: PaceType? = nil
}

// MARK: - Speed Learning

/// Per-pace rolling-average speed store backed by UserDefaults.
/// Returns calibrated defaults until at least 10 samples for a pace exist.
final class SpeedLearningStore {
    private enum Keys {
        static let avgWalk = "avgWalkingSpeed"
        static let avgJog  = "avgJoggingSpeed"
        static let avgRun  = "avgRunningSpeed"
        static let cntWalk = "walkSampleCount"
        static let cntJog  = "jogSampleCount"
        static let cntRun  = "runSampleCount"
    }

    private(set) var avgWalk: Double = 1.4
    private(set) var avgJog:  Double = 2.7
    private(set) var avgRun:  Double = 4.0
    private(set) var walkSampleCount = 0
    private(set) var jogSampleCount  = 0
    private(set) var runSampleCount  = 0

    init() { load() }

    func learnedSpeed(for paceType: PaceType) -> Double {
        switch paceType {
        case .walk: return walkSampleCount >= 10 ? avgWalk : 1.4
        case .jog:  return jogSampleCount  >= 10 ? avgJog  : 2.7
        case .run:  return runSampleCount  >= 10 ? avgRun  : 4.0
        }
    }

    /// Add a new GPS-derived sample. Pass an explicit paceType when known
    /// (active route segment); otherwise the speed is classified by threshold.
    func recordSample(speed: Double, paceType: PaceType?) {
        guard speed > 0 else { return }

        let classified: PaceType
        if let paceType {
            classified = paceType
        } else {
            switch speed {
            case ..<2.0:     classified = .walk
            case 2.0..<3.5:  classified = .jog
            default:         classified = .run
            }
        }

        switch classified {
        case .walk:
            avgWalk = ((avgWalk * Double(walkSampleCount)) + speed) / Double(walkSampleCount + 1)
            walkSampleCount += 1
        case .jog:
            avgJog = ((avgJog * Double(jogSampleCount)) + speed) / Double(jogSampleCount + 1)
            jogSampleCount += 1
        case .run:
            avgRun = ((avgRun * Double(runSampleCount)) + speed) / Double(runSampleCount + 1)
            runSampleCount += 1
        }

        let total = walkSampleCount + jogSampleCount + runSampleCount
        if total % 10 == 0 { save() }
    }

    func resetAll() {
        avgWalk = 1.4; avgJog = 2.7; avgRun = 4.0
        walkSampleCount = 50; jogSampleCount = 50; runSampleCount = 50
        save()
    }

    func reset(_ paceType: PaceType) {
        switch paceType {
        case .walk: avgWalk = 1.4; walkSampleCount = 50
        case .jog:  avgJog  = 2.7; jogSampleCount  = 50
        case .run:  avgRun  = 4.0; runSampleCount  = 50
        }
        save()
    }

    private func save() {
        let d = UserDefaults.standard
        d.set(avgWalk, forKey: Keys.avgWalk)
        d.set(avgJog,  forKey: Keys.avgJog)
        d.set(avgRun,  forKey: Keys.avgRun)
        d.set(walkSampleCount, forKey: Keys.cntWalk)
        d.set(jogSampleCount,  forKey: Keys.cntJog)
        d.set(runSampleCount,  forKey: Keys.cntRun)
    }

    private func load() {
        let d = UserDefaults.standard
        if d.double(forKey: Keys.avgWalk) > 0 {
            avgWalk = d.double(forKey: Keys.avgWalk)
            walkSampleCount = d.integer(forKey: Keys.cntWalk)
        }
        if d.double(forKey: Keys.avgJog) > 0 {
            avgJog = d.double(forKey: Keys.avgJog)
            jogSampleCount = d.integer(forKey: Keys.cntJog)
        }
        if d.double(forKey: Keys.avgRun) > 0 {
            avgRun = d.double(forKey: Keys.avgRun)
            runSampleCount = d.integer(forKey: Keys.cntRun)
        }
    }
}

// MARK: - Pace Math

enum PaceMath {

    /// Expand a pace order into actual ordered segments, honoring pulse repetition.
    static func effectivePaceSegments(
        paceOrder: [PaceSegmentConfig],
        totalDistance: Double,
        pulseSegmentCount: Int
    ) -> [PaceSegmentConfig] {
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

        var chunkCounts = activePaceOrder.map {
            max(0, Int(floor($0.percentage * Double(pulseSegmentCount))))
        }
        let fractionalParts = activePaceOrder.enumerated().map {
            (index: $0.offset,
             fraction: ($0.element.percentage * Double(pulseSegmentCount)) - Double(chunkCounts[$0.offset]))
        }

        var assignedChunks = chunkCounts.reduce(0, +)
        let sortedFractions = fractionalParts.sorted { lhs, rhs in
            lhs.fraction == rhs.fraction ? lhs.index < rhs.index : lhs.fraction > rhs.fraction
        }

        var fractionIndex = 0
        while assignedChunks < pulseSegmentCount && !sortedFractions.isEmpty {
            let targetIndex = sortedFractions[fractionIndex % sortedFractions.count].index
            chunkCounts[targetIndex] += 1
            assignedChunks += 1
            fractionIndex += 1
        }

        while assignedChunks > pulseSegmentCount,
              let removableIndex = chunkCounts.firstIndex(where: { $0 > 0 }) {
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

    /// Pace type at a given distance along a route, or nil if no active pace order.
    static func paceType(
        at distance: CLLocationDistance,
        totalDistance: CLLocationDistance,
        segments: [PaceSegmentConfig]
    ) -> PaceType? {
        guard totalDistance > 0, !segments.isEmpty else { return nil }
        let clampedDistance = min(max(distance, 0), totalDistance)
        var segmentStart: CLLocationDistance = 0

        for (index, pace) in segments.enumerated() {
            let segmentLength = pace.percentage * totalDistance
            let segmentEnd = (index == segments.count - 1)
                ? totalDistance
                : min(totalDistance, segmentStart + segmentLength)
            if clampedDistance <= segmentEnd || index == segments.count - 1 {
                return pace.paceType
            }
            segmentStart = segmentEnd
        }
        return segments.last?.paceType
    }

    /// Estimated minutes remaining on a route using per-pace learned speeds.
    static func estimatedRouteMinutes(
        totalDistance: CLLocationDistance,
        traveledDistance: CLLocationDistance = 0,
        paceOrder: [PaceSegmentConfig],
        pulseSegmentCount: Int,
        speedStore: SpeedLearningStore
    ) -> Double {
        let remainingDistance = max(0, totalDistance - traveledDistance)
        guard remainingDistance > 0 else { return 0 }

        let segments = effectivePaceSegments(
            paceOrder: paceOrder,
            totalDistance: totalDistance,
            pulseSegmentCount: pulseSegmentCount
        )
        guard !segments.isEmpty else {
            return (remainingDistance / speedStore.learnedSpeed(for: .walk)) / 60.0
        }

        var remainingMinutes: Double = 0
        var segmentStart: CLLocationDistance = 0

        for (index, pace) in segments.enumerated() {
            let segmentLength = pace.percentage * totalDistance
            let segmentEnd = (index == segments.count - 1)
                ? totalDistance
                : min(totalDistance, segmentStart + segmentLength)
            let overlapStart = max(traveledDistance, segmentStart)
            let overlapEnd = min(totalDistance, segmentEnd)
            if overlapEnd > overlapStart {
                remainingMinutes += ((overlapEnd - overlapStart) / speedStore.learnedSpeed(for: pace.paceType)) / 60.0
            }
            segmentStart = segmentEnd
        }
        return remainingMinutes
    }

    /// Convert a time target (minutes) into a target distance (meters) using the pace mix
    /// and learned speeds. Falls back to learned walking speed if no pace mix is set.
    static func targetDistanceMeters(
        forTargetMinutes minutes: Double,
        paceOrder: [PaceSegmentConfig],
        speedStore: SpeedLearningStore
    ) -> CLLocationDistance {
        let targetSeconds = minutes * 60.0
        let activePaces = paceOrder.filter { $0.percentage >= 0.01 }
        guard !activePaces.isEmpty else {
            return targetSeconds * speedStore.learnedSpeed(for: .walk)
        }

        let totalPercentage = activePaces.reduce(0.0) { $0 + $1.percentage }
        guard totalPercentage > 0 else {
            return targetSeconds * speedStore.learnedSpeed(for: .walk)
        }

        let secondsPerMeter = activePaces.reduce(0.0) { partial, pace in
            let normalized = pace.percentage / totalPercentage
            return partial + (normalized / speedStore.learnedSpeed(for: pace.paceType))
        }

        guard secondsPerMeter > 0 else {
            return targetSeconds * speedStore.learnedSpeed(for: .walk)
        }
        return targetSeconds / secondsPerMeter
    }
}

// MARK: - Random Route Geometry

enum RouteGeometry {

    /// Random point around `center` within a radius, biased by a compass direction.
    /// Direction tokens: N, NE, E, SE, S, SW, W, NW, or "random".
    static func generateRandomCoordinate(
        around center: CLLocationCoordinate2D,
        radius: Double,
        direction: String
    ) -> CLLocationCoordinate2D {
        let range = angleRange(for: direction)
        let randomAngle: Double = (direction == "N")
            ? (Bool.random() ? Double.random(in: 337.5...360.0) : Double.random(in: 0.0...22.5))
            : Double.random(in: range)
        let radians = randomAngle * (.pi / 180)
        let randomDistance = Double.random(in: (0.7 * radius)...radius)
        let earthRadius = 6_371_000.0
        let latOffset = (randomDistance * cos(radians)) / earthRadius
        let centerLatRadians = center.latitude * (.pi / 180)
        let longOffset = (randomDistance * sin(radians)) / (earthRadius * cos(centerLatRadians))
        return CLLocationCoordinate2D(
            latitude: center.latitude + (latOffset * (180 / .pi)),
            longitude: center.longitude + (longOffset * (180 / .pi))
        )
    }

    /// Loop waypoints around a center; first point is the center itself.
    static func generateLoopPoints(
        count: Int,
        center: CLLocationCoordinate2D,
        averageRadius: Double,
        direction: String
    ) -> [CLLocationCoordinate2D] {
        var points = [center]
        for _ in 1..<count {
            let variation = Double.random(in: 0.7...1.3)
            points.append(
                generateRandomCoordinate(
                    around: center,
                    radius: averageRadius * variation,
                    direction: direction
                )
            )
        }
        return points
    }

    /// Initial radius guess for a random single-leg route given a target mileage.
    static func initialEndpointRadius(targetMiles: Double, routeType: RouteConfig.RouteType) -> CLLocationDistance {
        let targetMeters = targetMiles * 1609.34
        let legTargetMeters = (routeType == .outAndBack) ? targetMeters / 2.0 : targetMeters
        return max(150, legTargetMeters * 0.7)
    }

    private static func angleRange(for direction: String) -> ClosedRange<Double> {
        switch direction {
        case "N":  return 337.5...360.0
        case "NE": return 22.5...67.5
        case "E":  return 67.5...112.5
        case "SE": return 112.5...157.5
        case "S":  return 157.5...202.5
        case "SW": return 202.5...247.5
        case "W":  return 247.5...292.5
        case "NW": return 292.5...337.5
        default:   return 0.0...360.0
        }
    }
}
