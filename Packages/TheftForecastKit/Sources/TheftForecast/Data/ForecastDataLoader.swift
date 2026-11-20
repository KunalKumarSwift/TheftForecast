//  ForecastDataLoader.swift
//
//  Loads the bundled `forecast_data.json` and checks it matches the Core ML model.
//
//  Reads from `Bundle.module` (never `Bundle.main`) so the package works in any app.
//  The feature-order check matters: the model is a plain weight vector, so inputs in
//  the wrong order would silently produce wrong forecasts.

import Foundation
import TheftForecastInterface

/// Loads and validates the bundled forecast data.
enum ForecastDataLoader {
    /// The variable order the Swift `FeatureBuilder` produces.
    static let expectedFeatureNames: [String] = [
        "lag1", "lag2", "lag3", "lag12", "roll12", "near_roll3", "month_sin", "month_cos",
    ]

    /// Decodes `forecast_data.json` from the package bundle.
    ///
    /// - Returns: The decoded data.
    /// - Throws: `TheftForecastError.resourcesUnavailable` if the file is missing, malformed,
    ///   or its feature order does not match what `FeatureBuilder` produces.
    static func load() throws -> ForecastData {
        guard let url = Bundle.module.url(forResource: "forecast_data", withExtension: "json") else {
            throw TheftForecastError.resourcesUnavailable("forecast_data.json is missing from the bundle")
        }
        let data: ForecastData
        do {
            data = try JSONDecoder().decode(ForecastData.self, from: Data(contentsOf: url))
        } catch {
            throw TheftForecastError.resourcesUnavailable("forecast_data.json: \(error.localizedDescription)")
        }
        guard data.featureNames == expectedFeatureNames + data.characteristicNames else {
            throw TheftForecastError.resourcesUnavailable("feature order in forecast_data.json does not match the app")
        }
        return data
    }
}
