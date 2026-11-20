//  QueryResolver.swift
//
//  Turns the user's text (postal code or neighbourhood name) into a neighbourhood.
//
//  Same rules as `resolve_neighbourhood` in the notebook: a postal code is geocoded and
//  located by boundary; otherwise a unique partial name match wins, and a close spelling
//  match is the fallback. The postal code is only a lookup key, never a model input.

import Foundation
import TheftForecastInterface

/// Resolves a query to a neighbourhood index and a description of how it matched.
struct QueryResolver {
    private let names: [String]
    private let locator: NeighbourhoodLocator
    private let geocoder: any PostalCodeGeocoding

    /// Creates a resolver.
    ///
    /// - Parameters:
    ///   - data: Neighbourhood names and boundaries.
    ///   - geocoder: Postal-code geocoder.
    init(data: ForecastData, geocoder: any PostalCodeGeocoding) {
        names = data.neighbourhoods.map(\.name)
        locator = NeighbourhoodLocator(neighbourhoods: data.neighbourhoods)
        self.geocoder = geocoder
    }

    /// Resolves the query.
    ///
    /// - Parameter query: A postal code (`M5V 2T6`, `m5v2t6`, `M5V`) or part of a neighbourhood name.
    /// - Returns: The neighbourhood index and how it was matched.
    /// - Throws: `TheftForecastError` when nothing (or more than one name) matches.
    func resolve(_ query: String) async throws -> (index: Int, how: String) {
        let text: String = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if let postalCode = Self.normalisedPostalCode(text) {
            let point: Coordinate = try await geocoder.coordinate(forPostalCode: postalCode)
            guard let index = locator.neighbourhoodIndex(containing: point) else {
                throw TheftForecastError.outsideToronto(postalCode)
            }
            return (index, "from postal code \(postalCode)")
        }
        return try matchName(text)
    }

    /// Normalises a Canadian postal code, or returns `nil` if the text is not one.
    ///
    /// - Parameter text: User input.
    /// - Returns: `A1A 1A1` or `A1A`, upper-cased.
    static func normalisedPostalCode(_ text: String) -> String? {
        let compact: String = text.replacingOccurrences(of: " ", with: "").uppercased()
        guard compact.wholeMatch(of: /[A-Z]\d[A-Z](\d[A-Z]\d)?/) != nil else { return nil }
        return compact.count == 6 ? "\(compact.prefix(3)) \(compact.suffix(3))" : compact
    }

    private func matchName(_ text: String) throws -> (index: Int, how: String) {
        guard !text.isEmpty else { throw TheftForecastError.noMatch(text) }
        let lowered: String = text.lowercased()
        let hits: [Int] = names.indices.filter { names[$0].lowercased().contains(lowered) }
        if hits.count == 1 { return (hits[0], "matched by name") }
        if hits.count > 1 {
            throw TheftForecastError.ambiguousName(text, matches: hits.prefix(8).map { names[$0] })
        }
        // Fallback for typos, like difflib's cutoff of 0.5 in the notebook.
        let scored: [(Int, Double)] = names.indices.map { index -> (Int, Double) in
            let bareName: String = names[index].replacing(/\s*\(\d+\)$/, with: "").lowercased()
            return (index, Self.similarity(lowered, bareName))
        }
        guard let best = scored.max(by: { $0.1 < $1.1 }), best.1 >= 0.5 else {
            throw TheftForecastError.noMatch(text)
        }
        return (best.0, "closest name match to '\(text)'")
    }

    // 1 - normalised Levenshtein distance: 1 means identical, 0 means nothing in common.
    private static func similarity(_ a: String, _ b: String) -> Double {
        let left: [Character] = Array(a)
        let right: [Character] = Array(b)
        guard !left.isEmpty, !right.isEmpty else { return 0 }
        var row: [Int] = Array(0...right.count)
        for i in 1...left.count {
            var previousDiagonal: Int = row[0]
            row[0] = i
            for j in 1...right.count {
                let above: Int = row[j]
                row[j] = min(row[j] + 1, row[j - 1] + 1, previousDiagonal + (left[i - 1] == right[j - 1] ? 0 : 1))
                previousDiagonal = above
            }
        }
        return 1 - Double(row[right.count]) / Double(max(left.count, right.count))
    }
}
