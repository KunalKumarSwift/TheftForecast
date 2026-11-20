//  ForecastScreen.swift
//
//  The "Forecast" tab: type a postal code or name, see the neighbourhood forecast.
//
//  Its view model is owned by `TheftForecastTabs`, so the city risk map can open a
//  neighbourhood here.

import SwiftUI
import TheftForecastInterface

/// Search screen showing the auto-theft forecast for a Toronto neighbourhood.
struct ForecastScreen: View {
    @Bindable var viewModel: ForecastViewModel
    @FocusState private var isTyping: Bool

    var body: some View {
        NavigationStack {
            Form {
                searchSection
                resultSection
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("Auto Theft Forecast")
        }
    }

    private var searchSection: some View {
        Section {
            TextField("Postal code or neighbourhood", text: $viewModel.query)
                .postalCodeKeyboard()
                .autocorrectionDisabled()
                .focused($isTyping)
                .onSubmit(runSearch)
            Stepper("Patrol units in the city: \(viewModel.patrolUnits)", value: $viewModel.patrolUnits, in: 10...1000, step: 10)
            Button(action: runSearch) {
                Label("Show forecast", systemImage: "magnifyingglass")
            }
            .disabled(!viewModel.canSearch)
        } footer: {
            Text("For example M5V 2T6, M6A or Yorkdale. The postal code is only used to find your neighbourhood.")
        }
    }

    private func runSearch() {
        isTyping = false  // hide the keyboard so the results are visible
        Task { await viewModel.search() }
    }

    @ViewBuilder
    private var resultSection: some View {
        switch viewModel.state {
        case .idle:
            EmptyView()
        case .loading:
            Section { ProgressView("Forecasting with Core ML…") }
        case .failed(let message):
            Section { Label(message, systemImage: "exclamationmark.triangle").foregroundStyle(.red) }
        case .loaded(let prediction):
            PredictionSummaryView(prediction: prediction)
            mapSection(for: prediction)
            Section("Thefts per month") { TheftChartView(prediction: prediction) }
            PatrolPlanView(plan: prediction.patrolPlan)
        }
    }
}

extension ForecastScreen {
    @ViewBuilder
    private func mapSection(for prediction: NeighbourhoodPrediction) -> some View {
        Section {
            NeighbourhoodMapView(prediction: prediction, onSelect: { showNeighbourhood($0) })
                .listRowInsets(EdgeInsets())
            RiskLegendView()
            NeighbourComparisonChart(prediction: prediction)
        } header: {
            Text("Map and bordering neighbourhoods")
        } footer: {
            Text("Shading shows each neighbourhood's risk level. Tap a name on the map to see its forecast.")
        }
    }

    private func showNeighbourhood(_ name: String) {
        Task { await viewModel.show(neighbourhood: name) }
    }
}

private extension View {
    // Capital letters and a Search key on iPhone; macOS (used for `swift test`) has no such keyboard options.
    @ViewBuilder
    func postalCodeKeyboard() -> some View {
        #if os(iOS)
        self.textInputAutocapitalization(.characters).submitLabel(.search)
        #else
        self
        #endif
    }
}
