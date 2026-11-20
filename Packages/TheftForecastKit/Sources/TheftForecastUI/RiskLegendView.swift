//  RiskLegendView.swift
//
//  Legend for the risk colour ramp, shown under the map and the comparison chart.
//
//  Each swatch carries its label, so the map's shading never relies on colour alone.

import SwiftUI
import TheftForecastInterface

/// Swatches for the four risk levels, low to very high.
struct RiskLegendView: View {
    var body: some View {
        HStack(spacing: 12) {
            ForEach(RiskLevel.allCases, id: \.self) { level in
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(level.tint)
                        .frame(width: 14, height: 10)
                    Text(level.rawValue)
                }
            }
        }
        .font(.caption2)
        .foregroundStyle(.secondary)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Risk colours from low, lightest, to very high, darkest")
    }
}
