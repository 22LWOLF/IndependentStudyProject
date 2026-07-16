//
//  MapCanvasView.swift
//  MapApp
//
//  SwiftUI wrapper around MKMapView. Renders the built route as pace-colored
//  polylines (outbound legs wide and solid, out-and-back return legs thin and
//  dotted on top so both paces stay visible), dims the walked portion during a
//  live session, shows draggable manual pins, and (on the Build tab) lets a
//  tap drop a new pin.
//

import SwiftUI
import MapKit

struct MapCanvasView: UIViewRepresentable {
    @EnvironmentObject private var model: AppModel

    /// When true, tapping the map drops manual pins and pins can be dragged.
    var allowsPinEditing = false
    /// When true (live session), the camera follows the user.
    var followsUser = false

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.showsUserLocation = true
        map.showsCompass = false
        map.userTrackingMode = .follow

        if allowsPinEditing {
            let tap = UITapGestureRecognizer(
                target: context.coordinator,
                action: #selector(Coordinator.handleTap(_:))
            )
            map.addGestureRecognizer(tap)
        }
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        context.coordinator.model = model
        context.coordinator.allowsPinEditing = allowsPinEditing
        syncOverlays(on: map, coordinator: context.coordinator)
        syncWalkedOverlay(on: map, coordinator: context.coordinator)
        syncPins(on: map, coordinator: context.coordinator)
        syncFollowMode(on: map, coordinator: context.coordinator)
    }

    func makeCoordinator() -> Coordinator { Coordinator(model: model) }

    // MARK: - Syncing

    private func syncOverlays(on map: MKMapView, coordinator: Coordinator) {
        let signature = model.builtRoute.map {
            "\($0.coordinates.count)-\(Int($0.totalMeters))-\($0.paceSegments.count)"
        } ?? "none"
        guard signature != coordinator.overlaySignature else { return }
        coordinator.overlaySignature = signature
        coordinator.walkedBucket = -1

        map.removeOverlays(map.overlays)
        guard let route = model.builtRoute else { return }

        // Order matters: outbound (forward) runs first, then return (backward)
        // runs so the thin dotted line rides on top of the wide solid one.
        let runs = route.coloredSegments.sorted { isReturnRun($0, route: route) == false && isReturnRun($1, route: route) }
        for run in runs where run.coords.count > 1 {
            var coords = run.coords
            let line = StyledPolyline(coordinates: &coords, count: coords.count)
            line.paceType = run.pace
            line.kind = isReturnRun(run, route: route) ? .backward : .forward
            map.addOverlay(line)
        }

        var allCoords = route.coordinates
        let bounds = MKPolyline(coordinates: &allCoords, count: allCoords.count)
        map.setVisibleMapRect(
            bounds.boundingMapRect,
            edgePadding: UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40),
            animated: true
        )
    }

    private func isReturnRun(_ run: PaceRun, route: BuiltRoute) -> Bool {
        guard let returnStart = route.returnStartMeters else { return false }
        return run.startMeters >= returnStart - 0.5
    }

    /// Dim the portion already walked during a live (or just-completed) session.
    private func syncWalkedOverlay(on map: MKMapView, coordinator: Coordinator) {
        let active = model.isLive || model.routeCompleted
        let bucket = active ? Int((model.progress?.traveledMeters ?? 0) / 8) : -1
        guard bucket != coordinator.walkedBucket else { return }
        coordinator.walkedBucket = bucket

        let stale = map.overlays.compactMap { $0 as? StyledPolyline }.filter { $0.kind == .walked }
        map.removeOverlays(stale)

        guard bucket >= 0,
              let route = model.builtRoute,
              let progress = model.progress else { return }

        var coords = RouteTracking.walkedPath(
            route: route.coordinates,
            cumulative: route.cumulativeMeters,
            traveled: progress.traveledMeters
        )
        guard coords.count > 1 else { return }

        let line = StyledPolyline(coordinates: &coords, count: coords.count)
        line.kind = .walked
        map.addOverlay(line)
    }

    private func syncPins(on map: MKMapView, coordinator: Coordinator) {
        let signature = Coordinator.pinSignature(model.manualPins)
        guard signature != coordinator.pinSignature else { return }
        coordinator.pinSignature = signature

        map.removeAnnotations(map.annotations.compactMap { $0 as? RouteAnnotation })
        for (index, pin) in model.manualPins.enumerated() {
            let annotation = RouteAnnotation()
            annotation.coordinate = pin
            annotation.index = index
            annotation.title = "Pin \(index + 1)"
            map.addAnnotation(annotation)
        }
    }

    private func syncFollowMode(on map: MKMapView, coordinator: Coordinator) {
        guard coordinator.wasFollowing != followsUser else { return }
        coordinator.wasFollowing = followsUser
        if followsUser {
            map.setUserTrackingMode(.follow, animated: true)
        }
    }

    // MARK: - Coordinator

    @MainActor
    final class Coordinator: NSObject, MKMapViewDelegate {
        var model: AppModel
        var allowsPinEditing = false
        var overlaySignature = ""
        var pinSignature = ""
        var walkedBucket = -1
        var wasFollowing = false

        init(model: AppModel) { self.model = model }

        static func pinSignature(_ pins: [CLLocationCoordinate2D]) -> String {
            pins.map { "\($0.latitude),\($0.longitude)" }.joined(separator: ";")
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard allowsPinEditing, let map = gesture.view as? MKMapView else { return }
            let point = gesture.location(in: map)

            // Ignore taps that land on an existing pin so drag/select still works.
            for annotation in map.annotations {
                if let view = map.view(for: annotation), view.frame.contains(point) {
                    return
                }
            }

            let coordinate = map.convert(point, toCoordinateFrom: map)
            model.addManualPin(coordinate)
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let line = overlay as? MKPolyline else {
                return MKOverlayRenderer(overlay: overlay)
            }
            let renderer = MKPolylineRenderer(polyline: line)
            renderer.lineCap = .round

            guard let styled = line as? StyledPolyline else {
                renderer.lineWidth = 5
                renderer.strokeColor = Theme.denimUI
                return renderer
            }

            switch styled.kind {
            case .walked:
                // Dim what's already covered; pace colors stay visible around it.
                renderer.lineWidth = 9
                renderer.strokeColor = UIColor.black.withAlphaComponent(0.35)
            case .backward:
                // Return leg of an out-and-back: thin dots riding on the wide
                // outbound stripe so both legs' paces stay readable.
                renderer.lineWidth = 3.5
                renderer.lineDashPattern = [0.1, 8]
                renderer.strokeColor = styled.paceType.map(Theme.uiColor(for:)) ?? Theme.denimUI
            default:
                renderer.lineWidth = 7
                renderer.strokeColor = styled.paceType.map(Theme.uiColor(for:)) ?? Theme.denimUI
            }
            return renderer
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let routeAnnotation = annotation as? RouteAnnotation else { return nil }
            let identifier = "routePin"
            let view = (mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView)
                ?? MKMarkerAnnotationView(annotation: routeAnnotation, reuseIdentifier: identifier)
            view.annotation = routeAnnotation
            view.isDraggable = allowsPinEditing
            view.markerTintColor = Theme.denimUI
            view.glyphText = "\(routeAnnotation.index + 1)"
            return view
        }

        func mapView(
            _ mapView: MKMapView,
            annotationView view: MKAnnotationView,
            didChange newState: MKAnnotationView.DragState,
            fromOldState oldState: MKAnnotationView.DragState
        ) {
            guard newState == .ending, let annotation = view.annotation as? RouteAnnotation else { return }
            model.movePin(at: annotation.index, to: annotation.coordinate)
            // The map already shows the pin at its new spot; skip the next resync.
            pinSignature = Self.pinSignature(model.manualPins)
            view.dragState = .none
        }
    }
}
