//  RecursiveForecaster.swift
//
//  Forecasts all neighbourhoods month after month, feeding predictions back in.
//
//  Mirrors the notebook's `forecast` function: each predicted month is appended to the
//  history so the next month's lags and averages use it. All 158 neighbourhoods move
//  together because `near_roll3` needs every neighbour's latest value.

import Foundation
import TheftForecastInterface

/// Runs the month-by-month forecast with the Core ML model.
enum RecursiveForecaster {
    /// Forecasts every neighbourhood for `months` months after the last actual month.
    ///
    /// - Parameters:
    ///   - data: Bundled history, characteristics and neighbour lists.
    ///   - model: The Core ML model.
    ///   - months: How many months to forecast (the app uses 24).
    /// - Returns: `forecast[hood][monthIndex]`, where index 0 is the month after the data ends.
    /// - Throws: `TheftForecastError` if the data is malformed or Core ML fails.
    static func forecast(data: ForecastData, model: TheftModel, months: Int) throws -> [[Double]] {
        var history: [[Double]] = data.neighbourhoods.map { $0.history.map(Double.init) }
        var forecast: [[Double]] = Array(repeating: [], count: history.count)
        var month: YearMonth = try data.lastActualMonth()

        for _ in 0..<months {
            month = month.adding(months: 1)
            let rows: [[Double]] = FeatureBuilder.rows(history: history, nextMonth: month, data: data)
            let predicted: [Double] = try model.predict(rows)
            for hood in history.indices {
                history[hood].append(predicted[hood])
                forecast[hood].append(predicted[hood])
            }
        }
        return forecast
    }
}
