//  NeighbourhoodArea.swift
//
//  A neighbourhood's boundary plus the few numbers needed to colour and compare it on a map.
//
//  Kept separate from `NeighbourhoodPrediction` so the map can show the bordering
//  neighbourhoods too without running (or carrying) their full forecast and patrol plan.

import Foundation

/// A neighbourhood's outline and headline forecast, for maps and comparisons.
public struct NeighbourhoodArea: Sendable, Equatable, Identifiable {
    /// Name as in the police data, e.g. `Yorkdale-Glen Park (31)`.
    public let name: String
    /// Boundary outlines (usually one), each a closed ring of points.
    public let outlines: [[Coordinate]]
    /// Forecast thefts over the next 12 months.
    public let nextTwelveMonths: Double
    /// Next-12-month forecast per 1,000 residents.
    public let perThousandResidents: Double
    /// Rank by forecast thefts per resident (1 = most).
    public let rankPerResident: Int
    /// Risk quarter by thefts per resident.
    public let riskLevel: RiskLevel

    public var id: String { name }

    /// Creates an area. Values are produced by the forecasting engine.
    ///
    /// - Parameters:
    ///   - name: Neighbourhood name.
    ///   - outlines: Boundary rings.
    ///   - nextTwelveMonths: Forecast thefts, next 12 months.
    ///   - perThousandResidents: Forecast per 1,000 residents.
    ///   - rankPerResident: Rank per resident.
    ///   - riskLevel: Risk quarter.
    public init(
        name: String, outlines: [[Coordinate]], nextTwelveMonths: Double,
        perThousandResidents: Double, rankPerResident: Int, riskLevel: RiskLevel
    ) {
        self.name = name
        self.outlines = outlines
        self.nextTwelveMonths = nextTwelveMonths
        self.perThousandResidents = perThousandResidents
        self.rankPerResident = rankPerResident
        self.riskLevel = riskLevel
    }

    /// The name without the trailing police number, e.g. `Yorkdale-Glen Park`.
    public var shortName: String {
        name.replacing(/\s*\(\d+\)$/, with: "")
    }
}
