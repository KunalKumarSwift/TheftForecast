//  PatrolShiftChart.swift
//
//  Stacked bars of patrol units per day for each month, split by shift.
//
//  Sits above the patrol table: the chart shows the shape (which shift needs the most
//  cover, and how it moves month to month) while the table keeps the exact numbers.
//  Shift colours come in a fixed order so night is always the same colour.

import Charts
import SwiftUI
import TheftForecastInterface

/// Patrol units per day by month and shift.
struct PatrolShiftChart: View {
    let plan: [PatrolPlanMonth]
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Chart {
            ForEach(plan) { month in
                ForEach(month.shifts) { shift in
                    BarMark(
                        x: .value("Month", month.month.label),
                        y: .value("Units per day", shift.units),
                        width: .ratio(0.6)
                    )
                    .foregroundStyle(by: .value("Shift", shift.shift))
                }
            }
        }
        .chartForegroundStyleScale(domain: shiftNames, range: ShiftColors.colors(for: colorScheme))
        .chartLegend(position: .top, alignment: .leading)
        .chartYAxisLabel("Units per day")
        .chartYAxis {
            AxisMarks { _ in
                AxisGridLine().foregroundStyle(Color.secondary.opacity(0.2))
                AxisValueLabel()
            }
        }
        .frame(height: 220)
        .accessibilityLabel("Patrol units per day for the next \(plan.count) months, split by shift")
    }

    private var shiftNames: [String] {
        plan.first?.shifts.map(\.shift) ?? []
    }
}
