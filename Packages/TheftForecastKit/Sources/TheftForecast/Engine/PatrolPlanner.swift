//  PatrolPlanner.swift
//
//  Splits the city's daily patrol units across neighbourhoods and shifts.
//
//  Same rule as the notebook: a neighbourhood gets the share of units that matches its
//  share of the city's forecast thefts that month, then that is split across shifts by
//  its (citywide-blended) hour-of-day pattern exported in `shiftShares`.

import Foundation
import TheftForecastInterface

/// Builds the 6-month patrol plan for one neighbourhood.
enum PatrolPlanner {
    /// Number of months in the plan.
    static let planMonths: Int = 6

    /// Creates the patrol plan.
    ///
    /// - Parameters:
    ///   - hood: Index of the neighbourhood.
    ///   - forecast: `forecast[hood][monthIndex]` for all neighbourhoods.
    ///   - firstMonth: The first forecast month.
    ///   - units: Patrol units on duty per day across the city.
    ///   - data: Shift names and shares.
    /// - Returns: One entry per month for the next 6 months.
    static func plan(
        hood: Int, forecast: [[Double]], firstMonth: YearMonth, units: Int, data: ForecastData
    ) -> [PatrolPlanMonth] {
        (0..<planMonths).map { monthIndex -> PatrolPlanMonth in
            let cityTotal: Double = forecast.reduce(0) { $0 + $1[monthIndex] }
            let hoodThefts: Double = forecast[hood][monthIndex]
            let unitsPerDay: Double = cityTotal > 0 ? Double(units) * hoodThefts / cityTotal : 0
            let shifts: [ShiftUnits] = zip(data.shiftNames, data.neighbourhoods[hood].shiftShares).map {
                ShiftUnits(shift: $0, units: unitsPerDay * $1)
            }
            return PatrolPlanMonth(
                month: firstMonth.adding(months: monthIndex),
                forecastThefts: hoodThefts,
                unitsPerDay: unitsPerDay,
                shifts: shifts
            )
        }
    }
}
