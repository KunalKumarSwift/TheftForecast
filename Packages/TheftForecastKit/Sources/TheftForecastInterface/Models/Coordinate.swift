//  Coordinate.swift
//
//  A latitude/longitude pair, kept free of CoreLocation so the interface target
//  has no framework dependencies beyond Foundation.

import Foundation

/// A latitude/longitude pair in degrees.
public struct Coordinate: Sendable, Equatable {
    /// Latitude in degrees.
    public let latitude: Double
    /// Longitude in degrees.
    public let longitude: Double

    /// Creates a coordinate.
    ///
    /// - Parameters:
    ///   - latitude: Latitude in degrees.
    ///   - longitude: Longitude in degrees.
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
