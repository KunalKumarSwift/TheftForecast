//  TheftForecastTabs.swift
//
//  The UI target's public entry point: a tab bar with the forecast and the city risk map.
//
//  Both tabs' view models live here so the map can hand a neighbourhood to the forecast
//  tab ("Open forecast") without either screen knowing about the other. It receives the
//  forecaster from the app (dependency injection), so it never imports the Core ML engine.

import SwiftUI
import TheftForecastInterface

/// Root view with the "Forecast" and "Risk map" tabs.
public struct TheftForecastTabs: View {
    private enum Tab: Hashable {
        case forecast
        case riskMap
    }

    @State private var tab: Tab = .forecast
    @State private var forecastModel: ForecastViewModel
    @State private var cityMapModel: CityMapViewModel

    /// Creates the tabs.
    ///
    /// - Parameter forecaster: Produces predictions (the app passes `TheftForecaster.live()`).
    public init(forecaster: any TheftForecastProviding) {
        _forecastModel = State(initialValue: ForecastViewModel(forecaster: forecaster))
        _cityMapModel = State(initialValue: CityMapViewModel(forecaster: forecaster))
    }

    public var body: some View {
        TabView(selection: $tab) {
            ForecastScreen(viewModel: forecastModel)
                .tabItem { Label("Forecast", systemImage: "chart.line.uptrend.xyaxis") }
                .tag(Tab.forecast)
            CityMapScreen(viewModel: cityMapModel, onOpenForecast: { openForecast($0) })
                .tabItem { Label("Risk map", systemImage: "map") }
                .tag(Tab.riskMap)
        }
    }

    private func openForecast(_ name: String) {
        tab = .forecast
        Task { await forecastModel.show(neighbourhood: name) }
    }
}
