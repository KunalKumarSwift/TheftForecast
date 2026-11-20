//  RiskBadge.swift
//
//  Icon plus label for a risk level, used in the forecast summary and the city map card.
//
//  The text stays in normal ink and only the icon takes the risk colour, so the level
//  reads the same without colour and keeps full text contrast.

import SwiftUI
import TheftForecastInterface

/// Icon + label for a risk level.
struct RiskBadge: View {
    let level: RiskLevel

    // A plain HStack, not a Label: inside a Form row, Label picks up list-row icon layout
    // and made the "Risk level" row hundreds of points tall with empty space under it.
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: level.symbol).foregroundStyle(level.tint)
            Text(level.rawValue).fontWeight(.semibold).foregroundStyle(.primary)
        }
        .accessibilityElement(children: .combine)
    }
}
