//  NeighbourhoodLocator.swift
//
//  Finds which neighbourhood contains a point, using the exported boundary outlines.
//
//  Uses the even-odd ray-casting test (the same idea as matplotlib's `contains_point`
//  in the notebook). Outlines are `[longitude, latitude]`, GeoJSON order, so the point
//  is tested as (longitude, latitude).

import Foundation
import TheftForecastInterface

/// Point-in-boundary lookup for the 158 neighbourhoods.
struct NeighbourhoodLocator {
    private let neighbourhoods: [NeighbourhoodRecord]

    /// Creates a locator.
    ///
    /// - Parameter neighbourhoods: Records with boundary outlines.
    init(neighbourhoods: [NeighbourhoodRecord]) {
        self.neighbourhoods = neighbourhoods
    }

    /// Returns the index of the neighbourhood containing a point.
    ///
    /// - Parameter coordinate: The point to test.
    /// - Returns: The neighbourhood index, or `nil` when the point is outside Toronto.
    func neighbourhoodIndex(containing coordinate: Coordinate) -> Int? {
        neighbourhoods.firstIndex { record -> Bool in
            record.outlines.contains { outline -> Bool in
                contains(outline: outline, x: coordinate.longitude, y: coordinate.latitude)
            }
        }
    }

    private func contains(outline: [[Double]], x: Double, y: Double) -> Bool {
        var inside: Bool = false
        var previous: [Double] = outline[outline.count - 1]
        for point in outline {
            let crossesRay: Bool = (point[1] > y) != (previous[1] > y)
            if crossesRay {
                let crossingX: Double = (previous[0] - point[0]) * (y - point[1]) / (previous[1] - point[1]) + point[0]
                if x < crossingX { inside.toggle() }
            }
            previous = point
        }
        return inside
    }
}
