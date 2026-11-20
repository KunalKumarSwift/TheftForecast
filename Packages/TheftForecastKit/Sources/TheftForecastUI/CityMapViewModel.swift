//  CityMapViewModel.swift
//
//  Holds the city risk map's state: every neighbourhood's outline and the tapped one.
//
//  Areas load once (the first load runs the city-wide forecast, later visits reuse it).
//  Tapped points are matched to a neighbourhood here so the map view only reports taps.

import Foundation
import Observation
import TheftForecastInterface

/// State and actions for the city risk map.
@MainActor
@Observable
final class CityMapViewModel {
    /// What the map is showing.
    enum State: Equatable {
        case loading
        case loaded([NeighbourhoodArea])
        case failed(String)
    }

    /// Current state.
    private(set) var state: State = .loading
    /// The neighbourhood the user tapped, if any.
    private(set) var selected: NeighbourhoodArea?
    /// When on, low and moderate neighbourhoods fade so high-risk pockets stand out.
    var highlightsHighRisk: Bool = false

    private let forecaster: any TheftForecastProviding

    /// Creates the view model.
    ///
    /// - Parameter forecaster: Supplies the neighbourhood outlines and risk levels.
    init(forecaster: any TheftForecastProviding) {
        self.forecaster = forecaster
    }

    /// Loads the neighbourhoods unless they are already loaded.
    func load() async {
        if case .loaded = state { return }
        state = .loading
        do {
            state = .loaded(try await forecaster.cityAreas())
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    /// Selects the neighbourhood under a tapped point, or clears the selection outside Toronto.
    ///
    /// - Parameter point: Where the user tapped.
    func select(at point: Coordinate) {
        guard case .loaded(let areas) = state else { return }
        selected = areas.first { $0.contains(point) }
    }

    /// Clears the selection.
    func clearSelection() {
        selected = nil
    }
}
