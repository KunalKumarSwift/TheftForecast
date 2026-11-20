//  ForecastParityTests.swift
//
//  Proves the on-device Core ML forecast equals the v4 notebook's forecast.
//
//  `expected_forecast.json` is written by `export_coreml.ipynb` from the notebook's own
//  `future_forecast`, ranks and risk levels. If the Swift feature builder ever drifts from
//  `make_features`, these tests fail. Runs offline: a stub geocoder is injected.

import Foundation
import Testing
import TheftForecast
import TheftForecastInterface

/// Decoded `expected_forecast.json`.
private struct ExpectedForecast: Decodable {
    let forecast: [String: [Double]]
    let rankTotal: [String: Int]
    let rankPerCapita: [String: Int]
    let riskLevel: [String: String]

    static func load() throws -> ExpectedForecast {
        let url: URL = try #require(Bundle.module.url(forResource: "expected_forecast", withExtension: "json"))
        return try JSONDecoder().decode(ExpectedForecast.self, from: Data(contentsOf: url))
    }
}

@Suite("Core ML forecast matches the notebook")
struct ForecastParityTests {
    private let forecaster: TheftForecaster = TheftForecaster(geocoder: StubGeocoder(point: nil))

    @Test("24-month forecast for all 158 neighbourhoods")
    func forecastMatchesNotebook() async throws {
        let expected: ExpectedForecast = try ExpectedForecast.load()
        let actual: [String: [Double]] = try await forecaster.cityForecast()

        #expect(actual.count == 158)
        #expect(Set(actual.keys) == Set(expected.forecast.keys))
        var largestGap: Double = 0
        for (name, notebookValues) in expected.forecast {
            let appValues: [Double] = try #require(actual[name])
            #expect(appValues.count == 24)
            for (app, notebook) in zip(appValues, notebookValues) {
                largestGap = max(largestGap, abs(app - notebook))
            }
        }
        // The notebook rounds to 6 decimals; anything beyond that is floating-point noise.
        #expect(largestGap < 1e-5, "largest difference from the notebook: \(largestGap)")
    }

    @Test("Ranks and risk levels", arguments: [
        "Yorkdale-Glen Park (31)", "West Humber-Clairville (1)", "Fort York-Liberty Village (163)",
        "Harbourfront-CityPlace (165)", "Humber Summit (21)",
    ])
    func ranksMatchNotebook(name: String) async throws {
        let expected: ExpectedForecast = try ExpectedForecast.load()
        let prediction: NeighbourhoodPrediction = try await forecaster.prediction(for: name, patrolUnits: 200)

        #expect(prediction.name == name)
        #expect(prediction.rankByTotal == expected.rankTotal[name])
        #expect(prediction.rankPerResident == expected.rankPerCapita[name])
        #expect(prediction.riskLevel.rawValue == expected.riskLevel[name])
    }

    @Test("Every neighbourhood's risk level matches")
    func allRiskLevelsMatch() async throws {
        let expected: ExpectedForecast = try ExpectedForecast.load()
        var mismatches: [String] = []
        for (name, level) in expected.riskLevel {
            let prediction: NeighbourhoodPrediction = try await forecaster.prediction(for: name, patrolUnits: 200)
            if prediction.riskLevel.rawValue != level || prediction.rankPerResident != expected.rankPerCapita[name] {
                mismatches.append(name)
            }
        }
        #expect(mismatches.isEmpty, "mismatched: \(mismatches)")
    }

    @Test("Patrol plan shares the city's units")
    func patrolPlanAddsUp() async throws {
        let prediction: NeighbourhoodPrediction = try await forecaster.prediction(for: "Yorkdale", patrolUnits: 300)

        #expect(prediction.patrolPlan.count == 6)
        for month in prediction.patrolPlan {
            let shiftTotal: Double = month.shifts.reduce(0) { $0 + $1.units }
            #expect(abs(shiftTotal - month.unitsPerDay) < 1e-9)
            #expect(month.unitsPerDay > 0 && month.unitsPerDay < 300)
        }
    }
}
