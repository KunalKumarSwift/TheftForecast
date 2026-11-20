//  NeighbourhoodPrediction.swift
//
//  The complete answer shown for one neighbourhood: forecast, ranks, profile and patrol plan.
//
//  It mirrors the notebook's `show_prediction` output so the app and the notebook
//  can be compared line by line. All values are plain data; no behaviour.

import Foundation

/// Thefts in one month, actual or forecast.
public struct MonthlyThefts: Sendable, Equatable, Identifiable {
    /// The month.
    public let month: YearMonth
    /// Number of thefts (forecasts are fractional).
    public let thefts: Double

    public var id: YearMonth { month }

    /// Creates a monthly value.
    ///
    /// - Parameters:
    ///   - month: The month.
    ///   - thefts: Thefts in that month.
    public init(month: YearMonth, thefts: Double) {
        self.month = month
        self.thefts = thefts
    }
}

/// Which quarter of neighbourhoods this one falls in, by forecast thefts per resident.
public enum RiskLevel: String, Sendable, Equatable, CaseIterable {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
    case veryHigh = "Very high"
}

/// Census and geography facts about a neighbourhood.
public struct NeighbourhoodProfile: Sendable, Equatable {
    /// Residents (2021 census).
    public let population: Int
    /// Median household income in thousands of dollars.
    public let medianIncomeThousands: Double
    /// Distance from the neighbourhood centre to Pearson airport.
    public let kilometresToAirport: Double
    /// Single-detached houses as a share of households (0 to 1).
    public let shareDetached: Double

    /// Creates a profile.
    ///
    /// - Parameters:
    ///   - population: Residents.
    ///   - medianIncomeThousands: Median household income in $1,000s.
    ///   - kilometresToAirport: Distance to Pearson in km.
    ///   - shareDetached: Share of homes that are detached, 0 to 1.
    public init(population: Int, medianIncomeThousands: Double, kilometresToAirport: Double, shareDetached: Double) {
        self.population = population
        self.medianIncomeThousands = medianIncomeThousands
        self.kilometresToAirport = kilometresToAirport
        self.shareDetached = shareDetached
    }
}

/// Everything the app shows for one neighbourhood.
public struct NeighbourhoodPrediction: Sendable, Equatable {
    /// Neighbourhood name, for example `Yorkdale-Glen Park (31)`.
    public let name: String
    /// How the query was matched, for example `from postal code M5V 2T6`.
    public let matchDescription: String
    /// Actual thefts over the last 12 months of data.
    public let lastTwelveMonths: Int
    /// Forecast thefts over the next 12 months.
    public let nextTwelveMonths: Double
    /// Forecast thefts over months 13 to 24.
    public let monthsThirteenToTwentyFour: Double
    /// Forecast thefts over the next 12 months per 1,000 residents.
    public let perThousandResidents: Double
    /// Rank by forecast total (1 = most thefts).
    public let rankByTotal: Int
    /// Rank by forecast thefts per resident (1 = most).
    public let rankPerResident: Int
    /// Number of neighbourhoods ranked.
    public let neighbourhoodCount: Int
    /// Risk quarter by thefts per resident.
    public let riskLevel: RiskLevel
    /// Census and geography facts.
    public let profile: NeighbourhoodProfile
    /// Recent actual monthly thefts (up to 36 months).
    public let history: [MonthlyThefts]
    /// Forecast monthly thefts for the next 24 months.
    public let forecast: [MonthlyThefts]
    /// Suggested patrol units for the next 6 months.
    public let patrolPlan: [PatrolPlanMonth]
    /// This neighbourhood's outline and headline numbers, for the map.
    public let area: NeighbourhoodArea
    /// Neighbourhoods sharing a border with this one, most thefts per resident first.
    public let borderingAreas: [NeighbourhoodArea]
    /// Toronto-wide next-12-month forecast per 1,000 residents.
    public let cityPerThousandResidents: Double

    /// Creates a prediction. Values are produced by the forecasting engine.
    ///
    /// - Parameters:
    ///   - name: Neighbourhood name.
    ///   - matchDescription: How the query was matched.
    ///   - lastTwelveMonths: Actual thefts in the last 12 months.
    ///   - nextTwelveMonths: Forecast thefts, next 12 months.
    ///   - monthsThirteenToTwentyFour: Forecast thefts, months 13-24.
    ///   - perThousandResidents: Next-12-month forecast per 1,000 residents.
    ///   - rankByTotal: Rank by total forecast.
    ///   - rankPerResident: Rank by forecast per resident.
    ///   - neighbourhoodCount: Number of neighbourhoods ranked.
    ///   - riskLevel: Risk quarter.
    ///   - profile: Census and geography facts.
    ///   - history: Recent actual thefts.
    ///   - forecast: 24-month forecast.
    ///   - patrolPlan: 6-month patrol plan.
    ///   - area: Outline and headline numbers for the map.
    ///   - borderingAreas: Neighbourhoods sharing a border.
    ///   - cityPerThousandResidents: Toronto-wide forecast per 1,000 residents.
    public init(
        name: String, matchDescription: String, lastTwelveMonths: Int, nextTwelveMonths: Double,
        monthsThirteenToTwentyFour: Double, perThousandResidents: Double, rankByTotal: Int, rankPerResident: Int,
        neighbourhoodCount: Int, riskLevel: RiskLevel, profile: NeighbourhoodProfile,
        history: [MonthlyThefts], forecast: [MonthlyThefts], patrolPlan: [PatrolPlanMonth],
        area: NeighbourhoodArea, borderingAreas: [NeighbourhoodArea], cityPerThousandResidents: Double
    ) {
        self.name = name
        self.matchDescription = matchDescription
        self.lastTwelveMonths = lastTwelveMonths
        self.nextTwelveMonths = nextTwelveMonths
        self.monthsThirteenToTwentyFour = monthsThirteenToTwentyFour
        self.perThousandResidents = perThousandResidents
        self.rankByTotal = rankByTotal
        self.rankPerResident = rankPerResident
        self.neighbourhoodCount = neighbourhoodCount
        self.riskLevel = riskLevel
        self.profile = profile
        self.history = history
        self.forecast = forecast
        self.patrolPlan = patrolPlan
        self.area = area
        self.borderingAreas = borderingAreas
        self.cityPerThousandResidents = cityPerThousandResidents
    }
}
