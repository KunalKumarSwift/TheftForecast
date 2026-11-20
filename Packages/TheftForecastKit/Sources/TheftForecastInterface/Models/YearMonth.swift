//  YearMonth.swift
//
//  A calendar month (year + month) used as the time axis of every forecast.
//
//  The model works on whole months, so a dedicated value type avoids time-zone and
//  day-of-month pitfalls that come with `Date`. `date` exists only for Swift Charts.

import Foundation

/// A calendar month, such as August 2026.
public struct YearMonth: Sendable, Hashable, Comparable, Codable {
    /// Four-digit year.
    public let year: Int
    /// Month number, 1 (January) to 12 (December).
    public let month: Int

    /// Creates a month.
    ///
    /// - Parameters:
    ///   - year: Four-digit year.
    ///   - month: Month number, 1 to 12.
    public init(year: Int, month: Int) {
        precondition((1...12).contains(month), "month must be 1-12")
        self.year = year
        self.month = month
    }

    /// Parses the `yyyy-MM` format written by the export notebook.
    ///
    /// - Parameter text: A string such as `"2026-08"`.
    /// - Returns: The month, or `nil` if the text is not in `yyyy-MM` format.
    public static func parse(_ text: String) -> YearMonth? {
        let parts: [Substring] = text.split(separator: "-")
        guard parts.count == 2, let year = Int(parts[0]), let month = Int(parts[1]), (1...12).contains(month) else {
            return nil
        }
        return YearMonth(year: year, month: month)
    }

    /// Returns the month `count` months later (or earlier when negative).
    ///
    /// - Parameter count: Number of months to move.
    /// - Returns: The shifted month.
    public func adding(months count: Int) -> YearMonth {
        let zeroBased: Int = year * 12 + (month - 1) + count
        return YearMonth(year: zeroBased / 12, month: zeroBased % 12 + 1)
    }

    /// The first day of the month at noon UTC, for charting.
    public var date: Date {
        var calendar: Calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .gmt
        return calendar.date(from: DateComponents(year: year, month: month, day: 1, hour: 12)) ?? .distantPast
    }

    /// Short label such as `Aug 2026`, in the user's language.
    public var label: String {
        var calendar: Calendar = Calendar(identifier: .gregorian)
        // Without a locale the calendar falls back to generic symbols like "M08".
        calendar.locale = .current
        return "\(calendar.shortMonthSymbols[month - 1]) \(year)"
    }

    public static func < (lhs: YearMonth, rhs: YearMonth) -> Bool {
        (lhs.year, lhs.month) < (rhs.year, rhs.month)
    }
}
