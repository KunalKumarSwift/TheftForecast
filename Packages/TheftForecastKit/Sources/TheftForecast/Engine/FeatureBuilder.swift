//  FeatureBuilder.swift
//
//  Builds the 20 model variables for every neighbourhood for the next month.
//
//  This is the Swift twin of `make_features` in the v4 notebook and must stay in sync
//  with it: lags, the 12-month average, the 5-neighbour 3-month average, the month on a
//  circle, then the fixed characteristics. The parity tests catch any drift.

import Foundation
import TheftForecastInterface

/// Pure function namespace that turns theft history into model inputs.
enum FeatureBuilder {
    /// Builds one input row per neighbourhood for the month after the end of `history`.
    ///
    /// - Parameters:
    ///   - history: Monthly thefts per neighbourhood (`history[hood][month]`), oldest first;
    ///     every row must have at least 12 months.
    ///   - nextMonth: The calendar month being predicted (for the seasonal variables).
    ///   - data: Characteristics and neighbour lists, in the same neighbourhood order.
    /// - Returns: One feature row per neighbourhood, in `data.featureNames` order.
    static func rows(history: [[Double]], nextMonth: YearMonth, data: ForecastData) -> [[Double]] {
        let threeMonthAverages: [Double] = history.map { mean($0.suffix(3)) }
        let angle: Double = 2 * Double.pi * Double(nextMonth.month) / 12

        return data.neighbourhoods.indices.map { hood -> [Double] in
            let past: [Double] = history[hood]
            precondition(past.count >= 12, "need 12 months of history to build lag12/roll12")
            let count: Int = past.count
            let nearby: Double = mean(data.neighbourhoods[hood].neighbours.map { threeMonthAverages[$0] })

            let historyFeatures: [Double] = [
                past[count - 1],  // lag1
                past[count - 2],  // lag2
                past[count - 3],  // lag3
                past[count - 12],  // lag12
                mean(past.suffix(12)),  // roll12
                nearby,  // near_roll3
                sin(angle),  // month_sin
                cos(angle),  // month_cos
            ]
            return historyFeatures + data.neighbourhoods[hood].characteristics
        }
    }

    private static func mean<C: Collection>(_ values: C) -> Double where C.Element == Double {
        values.reduce(0, +) / Double(values.count)
    }
}
