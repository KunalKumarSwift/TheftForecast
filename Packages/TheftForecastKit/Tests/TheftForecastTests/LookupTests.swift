//  LookupTests.swift
//
//  Checks postal-code and name lookups resolve to the right neighbourhood.
//
//  Uses a stub geocoder with known coordinates (checked against the boundaries in
//  Python) so the tests run offline and do not depend on Apple's geocoding service.

import Foundation
import Testing
import TheftForecast
import TheftForecastInterface

/// Returns a fixed point, or "not found" when `point` is nil.
struct StubGeocoder: PostalCodeGeocoding {
    let point: Coordinate?

    func coordinate(forPostalCode postalCode: String) async throws -> Coordinate {
        guard let point else { throw TheftForecastError.postalCodeNotFound(postalCode) }
        return point
    }
}

@Suite("Finding the neighbourhood")
struct LookupTests {
    @Test("A postal code is located by boundary", arguments: [
        (Coordinate(latitude: 43.7255, longitude: -79.4522), "Yorkdale-Glen Park (31)"),  // Yorkdale Mall
        (Coordinate(latitude: 43.6426, longitude: -79.3871), "Harbourfront-CityPlace (165)"),  // CN Tower
    ])
    func postalCodeUsesBoundaries(point: Coordinate, expectedName: String) async throws {
        let forecaster: TheftForecaster = TheftForecaster(geocoder: StubGeocoder(point: point))
        let prediction: NeighbourhoodPrediction = try await forecaster.prediction(for: "m6a 2t9", patrolUnits: 200)

        #expect(prediction.name == expectedName)
        #expect(prediction.matchDescription == "from postal code M6A 2T9")
    }

    @Test("A point in the lake is outside Toronto")
    func pointOutsideToronto() async throws {
        let lake: Coordinate = Coordinate(latitude: 43.60, longitude: -79.35)
        let forecaster: TheftForecaster = TheftForecaster(geocoder: StubGeocoder(point: lake))

        await #expect(throws: TheftForecastError.outsideToronto("M5J")) {
            try await forecaster.prediction(for: "M5J", patrolUnits: 200)
        }
    }

    @Test("Names: partial, ambiguous and misspelled")
    func nameMatching() async throws {
        let forecaster: TheftForecaster = TheftForecaster(geocoder: StubGeocoder(point: nil))

        let partial: NeighbourhoodPrediction = try await forecaster.prediction(for: "yorkdale", patrolUnits: 200)
        #expect(partial.name == "Yorkdale-Glen Park (31)")

        let typo: NeighbourhoodPrediction = try await forecaster.prediction(for: "Milikenn", patrolUnits: 200)
        #expect(typo.name == "Milliken (130)")

        await #expect(throws: TheftForecastError.self) {
            try await forecaster.prediction(for: "Humber", patrolUnits: 200)
        }
    }
}
