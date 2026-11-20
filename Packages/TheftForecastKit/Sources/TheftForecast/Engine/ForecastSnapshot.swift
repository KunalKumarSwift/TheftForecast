//  ForecastSnapshot.swift
//
//  The 24-month forecast and ranks for all neighbourhoods, computed once and reused.
//
//  Ranks need every neighbourhood's forecast, so the whole city is forecast once
//  (158 x 24 predictions, a fraction of a second) and each user query then only
//  assembles the answer for its neighbourhood.

import Foundation
import TheftForecastInterface

/// City-wide forecast results plus the per-neighbourhood answer builder.
struct ForecastSnapshot {
    /// How many months are forecast.
    static let forecastMonths: Int = 24

    let data: ForecastData
    let forecast: [[Double]]
    let rankings: Rankings
    let lastMonth: YearMonth

    /// Runs the forecast for every neighbourhood.
    ///
    /// - Parameters:
    ///   - data: Bundled data.
    ///   - model: Loaded Core ML model.
    /// - Throws: `TheftForecastError` if the data is malformed or Core ML fails.
    init(data: ForecastData, model: TheftModel) throws {
        self.data = data
        lastMonth = try data.lastActualMonth()
        forecast = try RecursiveForecaster.forecast(data: data, model: model, months: Self.forecastMonths)
        let population: [Double] = data.neighbourhoods.map { data.characteristic("population_k", of: $0) }
        rankings = Rankings(forecast: forecast, populationThousands: population)
    }

    /// Builds the full answer for one neighbourhood.
    ///
    /// - Parameters:
    ///   - hood: Neighbourhood index.
    ///   - how: How the query matched, shown to the user.
    ///   - patrolUnits: City-wide patrol units per day.
    /// - Returns: The prediction.
    func prediction(hood: Int, how: String, patrolUnits: Int) -> NeighbourhoodPrediction {
        let record: NeighbourhoodRecord = data.neighbourhoods[hood]
        let firstHistoryMonth: YearMonth = lastMonth.adding(months: 1 - record.history.count)
        let history: [MonthlyThefts] = record.history.enumerated().map {
            MonthlyThefts(month: firstHistoryMonth.adding(months: $0.offset), thefts: Double($0.element))
        }
        let future: [MonthlyThefts] = forecast[hood].enumerated().map {
            MonthlyThefts(month: lastMonth.adding(months: $0.offset + 1), thefts: $0.element)
        }
        let profile: NeighbourhoodProfile = NeighbourhoodProfile(
            population: Int((data.characteristic("population_k", of: record) * 1000).rounded()),
            medianIncomeThousands: data.characteristic("income_k", of: record),
            kilometresToAirport: data.characteristic("km_to_airport", of: record),
            shareDetached: data.characteristic("share_detached", of: record)
        )
        return NeighbourhoodPrediction(
            name: record.name,
            matchDescription: how,
            lastTwelveMonths: record.history.suffix(12).reduce(0, +),
            nextTwelveMonths: rankings.nextTwelve[hood],
            monthsThirteenToTwentyFour: forecast[hood].suffix(12).reduce(0, +),
            perThousandResidents: rankings.perThousand[hood],
            rankByTotal: rankings.rankByTotal[hood],
            rankPerResident: rankings.rankPerResident[hood],
            neighbourhoodCount: data.neighbourhoods.count,
            riskLevel: rankings.riskLevels[hood],
            profile: profile,
            history: history,
            forecast: future,
            patrolPlan: PatrolPlanner.plan(
                hood: hood, forecast: forecast, firstMonth: lastMonth.adding(months: 1),
                units: patrolUnits, data: data
            )
        )
    }
}
