//  YearMonthTests.swift
//
//  Checks month arithmetic across year boundaries, which every forecast label relies on.

import Testing
import TheftForecastInterface

@Suite("YearMonth")
struct YearMonthTests {
    @Test("Adding months crosses years both ways")
    func adding() {
        let august: YearMonth = YearMonth(year: 2026, month: 8)

        #expect(august.adding(months: 5) == YearMonth(year: 2027, month: 1))
        #expect(august.adding(months: -8) == YearMonth(year: 2025, month: 12))
        #expect(august.adding(months: 24) == YearMonth(year: 2028, month: 8))
    }

    @Test("Parses the export format")
    func parsing() {
        #expect(YearMonth.parse("2026-08") == YearMonth(year: 2026, month: 8))
        #expect(YearMonth.parse("2026-13") == nil)
        #expect(YearMonth.parse("August") == nil)
    }
}
