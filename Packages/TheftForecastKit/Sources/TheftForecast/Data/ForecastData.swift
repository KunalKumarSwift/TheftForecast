//  ForecastData.swift
//
//  The shape of `forecast_data.json`, written by `export_coreml.ipynb`.
//
//  Field names match the JSON keys exactly so decoding needs no custom keys. Arrays
//  are positional (characteristics follow `characteristicNames`, neighbours are
//  indices into `neighbourhoods`) to keep the bundled file around 1 MB.

import Foundation
import TheftForecastInterface

/// Everything needed to build model inputs and locate neighbourhoods on-device.
struct ForecastData: Decodable, Sendable {
    /// Model input order; must match the Core ML model's weights.
    let featureNames: [String]
    /// Names of the fixed neighbourhood characteristics, in `characteristics` order.
    let characteristicNames: [String]
    /// Last month of actual data, `yyyy-MM`.
    let lastMonth: String
    /// Patrol shift names, in `shiftShares` order.
    let shiftNames: [String]
    /// One record per neighbourhood (158).
    let neighbourhoods: [NeighbourhoodRecord]

    /// The last month of actual data as a `YearMonth`.
    ///
    /// - Throws: `TheftForecastError.resourcesUnavailable` if the month is malformed.
    func lastActualMonth() throws -> YearMonth {
        guard let month = YearMonth.parse(lastMonth) else {
            throw TheftForecastError.resourcesUnavailable("bad lastMonth '\(lastMonth)'")
        }
        return month
    }

    /// Looks up one characteristic for a neighbourhood by name.
    ///
    /// - Parameters:
    ///   - name: Characteristic name such as `population_k`.
    ///   - record: The neighbourhood.
    /// - Returns: The value.
    func characteristic(_ name: String, of record: NeighbourhoodRecord) -> Double {
        guard let index = characteristicNames.firstIndex(of: name) else {
            preconditionFailure("forecast_data.json has no characteristic '\(name)'")
        }
        return record.characteristics[index]
    }
}

/// One neighbourhood's data.
struct NeighbourhoodRecord: Decodable, Sendable {
    /// Name as in the police data, e.g. `Yorkdale-Glen Park (31)`.
    let name: String
    /// Actual monthly thefts, oldest first, ending at `lastMonth` (36 months).
    let history: [Int]
    /// Fixed characteristics in `characteristicNames` order.
    let characteristics: [Double]
    /// Indices of the 5 closest neighbourhoods.
    let neighbours: [Int]
    /// Share of thefts in each patrol shift, in `shiftNames` order.
    let shiftShares: [Double]
    /// Boundary outlines as `[longitude, latitude]` points.
    let outlines: [[[Double]]]
}
