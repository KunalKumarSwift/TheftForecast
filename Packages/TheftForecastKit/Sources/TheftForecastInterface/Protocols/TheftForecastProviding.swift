//  TheftForecastProviding.swift
//
//  The contract the UI uses to ask for a neighbourhood's prediction.
//
//  The UI depends on this protocol instead of the Core ML engine, so screens can be
//  previewed and tested with a stub and the engine can change without touching the UI.

import Foundation

/// Produces a neighbourhood prediction from a postal code or neighbourhood name.
public protocol TheftForecastProviding: Sendable {
    /// Finds the neighbourhood for a query and returns its forecast, ranks and patrol plan.
    ///
    /// - Parameters:
    ///   - query: A Toronto postal code (`M5V 2T6` or `M5V`) or part of a neighbourhood name.
    ///   - patrolUnits: Auto-theft patrol units on duty per day across the whole city.
    /// - Returns: The prediction for the matched neighbourhood.
    /// - Throws: `TheftForecastError` when the query cannot be matched or the model cannot run.
    func prediction(for query: String, patrolUnits: Int) async throws -> NeighbourhoodPrediction

    /// Returns every neighbourhood's outline and risk, for the city-wide map.
    ///
    /// - Returns: All neighbourhoods, in the data's order.
    /// - Throws: `TheftForecastError.resourcesUnavailable` if the model or data cannot be loaded.
    func cityAreas() async throws -> [NeighbourhoodArea]
}
