//  BorderFinder.swift
//
//  Works out which neighbourhoods share a border, from the exported boundary outlines.
//
//  Neighbouring boundaries in the city's data reuse the exact same vertices along a shared
//  edge, so two neighbourhoods border each other when they have at least two vertices in
//  common (one shared vertex is only a corner touch). This is a hash lookup over ~47,000
//  points, so it runs once with the forecast instead of shipping another table in the JSON.
//  It differs on purpose from `NeighbourhoodRecord.neighbours` (the 5 closest centres,
//  which the model uses): about a quarter of those do not actually touch.

import Foundation

/// Finds bordering neighbourhoods.
enum BorderFinder {
    private struct Vertex: Hashable {
        let x: Int
        let y: Int
    }

    /// Returns, for each neighbourhood, the indices of the neighbourhoods that share a border.
    ///
    /// - Parameter neighbourhoods: Records with boundary outlines.
    /// - Returns: `result[hood]` lists the bordering neighbourhoods, in index order.
    static func borders(of neighbourhoods: [NeighbourhoodRecord]) -> [[Int]] {
        var owners: [Vertex: Set<Int>] = [:]
        for (hood, record) in neighbourhoods.enumerated() {
            for point in record.outlines.joined() {
                // The export rounds to 5 decimals; rounding again absorbs float noise.
                owners[Vertex(x: Int((point[0] * 100_000).rounded()), y: Int((point[1] * 100_000).rounded())), default: []]
                    .insert(hood)
            }
        }
        var sharedCounts: [[Int: Int]] = Array(repeating: [:], count: neighbourhoods.count)
        for hoods in owners.values where hoods.count > 1 {
            for hood in hoods {
                for other in hoods where other != hood {
                    sharedCounts[hood][other, default: 0] += 1
                }
            }
        }
        return sharedCounts.map { counts -> [Int] in
            counts.filter { $0.value >= 2 }.keys.sorted()
        }
    }
}
