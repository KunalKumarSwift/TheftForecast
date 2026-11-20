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

    var body: some View {
        Label {
            Text(level.rawValue).fontWeight(.semibold)
        } icon: {
            Image(systemName: level.symbol).foregroundStyle(level.tint)
        }
    }
}
