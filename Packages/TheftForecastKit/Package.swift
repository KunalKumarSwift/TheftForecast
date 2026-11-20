// swift-tools-version: 6.0
//  Package.swift — TheftForecastKit
//
//  Forecasts Toronto auto thefts per neighbourhood on-device with the Core ML model
//  exported by `export_coreml.ipynb`, and shows the result in SwiftUI.
//
//  Layering (dependencies point downward only):
//    TheftForecastUI  ──► TheftForecastInterface
//    TheftForecast    ──► TheftForecastInterface
//  The UI never imports the engine; the app wires `TheftForecaster` into the UI
//  through the `TheftForecastProviding` protocol.
//
//  macOS is listed so `swift test` runs the Core ML parity tests on a Mac.

import PackageDescription

let package = Package(
    name: "TheftForecastKit",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "TheftForecastInterface", targets: ["TheftForecastInterface"]),
        .library(name: "TheftForecast", targets: ["TheftForecast"]),
        .library(name: "TheftForecastUI", targets: ["TheftForecastUI"]),
    ],
    targets: [
        .target(name: "TheftForecastInterface"),
        .target(
            name: "TheftForecast",
            dependencies: ["TheftForecastInterface"],
            // Xcode compiles the .mlmodel to .mlmodelc anyway; `swift build` copies it raw. TheftModel loads either.
            resources: [.copy("Resources/AutoTheftRegressor.mlmodel"), .copy("Resources/forecast_data.json")]
        ),
        .target(name: "TheftForecastUI", dependencies: ["TheftForecastInterface"]),
        .testTarget(
            name: "TheftForecastTests",
            dependencies: ["TheftForecast", "TheftForecastInterface"],
            resources: [.copy("Resources/expected_forecast.json")]
        ),
    ]
)
