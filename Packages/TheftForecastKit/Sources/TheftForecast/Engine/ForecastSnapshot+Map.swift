//  ForecastSnapshot+Map.swift
//
//  Builds the map data for a prediction: the neighbourhood's outline and its bordering areas.
//
//  Bordering areas reuse the city-wide ranks already in the snapshot, so showing them on
//  the map costs no extra Core ML work.

import Foundation
import TheftForecastInterface

extension ForecastSnapshot {
    /// The outline and headline numbers for one neighbourhood.
    ///
    /// - Parameter hood: Neighbourhood index.
    /// - Returns: The map area.
    func area(hood: Int) -> NeighbourhoodArea {
        let record: NeighbourhoodRecord = data.neighbourhoods[hood]
        return NeighbourhoodArea(
            name: record.name,
            outlines: record.outlines.map { outline -> [Coordinate] in
                outline.map { Coordinate(latitude: $0[1], longitude: $0[0]) }
            },
            nextTwelveMonths: rankings.nextTwelve[hood],
            perThousandResidents: rankings.perThousand[hood],
            rankPerResident: rankings.rankPerResident[hood],
            riskLevel: rankings.riskLevels[hood]
        )
    }

    /// The neighbourhoods bordering one neighbourhood, most thefts per resident first.
    ///
    /// - Parameter hood: Neighbourhood index.
    /// - Returns: The bordering areas.
    func borderingAreas(hood: Int) -> [NeighbourhoodArea] {
        borders[hood].map(area(hood:)).sorted { $0.perThousandResidents > $1.perThousandResidents }
    }

    /// Toronto-wide next-12-month forecast per 1,000 residents.
    var cityPerThousandResidents: Double {
        let population: Double = data.neighbourhoods.reduce(0) { $0 + data.characteristic("population_k", of: $1) }
        return rankings.nextTwelve.reduce(0, +) / population
    }
}
