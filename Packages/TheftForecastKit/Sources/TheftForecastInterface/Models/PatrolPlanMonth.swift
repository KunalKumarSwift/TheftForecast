//  PatrolPlanMonth.swift
//
//  One month of the suggested patrol plan for a neighbourhood.
//
//  Units are fractional on purpose: they express a share of the city's daily units,
//  matching the notebook's patrol table rather than rounding to whole cars.

import Foundation

/// Patrol units for one shift (night, day or evening).
public struct ShiftUnits: Sendable, Equatable, Identifiable {
    /// Shift name, for example `Night (11pm-7am)`.
    public let shift: String
    /// Patrol units per day in this shift.
    public let units: Double

    public var id: String { shift }

    /// Creates a shift allocation.
    ///
    /// - Parameters:
    ///   - shift: Shift name.
    ///   - units: Units per day in the shift.
    public init(shift: String, units: Double) {
        self.shift = shift
        self.units = units
    }
}

/// The patrol plan for one forecast month.
public struct PatrolPlanMonth: Sendable, Equatable, Identifiable {
    /// The month.
    public let month: YearMonth
    /// Forecast thefts in the neighbourhood that month.
    public let forecastThefts: Double
    /// Patrol units per day assigned to the neighbourhood.
    public let unitsPerDay: Double
    /// Units per day split across the shifts.
    public let shifts: [ShiftUnits]

    public var id: YearMonth { month }

    /// Creates a patrol month.
    ///
    /// - Parameters:
    ///   - month: The month.
    ///   - forecastThefts: Forecast thefts.
    ///   - unitsPerDay: Units per day for the neighbourhood.
    ///   - shifts: Units per shift.
    public init(month: YearMonth, forecastThefts: Double, unitsPerDay: Double, shifts: [ShiftUnits]) {
        self.month = month
        self.forecastThefts = forecastThefts
        self.unitsPerDay = unitsPerDay
        self.shifts = shifts
    }
}
