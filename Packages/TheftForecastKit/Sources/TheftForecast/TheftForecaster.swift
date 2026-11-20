//  TheftForecaster.swift
//
//  The single public entry point of the TheftForecast engine.
//
//  An actor so the Core ML model and the cached city-wide forecast are loaded once and
//  safely shared across concurrent requests. Loading is deferred to the first query,
//  keeping app launch fast. `live()` wires Apple's geocoder; tests inject a stub.

import Foundation
import TheftForecastInterface

/// Forecasts auto thefts for a Toronto neighbourhood from a postal code or name, on-device.
public actor TheftForecaster: TheftForecastProviding {
    private let geocoder: any PostalCodeGeocoding
    private var snapshot: ForecastSnapshot?

    /// Creates a forecaster.
    ///
    /// - Parameter geocoder: Turns postal codes into coordinates.
    public init(geocoder: any PostalCodeGeocoding) {
        self.geocoder = geocoder
    }

    /// Creates a forecaster that geocodes postal codes with Apple's CoreLocation geocoder.
    ///
    /// - Returns: A ready-to-use forecaster.
    public static func live() -> TheftForecaster {
        TheftForecaster(geocoder: AppleGeocodingProvider())
    }

    /// Finds the neighbourhood for a query and returns its forecast, ranks and patrol plan.
    ///
    /// - Parameters:
    ///   - query: A Toronto postal code (`M5V 2T6` or `M5V`) or part of a neighbourhood name.
    ///   - patrolUnits: Auto-theft patrol units on duty per day across the whole city.
    /// - Returns: The prediction for the matched neighbourhood.
    /// - Throws: `TheftForecastError` when the query cannot be matched or the model cannot run.
    public func prediction(for query: String, patrolUnits: Int) async throws -> NeighbourhoodPrediction {
        let current: ForecastSnapshot = try await loadedSnapshot()
        let match: (index: Int, how: String) = try await QueryResolver(data: current.data, geocoder: geocoder)
            .resolve(query)
        return current.prediction(hood: match.index, how: match.how, patrolUnits: patrolUnits)
    }

    /// Returns every neighbourhood's outline and risk, for the city-wide map.
    ///
    /// - Returns: All neighbourhoods, in the data's order.
    /// - Throws: `TheftForecastError.resourcesUnavailable` if the model or data cannot be loaded.
    public func cityAreas() async throws -> [NeighbourhoodArea] {
        let current: ForecastSnapshot = try await loadedSnapshot()
        return current.data.neighbourhoods.indices.map(current.area(hood:))
    }

    /// The 24-month forecast for every neighbourhood, keyed by name.
    ///
    /// - Returns: Forecast thefts per month for each neighbourhood, first month first.
    /// - Throws: `TheftForecastError.resourcesUnavailable` if the model or data cannot be loaded.
    /// - Note: Used by the parity tests to compare against the notebook.
    public func cityForecast() async throws -> [String: [Double]] {
        let current: ForecastSnapshot = try await loadedSnapshot()
        return Dictionary(uniqueKeysWithValues: zip(current.data.neighbourhoods.map(\.name), current.forecast))
    }

    private func loadedSnapshot() async throws -> ForecastSnapshot {
        if let snapshot { return snapshot }
        let data: ForecastData = try ForecastDataLoader.load()
        let model: TheftModel = try await TheftModel(expectedInputCount: data.featureNames.count)
        let built: ForecastSnapshot = try ForecastSnapshot(data: data, model: model)
        snapshot = built
        return built
    }
}
