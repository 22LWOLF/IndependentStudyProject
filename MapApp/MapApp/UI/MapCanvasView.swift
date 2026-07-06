//
//  MapCanvasView.swift
//  MapApp
//
//  SwiftUI wrapper around MKMapView. Renders the built route as pace-colored
//  polylines, shows draggable manual pins, and (on the Build tab) lets a tap
//  drop a new pin.
//

import SwiftUI
import MapKit

struct MapCanvasView: UIViewRepresentable {
    @EnvironmentObject private var model: AppModel

    /// When true, tapping the map drops manual pins and pins can be dragged.
    var allowsPinEditing = false

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
        syncPins(on: map, coordinator: context.coordinator)
    }

    func makeCoordinator() -> Coordinator { Coordinator(model: model) }

    // MARK: - Syncing

    private func syncOverlays(on map: MKMapView, coordinator: Coordinator) {
        let signature = model.builtRoute.map {
            "\($0.coordinates.count)-\(Int($0.totalMeters))-\($0.paceSegments.count)"
        } ?? "none"
        guard signature != coordinator.overlaySignature else { return }
        coordinator.overlaySignature = signature

        map.removeOverlays(map.overlays)
        guard let route = model.builtRoute else { return }

        for run in route.coloredSegments where run.coords.count > 1 {
            var coords = run.coords
            let line = StyledPolyline(coordinates: &coords, count: coords.count)
            line.paceType = run.pace
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

    // MARK: - Coordinator

    @MainActor
    final class Coordinator: NSObject, MKMapViewDelegate {
        var model: AppModel
        var allowsPinEditing = false
        var overlaySignature = ""
        var pinSignature = ""

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
            renderer.lineWidth = 5
            renderer.lineCap = .round
            if let styled = line as? StyledPolyline, let pace = styled.paceType {
                renderer.strokeColor = Theme.uiColor(for: pace)
            } else {
                renderer.strokeColor = Theme.denimUI
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
