//  ForecastViewModel.swift
//
//  Holds the forecast screen's state and runs the lookup.
//
//  One observable state object per screen: views only render `state` and call `search()`.
//  Main-actor isolated because SwiftUI reads it; the forecaster itself runs off the
//  main actor, so the UI stays responsive while Core ML works.

import Foundation
import Observation
import TheftForecastInterface

/// State and actions for `ForecastScreen`.
@MainActor
@Observable
final class ForecastViewModel {
    /// What the screen is showing.
    enum State: Equatable {
        case idle
        case loading
        case loaded(NeighbourhoodPrediction)
        case failed(String)
    }

    /// The postal code or neighbourhood name typed by the user.
    var query: String = "M5V 2T6"
    /// City-wide patrol units on duty per day.
    var patrolUnits: Int = 200
    /// Current screen state.
    private(set) var state: State = .idle

    private let forecaster: any TheftForecastProviding

    /// Creates the view model.
    ///
    /// - Parameter forecaster: Produces predictions.
    init(forecaster: any TheftForecastProviding) {
        self.forecaster = forecaster
    }

    /// Whether a search can run now.
    var canSearch: Bool {
        !query.trimmingCharacters(in: .whitespaces).isEmpty && state != .loading
    }

    /// Looks up the current query and updates `state`.
    func search() async {
        state = .loading
        do {
            let prediction: NeighbourhoodPrediction = try await forecaster.prediction(for: query, patrolUnits: patrolUnits)
            state = .loaded(prediction)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    /// Shows the forecast for a neighbourhood picked on the map.
    ///
    /// - Parameter name: The neighbourhood's full name, e.g. `Milliken (130)`.
    func show(neighbourhood name: String) async {
        query = name
        await search()
    }
}
