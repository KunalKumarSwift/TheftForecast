//  MapGeometry.swift
//
//  Map helpers shared by the neighbourhood map and the city risk map.
//
//  Outline drawing, camera fitting and tap hit-testing live here so both maps draw a
//  neighbourhood the same way. Hit-testing uses the even-odd ray-casting rule because
//  iOS 17 MapKit cannot report taps on polygons directly.

import MapKit
import SwiftUI
import TheftForecastInterface

/// Draws every outline of one neighbourhood as filled polygons.
struct AreaPolygons: MapContent {
    let area: NeighbourhoodArea
    let fill: Color
    let stroke: Color
    let lineWidth: CGFloat

    var body: some MapContent {
        ForEach(Array(area.outlines.enumerated()), id: \.offset) { item in
            MapPolygon(coordinates: item.element.map(\.location))
                .foregroundStyle(fill)
                .stroke(stroke, lineWidth: lineWidth)
        }
    }
}

/// The smallest latitude/longitude box around a set of points.
struct BoundingBox {
    let minLatitude: Double
    let maxLatitude: Double
    let minLongitude: Double
    let maxLongitude: Double

    /// Creates the box around some points.
    ///
    /// - Parameter points: At least one point.
    init(_ points: [Coordinate]) {
        precondition(!points.isEmpty, "a neighbourhood always has an outline")
        minLatitude = points.map(\.latitude).min() ?? 0
        maxLatitude = points.map(\.latitude).max() ?? 0
        minLongitude = points.map(\.longitude).min() ?? 0
        maxLongitude = points.map(\.longitude).max() ?? 0
    }

    /// The middle of the box.
    var center: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: (minLatitude + maxLatitude) / 2, longitude: (minLongitude + maxLongitude) / 2)
    }

    /// A map region showing the whole box with a margin.
    ///
    /// - Parameter margin: Scale applied to the box, e.g. `1.15` for 15% extra.
    /// - Returns: The region.
    func region(margin: Double) -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(
                latitudeDelta: (maxLatitude - minLatitude) * margin,
                longitudeDelta: (maxLongitude - minLongitude) * margin
            )
        )
    }
}

extension NeighbourhoodArea {
    // Centre of the largest ring's box: cheap, and inside the shape for Toronto's mostly compact neighbourhoods.
    var labelPoint: CLLocationCoordinate2D {
        BoundingBox(outlines.max { $0.count < $1.count } ?? []).center
    }

    /// Whether a point falls inside any of the neighbourhood's outlines.
    ///
    /// - Parameter point: The point to test.
    /// - Returns: `true` when the point is inside.
    func contains(_ point: Coordinate) -> Bool {
        outlines.contains { ring -> Bool in
            var inside: Bool = false
            var previous: Coordinate = ring[ring.count - 1]
            for vertex in ring {
                if (vertex.latitude > point.latitude) != (previous.latitude > point.latitude) {
                    let crossing: Double = (previous.longitude - vertex.longitude) * (point.latitude - vertex.latitude)
                        / (previous.latitude - vertex.latitude) + vertex.longitude
                    if point.longitude < crossing { inside.toggle() }
                }
                previous = vertex
            }
            return inside
        }
    }
}

extension Coordinate {
    /// The coordinate as a MapKit location.
    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
