//  PatrolPlanView.swift
//
//  Shows the 6-month patrol plan: units per day for the neighbourhood, split by shift.
//
//  One row per month with the shift split underneath, which fits a phone screen better
//  than the notebook's wide table.

import SwiftUI
import TheftForecastInterface

/// Patrol plan for the next 6 months.
struct PatrolPlanView: View {
    let plan: [PatrolPlanMonth]

    var body: some View {
        Section {
            ForEach(plan) { month in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(month.month.label).font(.headline)
                        Spacer()
                        Text("\(decimal(month.unitsPerDay, places: 2)) units/day").monospacedDigit()
                    }
                    Text("Forecast: \(decimal(month.forecastThefts, places: 1)) thefts")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    ForEach(month.shifts) { shift in
                        HStack {
                            Text(shift.shift)
                            Spacer()
                            Text(decimal(shift.units, places: 2)).monospacedDigit()
                        }
                        .font(.footnote)
                    }
                }
                .padding(.vertical, 2)
            }
        } header: {
            Text("Patrol plan")
        } footer: {
            Text("Units follow this neighbourhood's share of the city's forecast thefts, split by its time-of-day pattern.")
        }
    }

    private func decimal(_ value: Double, places: Int) -> String {
        value.formatted(.number.precision(.fractionLength(places)))
    }
}
