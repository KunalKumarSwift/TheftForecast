//  NeighbourComparisonChart.swift
//
//  Bar chart comparing forecast thefts per 1,000 residents with the bordering neighbourhoods.
//
//  Per resident rather than totals, because totals mostly track population size. Bars use
//  the risk ramp (so they match the map), the searched neighbourhood's name is bold, and a
//  dashed rule marks the Toronto average for context.

import Charts
import SwiftUI
import TheftForecastInterface

/// Thefts per 1,000 residents: this neighbourhood vs its bordering ones and the city.
struct NeighbourComparisonChart: View {
    let prediction: NeighbourhoodPrediction

    var body: some View {
        Chart {
            ForEach(rows) { area in
                BarMark(
                    x: .value("Thefts per 1,000 residents", area.perThousandResidents),
                    y: .value("Neighbourhood", area.shortName),
                    height: .fixed(18)
                )
                .foregroundStyle(area.riskLevel.tint)
                .clipShape(UnevenRoundedRectangle(bottomTrailingRadius: 4, topTrailingRadius: 4))
                .annotation(position: .trailing, spacing: 4) {
                    Text(area.perThousandResidents.formatted(.number.precision(.fractionLength(1))))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            RuleMark(x: .value("Toronto average", prediction.cityPerThousandResidents))
                .foregroundStyle(Color.secondary)
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 3]))
                .annotation(position: .top, alignment: .leading, spacing: 2) {
                    Text("Toronto avg").font(.caption2).foregroundStyle(.secondary)
                }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel {
                    let name: String = value.as(String.self) ?? ""
                    Text(name).fontWeight(name == prediction.area.shortName ? .bold : .regular)
                }
            }
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisGridLine().foregroundStyle(Color.secondary.opacity(0.2))
                AxisValueLabel()
            }
        }
        .chartXAxisLabel("Forecast thefts per 1,000 residents, next 12 months")
        .frame(height: CGFloat(rows.count) * 30 + 50)
    }

    private var rows: [NeighbourhoodArea] {
        ([prediction.area] + prediction.borderingAreas).sorted { $0.perThousandResidents > $1.perThousandResidents }
    }
}
