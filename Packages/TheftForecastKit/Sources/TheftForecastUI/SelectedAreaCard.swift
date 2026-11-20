//  SelectedAreaCard.swift
//
//  Card shown over the city map for the tapped neighbourhood.
//
//  Gives the headline numbers right on the map and a button to open the full forecast,
//  so users can scan the city and drill in without retyping a name.

import SwiftUI
import TheftForecastInterface

/// Headline numbers for a tapped neighbourhood, with a link to its forecast.
struct SelectedAreaCard: View {
    let area: NeighbourhoodArea
    let neighbourhoodCount: Int
    let onOpenForecast: @MainActor () -> Void
    let onClose: @MainActor () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(area.shortName).font(.headline)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close")
            }
            RiskBadge(level: area.riskLevel)
            HStack(spacing: 16) {
                figure("\(area.nextTwelveMonths.formatted(.number.precision(.fractionLength(0))))", caption: "thefts, next 12 months")
                figure(area.perThousandResidents.formatted(.number.precision(.fractionLength(1))), caption: "per 1,000 residents")
                figure("#\(area.rankPerResident)", caption: "of \(neighbourhoodCount) per resident")
            }
            Button(action: onOpenForecast) {
                Label("Open forecast", systemImage: "chart.line.uptrend.xyaxis")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    private func figure(_ value: String, caption: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value).font(.title3.bold()).monospacedDigit()
            Text(caption).font(.caption2).foregroundStyle(.secondary)
        }
    }
}
