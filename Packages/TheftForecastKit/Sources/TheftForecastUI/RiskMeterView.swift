//  RiskMeterView.swift
//
//  Shows where a neighbourhood sits among all of Toronto's, by thefts per resident.
//
//  A track split into the four risk quarters with a marker at the neighbourhood's rank,
//  so "rank 7 of 158" reads at a glance. More thefts is to the right, like a thermometer.

import SwiftUI
import TheftForecastInterface

/// A position marker on a four-segment risk track.
struct RiskMeterView: View {
    let rank: Int
    let count: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    HStack(spacing: 2) {
                        ForEach(RiskLevel.allCases, id: \.self) { level in
                            Rectangle().fill(level.tint)
                        }
                    }
                    .frame(height: 10)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    Capsule()
                        .fill(Color.primary)
                        .overlay(Capsule().stroke(Self.rowBackground, lineWidth: 2))
                        .frame(width: 6, height: 22)
                        .offset(x: position * (geometry.size.width - 6))
                }
                .frame(maxHeight: .infinity)
            }
            .frame(height: 22)
            HStack {
                Text("Fewer thefts per resident")
                Spacer()
                Text("More")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Rank \(rank) of \(count) Toronto neighbourhoods by thefts per resident")
    }

    // Rank 1 (most thefts) sits at the right end.
    private var position: CGFloat {
        guard count > 1 else { return 1 }
        return 1 - CGFloat(rank - 1) / CGFloat(count - 1)
    }

    // The ring separates the marker from the track; it matches the grouped-list row background.
    private static var rowBackground: Color {
        #if os(iOS)
        Color(uiColor: .secondarySystemGroupedBackground)
        #else
        Color(nsColor: .windowBackgroundColor)
        #endif
    }
}
