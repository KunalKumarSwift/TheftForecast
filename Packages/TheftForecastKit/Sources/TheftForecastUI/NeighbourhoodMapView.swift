//  NeighbourhoodMapView.swift
//
//  Map of the neighbourhood and the neighbourhoods bordering it, shaded by risk level.
//
//  The searched neighbourhood gets a heavy outline so it stands out whatever its risk.
//  Names are drawn as buttons on the map, so tapping a bordering neighbourhood opens its
//  forecast. The camera fits all shown outlines; the view is re-created (`.id`) for each
//  new search so the camera moves to the new area. Panning is off so a vertical swipe over
//  the map scrolls the page instead of getting trapped in the map; pinch-zoom still works.

import MapKit
import SwiftUI
import TheftForecastInterface

/// Map of a neighbourhood and its bordering neighbourhoods.
struct NeighbourhoodMapView: View {
    let prediction: NeighbourhoodPrediction
    /// Called with a neighbourhood's full name when its label is tapped.
    let onSelect: (String) -> Void

    var body: some View {
        Map(initialPosition: .region(fittingRegion), interactionModes: [.zoom]) {
            ForEach(prediction.borderingAreas) { area in
                shapes(for: area, isSelected: false)
            }
            shapes(for: prediction.area, isSelected: true)
            ForEach(prediction.borderingAreas) { area in
                label(for: area, isSelected: false)
            }
            label(for: prediction.area, isSelected: true)
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .frame(height: 320)
        .id(prediction.name)
    }

    @MapContentBuilder
    private func shapes(for area: NeighbourhoodArea, isSelected: Bool) -> some MapContent {
        ForEach(Array(area.outlines.enumerated()), id: \.offset) { item in
            MapPolygon(coordinates: item.element.map(\.location))
                .foregroundStyle(area.riskLevel.tint.opacity(isSelected ? 0.6 : 0.4))
                .stroke(isSelected ? Color.primary : area.riskLevel.tint, lineWidth: isSelected ? 3 : 1)
        }
    }

    @MapContentBuilder
    private func label(for area: NeighbourhoodArea, isSelected: Bool) -> some MapContent {
        Annotation(area.shortName, coordinate: area.labelPoint) {
            if isSelected {
                nameTag(area.shortName, weight: .bold)
            } else {
                Button {
                    onSelect(area.name)
                } label: {
                    nameTag(area.shortName, weight: .medium)
                }
                .buttonStyle(.plain)
                .accessibilityHint("Shows this neighbourhood's forecast")
            }
        }
        .annotationTitles(.hidden)
    }

    private func nameTag(_ name: String, weight: Font.Weight) -> some View {
        Text(name)
            .font(.caption2.weight(weight))
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .frame(maxWidth: 110)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(.regularMaterial, in: Capsule())
    }

    private var fittingRegion: MKCoordinateRegion {
        let points: [Coordinate] = ([prediction.area] + prediction.borderingAreas).flatMap { $0.outlines.joined() }
        let box: BoundingBox = BoundingBox(points)
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: box.midLatitude, longitude: box.midLongitude),
            span: MKCoordinateSpan(latitudeDelta: box.latitudeSpan * 1.15, longitudeDelta: box.longitudeSpan * 1.15)
        )
    }
}

/// The smallest latitude/longitude box around a set of points.
private struct BoundingBox {
    let minLatitude: Double
    let maxLatitude: Double
    let minLongitude: Double
    let maxLongitude: Double

    init(_ points: [Coordinate]) {
        precondition(!points.isEmpty, "a neighbourhood always has an outline")
        minLatitude = points.map(\.latitude).min() ?? 0
        maxLatitude = points.map(\.latitude).max() ?? 0
        minLongitude = points.map(\.longitude).min() ?? 0
        maxLongitude = points.map(\.longitude).max() ?? 0
    }

    var midLatitude: Double { (minLatitude + maxLatitude) / 2 }
    var midLongitude: Double { (minLongitude + maxLongitude) / 2 }
    var latitudeSpan: Double { maxLatitude - minLatitude }
    var longitudeSpan: Double { maxLongitude - minLongitude }
}

private extension NeighbourhoodArea {
    // Centre of the largest ring's box: cheap, and inside the shape for Toronto's mostly compact neighbourhoods.
    var labelPoint: CLLocationCoordinate2D {
        let largest: [Coordinate] = outlines.max { $0.count < $1.count } ?? []
        let box: BoundingBox = BoundingBox(largest)
        return CLLocationCoordinate2D(latitude: box.midLatitude, longitude: box.midLongitude)
    }
}

private extension Coordinate {
    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
