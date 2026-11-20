//  MapDataTests.swift
//
//  Checks the map data attached to a prediction: outline, bordering areas and city average.
//
//  The expected borders for Yorkdale-Glen Park were worked out in Python from the same
//  boundary file (neighbourhoods sharing at least two boundary vertices), and match the
//  city's published neighbourhood map.

import Foundation
import Testing
import TheftForecast
import TheftForecastInterface

@Suite("Map data")
struct MapDataTests {
    @Test("Bordering neighbourhoods are the ones that share a boundary")
    func borderingAreas() async throws {
        let forecaster: TheftForecaster = TheftForecaster(geocoder: StubGeocoder(point: nil))
        let prediction: NeighbourhoodPrediction = try await forecaster.prediction(for: "Yorkdale", patrolUnits: 200)

        #expect(Set(prediction.borderingAreas.map(\.name)) == [
            "Briar Hill-Belgravia (108)", "Brookhaven-Amesbury (30)", "Clanton Park (33)", "Downsview (155)",
            "Englemount-Lawrence (32)", "Forest Hill North (102)", "Maple Leaf (29)",
        ])
        let rates: [Double] = prediction.borderingAreas.map(\.perThousandResidents)
        #expect(rates == rates.sorted(by: >))
    }

    @Test("The neighbourhood's own area matches its prediction")
    func ownArea() async throws {
        let forecaster: TheftForecaster = TheftForecaster(geocoder: StubGeocoder(point: nil))
        let prediction: NeighbourhoodPrediction = try await forecaster.prediction(for: "Milliken", patrolUnits: 200)

        #expect(prediction.area.name == prediction.name)
        #expect(prediction.area.shortName == "Milliken")
        #expect(prediction.area.riskLevel == prediction.riskLevel)
        #expect(prediction.area.perThousandResidents == prediction.perThousandResidents)
        #expect(prediction.area.outlines.allSatisfy { $0.count >= 3 })
        #expect(prediction.cityPerThousandResidents > 0)
    }
}
