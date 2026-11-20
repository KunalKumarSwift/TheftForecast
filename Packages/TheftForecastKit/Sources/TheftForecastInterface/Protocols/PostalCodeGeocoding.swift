//  PostalCodeGeocoding.swift
//
//  The contract for turning a postal code into a coordinate.
//
//  A protocol so the engine can use Apple's geocoder in the app and a fixed stub in
//  tests, which keeps unit tests offline and deterministic.

import Foundation

/// Turns a postal code into a latitude and longitude.
public protocol PostalCodeGeocoding: Sendable {
    /// Looks up the centre point of a postal code.
    ///
    /// - Parameter postalCode: A normalised postal code such as `M5V 2T6` or `M5V`.
    /// - Returns: The point's coordinate.
    /// - Throws: `TheftForecastError.postalCodeNotFound` when the code cannot be located.
    func coordinate(forPostalCode postalCode: String) async throws -> Coordinate
}
