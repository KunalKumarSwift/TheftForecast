# Theft Forecast

An iOS app that forecasts auto thefts for any Toronto neighbourhood. Type a postal code
or a neighbourhood name and the app shows the next 24 months of thefts, how the area
ranks across the city's 158 neighbourhoods, a risk level, and a suggested patrol plan
by shift. The forecast runs entirely on the device using a Core ML model; the only network call is Apple's geocoder, used to turn a postal code
into a location.

## Screenshots

These screenshots come from the `ForecastFlowUITests` UI tests (iPhone 17 Pro Max
simulator, iOS 26.2, both tests passed). The forecast test searches for **M6A 2T9**
(Yorkdale Shopping Centre) and scrolls through the results; the risk map test opens the
second tab. Rerun the UI tests to refresh them.

| Summary | Map and neighbours | Chart |
|:---:|:---:|:---:|
| <img src="docs/screenshots/1-summary.png" width="250" alt="Forecast summary for Yorkdale-Glen Park: 91 thefts in the last 12 months, 92 forecast for the next 12, up 1 percent, risk level very high"> | <img src="docs/screenshots/2-map.png" width="250" alt="Risk meter, neighbourhood profile, and a map of Yorkdale-Glen Park with its bordering neighbourhoods shaded by risk"> | <img src="docs/screenshots/3-chart.png" width="250" alt="Comparison with bordering neighbourhoods and the monthly theft chart, actual then forecast"> |

| Patrol plan | Toronto risk map |
|:---:|:---:|
| <img src="docs/screenshots/4-patrol-plan.png" width="250" alt="Patrol units by shift as a stacked bar chart above the monthly patrol table"> | <img src="docs/screenshots/5-risk-map.png" width="250" alt="All 158 Toronto neighbourhoods coloured by risk level"> |

## Key Features

- **Postal code or name lookup.** Postal codes are geocoded with Apple's CoreLocation
  and matched to a neighbourhood boundary. Names are matched by partial or closest
  spelling. The postal code is only used to find the neighbourhood, never as model input.
- **On-device forecast.** A Core ML linear model predicts thefts month by month for
  24 months, feeding each prediction back in as history.
- **Ranks and risk.** Ranks by total thefts and per 1,000 residents, plus a risk level
  (the neighbourhood's quartile), computed the same way as the notebook's pandas code.
- **Neighbourhood profile.** 2021 census figures such as residents, median household
  income and distance to Pearson airport.
- **Risk meter and trend.** A bar split into the four risk levels shows where the
  neighbourhood sits among all 158, and an arrow shows the forecast change against the
  last 12 months.
- **Neighbourhood map.** Apple Maps shows the neighbourhood's boundary and every
  neighbourhood that shares a border with it, shaded by risk level. Tap a bordering
  neighbourhood's name to open its forecast. Borders are worked out on the device from
  the boundary outlines (shared boundary vertices).
- **Toronto risk map tab.** A second tab colours all 158 neighbourhoods by risk level on
  one map, so the risky pockets are visible at a glance. A toggle fades low and moderate
  areas to make high-risk clusters stand out. Tap any neighbourhood for its numbers and
  an **Open forecast** button that jumps to its full forecast.
- **Comparison with bordering neighbourhoods.** A bar chart of forecast thefts per 1,000
  residents for the neighbourhood and its neighbours, with the Toronto average marked.
- **Chart.** The last 3 years of actual thefts (solid) followed by the forecast (dashed).
- **Patrol plan.** Splits the city's daily patrol units (adjustable, default 200) by each
  neighbourhood's share of forecast thefts, then by night, day and evening shifts, shown
  as a stacked bar chart above the monthly table.

## Requirements

- Xcode with the iOS 17 SDK or later (Swift 6, strict concurrency)
- iOS 17.0 or later
- A network connection, for postal code lookup only

## Quick Start

```bash
git clone https://github.com/KunalKumarSwift/TheftForecast.git
cd TheftForecast
open TheftForecast.xcodeproj
```

Select the **TheftForecastApp** scheme, pick a simulator or device, and press Run. To run
on a device, set your own team under Signing & Capabilities.

From the command line:

```bash
# Build for a device
xcodebuild -project TheftForecast.xcodeproj -scheme TheftForecastApp \
  -destination 'generic/platform=iOS' -allowProvisioningUpdates build

# Run the UI test on a simulator
xcodebuild -project TheftForecast.xcodeproj -scheme TheftForecastApp \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' test

# Run the package unit tests on the Mac (includes Core ML parity tests)
cd Packages/TheftForecastKit && swift test
```

## Project Structure

```
.
├── App/                        # App entry point: wires the engine into the UI
├── Packages/TheftForecastKit/  # All features live in this Swift package
│   ├── Sources/
│   │   ├── TheftForecastInterface/  # Models, errors and protocols shared by the others
│   │   ├── TheftForecast/           # Engine: Core ML model, forecasting, ranks, patrol plan
│   │   │   └── Resources/           # AutoTheftRegressor.mlmodel, forecast_data.json
│   │   └── TheftForecastUI/         # SwiftUI screens and view model
│   └── Tests/TheftForecastTests/    # Parity tests against the notebook's output
├── UITests/                    # End-to-end UI test that captures the screenshots above
├── docs/screenshots/           # Screenshots used in this README
└── project.yml                 # XcodeGen spec for the Xcode project
```

The UI never imports the engine. Both depend only on `TheftForecastInterface`, and the
app connects them through the `TheftForecastProviding` protocol. This keeps the screens
testable with a stub and lets the engine change without touching the UI.

The Xcode project is generated from `project.yml`. To change project settings, edit
`project.yml` and run `xcodegen generate`.

## Model and Data

The model (`AutoTheftRegressor.mlmodel`) and its data (`forecast_data.json`) are exported
by the `export_coreml.ipynb` notebook, which is not part of this repository. The app
rebuilds the notebook's 20 input variables in Swift (recent monthly counts, the
12-month average, the average of the 5 nearest neighbourhoods, the month of the year,
and fixed neighbourhood characteristics). The parity tests in `TheftForecastTests`
check that the app's forecasts match the notebook's.
