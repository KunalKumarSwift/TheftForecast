//  Rankings.swift
//
//  Ranks neighbourhoods by forecast thefts, in total and per 1,000 residents.
//
//  Reproduces pandas exactly: `rank(ascending=False, method="min")` (ties share the best
//  rank) and `pd.qcut(..., 4)` quartiles using linear-interpolated quantiles, so the
//  app's ranks and risk levels match the notebook.

import Foundation
import TheftForecastInterface

/// Ranks and risk levels for all neighbourhoods.
struct Rankings {
    /// Forecast thefts over the next 12 months, per neighbourhood.
    let nextTwelve: [Double]
    /// The same per 1,000 residents.
    let perThousand: [Double]
    /// Rank by total (1 = most thefts).
    let rankByTotal: [Int]
    /// Rank per resident (1 = most).
    let rankPerResident: [Int]
    /// Risk quarter by thefts per resident.
    let riskLevels: [RiskLevel]

    /// Computes ranks from the 24-month forecast.
    ///
    /// - Parameters:
    ///   - forecast: `forecast[hood][monthIndex]` from `RecursiveForecaster`.
    ///   - populationThousands: Residents in thousands, per neighbourhood.
    init(forecast: [[Double]], populationThousands: [Double]) {
        let totals: [Double] = forecast.map { $0.prefix(12).reduce(0, +) }
        let rates: [Double] = zip(totals, populationThousands).map { $0 / $1 }
        nextTwelve = totals
        perThousand = rates
        rankByTotal = Rankings.minRankDescending(totals)
        rankPerResident = Rankings.minRankDescending(rates)

        let edges: [Double] = [0.25, 0.5, 0.75].map { Rankings.quantile(rates, $0) }
        riskLevels = rates.map { value -> RiskLevel in
            if value <= edges[0] { return .low }
            if value <= edges[1] { return .moderate }
            if value <= edges[2] { return .high }
            return .veryHigh
        }
    }

    private static func minRankDescending(_ values: [Double]) -> [Int] {
        values.map { value -> Int in values.filter { $0 > value }.count + 1 }
    }

    // numpy's default "linear" quantile, which pd.qcut uses for its bin edges.
    private static func quantile(_ values: [Double], _ fraction: Double) -> Double {
        let sorted: [Double] = values.sorted()
        let position: Double = fraction * Double(sorted.count - 1)
        let lower: Int = Int(position.rounded(.down))
        let upper: Int = min(lower + 1, sorted.count - 1)
        return sorted[lower] + (sorted[upper] - sorted[lower]) * (position - Double(lower))
    }
}
