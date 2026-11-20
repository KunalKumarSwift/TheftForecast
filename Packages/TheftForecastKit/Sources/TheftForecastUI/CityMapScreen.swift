//  CityMapScreen.swift
//
//  The "Risk map" tab: every Toronto neighbourhood coloured by risk level.
//
//  The legend floats at the top so the colours are always explained, and a toolbar toggle
//  fades low and moderate areas so the high-risk pockets stand out on their own.

import SwiftUI
import TheftForecastInterface

/// City-wide risk map with tap-to-inspect.
struct CityMapScreen: View {
    @Bindable var viewModel: CityMapViewModel
    /// Called with a neighbourhood's full name when the user asks for its forecast.
    let onOpenForecast: @MainActor (String) -> Void

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Toronto risk map")
                .toolbarTitleDisplayMode(.inline)
                .toolbar {
                    Toggle(isOn: $viewModel.highlightsHighRisk) {
                        Label("Highlight high risk", systemImage: "exclamationmark.triangle")
                    }
                    .toggleStyle(.button)
                }
        }
        .task { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView("Forecasting every neighbourhood…")
        case .failed(let message):
            ContentUnavailableView("Map unavailable", systemImage: "map", description: Text(message))
        case .loaded(let areas):
            CityRiskMapView(
                areas: areas,
                selected: viewModel.selected,
                highlightsHighRisk: viewModel.highlightsHighRisk,
                onTap: { viewModel.select(at: $0) }
            )
            .overlay(alignment: .top) {
                RiskLegendView()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.regularMaterial, in: Capsule())
                    .padding(.top, 8)
            }
            .safeAreaInset(edge: .bottom) {
                if let area = viewModel.selected {
                    SelectedAreaCard(
                        area: area,
                        neighbourhoodCount: areas.count,
                        onOpenForecast: { onOpenForecast(area.name) },
                        onClose: { viewModel.clearSelection() }
                    )
                } else {
                    Text("Tap a neighbourhood to see its numbers")
                        .font(.footnote)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.regularMaterial, in: Capsule())
                        .padding(.bottom, 8)
                }
            }
        }
    }
}
