//  CityRiskMapView.swift
//
//  Map of all of Toronto's neighbourhoods, each filled with its risk level's colour.
//
//  Thin light borders keep neighbouring areas of the same level apart. The tapped
//  neighbourhood gets a heavy outline drawn last so it sits on top. The base map is muted
//  so the risk colours carry the picture. Taps are converted to coordinates with
//  `MapReader` because iOS 17 MapKit cannot report taps on polygons.

import MapKit
import SwiftUI
import TheftForecastInterface

/// Choropleth of risk across every neighbourhood.
struct CityRiskMapView: View {
    let areas: [NeighbourhoodArea]
    let selected: NeighbourhoodArea?
    let highlightsHighRisk: Bool
    let onTap: @MainActor (Coordinate) -> Void

    var body: some View {
        MapReader { proxy in
            Map(initialPosition: .region(BoundingBox(areas.flatMap { $0.outlines.joined() }).region(margin: 1.05))) {
                ForEach(areas) { area in
                    AreaPolygons(area: area, fill: fill(for: area), stroke: .white.opacity(0.6), lineWidth: 0.5)
                }
                ForEach(selected.map { [$0] } ?? []) { area in
                    AreaPolygons(area: area, fill: .clear, stroke: .primary, lineWidth: 3)
                }
            }
            .mapStyle(.standard(emphasis: .muted, pointsOfInterest: .excludingAll))
            .onTapGesture { position in
                if let location = proxy.convert(position, from: .local) {
                    onTap(Coordinate(latitude: location.latitude, longitude: location.longitude))
                }
            }
        }
    }

    private func fill(for area: NeighbourhoodArea) -> Color {
        let isFaded: Bool = highlightsHighRisk && (area.riskLevel == .low || area.riskLevel == .moderate)
        return area.riskLevel.tint.opacity(isFaded ? 0.12 : 0.65)
    }
}
