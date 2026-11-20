//  TheftForecastApp.swift
//
//  App entry point and composition root: wires the Core ML engine into the UI.
//
//  This file only connects packages. All forecasting lives in `TheftForecast` and all
//  screens in `TheftForecastUI`, so the same features can be reused by another app.

import SwiftUI
import TheftForecast
import TheftForecastUI

/// The Toronto auto-theft forecast app.
@main
struct TheftForecastApp: App {
    // Created once; the actor loads the Core ML model lazily on the first search.
    private let forecaster: TheftForecaster = .live()

    var body: some Scene {
        WindowGroup {
            TheftForecastTabs(forecaster: forecaster)
        }
    }
}
