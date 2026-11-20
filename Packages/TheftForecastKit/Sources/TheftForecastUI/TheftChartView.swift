//  TheftChartView.swift
//
//  Line chart of the last 3 years of actual thefts followed by the 24-month forecast.
//
//  Same encoding as the notebook: one blue hue, solid for actual and dashed for forecast,
//  with a legend so the difference is not carried by dash style alone. The forecast line
//  starts at the last actual point so the two lines join without a gap.

import Charts
import SwiftUI
import TheftForecastInterface

/// Actual vs forecast monthly thefts.
struct TheftChartView: View {
    let prediction: NeighbourhoodPrediction

    var body: some View {
        Chart {
            ForEach(prediction.history) { point in
                LineMark(x: .value("Month", point.month.date), y: .value("Thefts", point.thefts), series: .value("Series", "Actual"))
                    .foregroundStyle(by: .value("Series", "Actual"))
            }
            ForEach(forecastWithJoin) { point in
                LineMark(x: .value("Month", point.month.date), y: .value("Thefts", point.thefts), series: .value("Series", "Forecast"))
                    .foregroundStyle(by: .value("Series", "Forecast"))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 4]))
            }
        }
        .chartForegroundStyleScale(["Actual": Color.blue, "Forecast": Color.blue.opacity(0.7)])
        .chartLegend(position: .top, alignment: .leading)
        .chartYAxisLabel("Thefts per month")
        .frame(height: 220)
        .accessibilityLabel("Monthly thefts: last \(prediction.history.count) months actual, then a 24-month forecast")
    }

    private var forecastWithJoin: [MonthlyThefts] {
        guard let last = prediction.history.last else { return prediction.forecast }
        return [last] + prediction.forecast
    }
}
