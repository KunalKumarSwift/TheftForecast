//  PredictionSummaryView.swift
//
//  Shows the headline numbers: neighbourhood, forecast totals, ranks, risk and profile.
//
//  Risk is shown with an icon and a text label, never colour alone, so it reads the
//  same for colour-blind users and in dark mode. The trend line compares the forecast
//  with the last 12 actual months, and the meter places the rank among all neighbourhoods.

import SwiftUI
import TheftForecastInterface

/// Headline numbers for one neighbourhood.
struct PredictionSummaryView: View {
    let prediction: NeighbourhoodPrediction

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 4) {
                Text(prediction.name).font(.title3.bold())
                Text(prediction.matchDescription).font(.footnote).foregroundStyle(.secondary)
            }
            LabeledContent("Last 12 months", value: "\(prediction.lastTwelveMonths) thefts")
            LabeledContent("Next 12 months (forecast)") {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(whole(prediction.nextTwelveMonths)) thefts")
                    TrendLabel(previous: Double(prediction.lastTwelveMonths), next: prediction.nextTwelveMonths)
                }
            }
            LabeledContent("Months 13–24 (forecast)", value: "\(whole(prediction.monthsThirteenToTwentyFour)) thefts")
            LabeledContent("Per 1,000 residents", value: prediction.perThousandResidents.formatted(.number.precision(.fractionLength(1))))
            LabeledContent("Rank by total", value: "#\(prediction.rankByTotal) of \(prediction.neighbourhoodCount)")
            LabeledContent("Rank per resident", value: "#\(prediction.rankPerResident) of \(prediction.neighbourhoodCount)")
            LabeledContent("Risk level") { RiskBadge(level: prediction.riskLevel) }
            RiskMeterView(rank: prediction.rankPerResident, count: prediction.neighbourhoodCount)
                .padding(.vertical, 4)
        } footer: {
            Text("Rank 1 = most thefts. Risk level is the neighbourhood's quarter by forecast thefts per resident.")
        }
        Section("Neighbourhood profile") {
            LabeledContent("Residents (2021)", value: prediction.profile.population.formatted())
            LabeledContent("Median household income", value: "$\(whole(prediction.profile.medianIncomeThousands))k")
            LabeledContent("Distance to Pearson airport", value: "\(whole(prediction.profile.kilometresToAirport)) km")
            LabeledContent("Detached homes", value: prediction.profile.shareDetached.formatted(.percent.precision(.fractionLength(0))))
        }
    }

    private func whole(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0)))
    }
}

/// Arrow and percentage change from the last 12 months to the next 12.
private struct TrendLabel: View {
    let previous: Double
    let next: Double

    var body: some View {
        if previous > 0 {
            let change: Double = (next - previous) / previous
            Label(
                "\(change.formatted(.percent.precision(.fractionLength(0)).sign(strategy: .always()))) vs last 12 months",
                systemImage: abs(change) < 0.005 ? "arrow.right" : (change > 0 ? "arrow.up.right" : "arrow.down.right")
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }
}
