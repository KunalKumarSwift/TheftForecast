//  PredictionSummaryView.swift
//
//  Shows the headline numbers: neighbourhood, forecast totals, ranks, risk and profile.
//
//  Risk is shown with an icon and a text label, never colour alone, so it reads the
//  same for colour-blind users and in dark mode.

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
            LabeledContent("Next 12 months (forecast)", value: "\(whole(prediction.nextTwelveMonths)) thefts")
            LabeledContent("Months 13–24 (forecast)", value: "\(whole(prediction.monthsThirteenToTwentyFour)) thefts")
            LabeledContent("Per 1,000 residents", value: prediction.perThousandResidents.formatted(.number.precision(.fractionLength(1))))
            LabeledContent("Rank by total", value: "#\(prediction.rankByTotal) of \(prediction.neighbourhoodCount)")
            LabeledContent("Rank per resident", value: "#\(prediction.rankPerResident) of \(prediction.neighbourhoodCount)")
            LabeledContent("Risk level") { RiskBadge(level: prediction.riskLevel) }
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

/// Icon + label for a risk level.
private struct RiskBadge: View {
    let level: RiskLevel

    var body: some View {
        Label(level.rawValue, systemImage: symbol)
            .foregroundStyle(tint)
            .fontWeight(.semibold)
    }

    private var symbol: String {
        switch level {
        case .low: return "checkmark.shield"
        case .moderate: return "shield"
        case .high: return "exclamationmark.shield"
        case .veryHigh: return "exclamationmark.triangle.fill"
        }
    }

    private var tint: Color {
        switch level {
        case .low: return .green
        case .moderate: return .secondary
        case .high: return .orange
        case .veryHigh: return .red
        }
    }
}
