//  AppleGeocodingProvider.swift
//
//  Geocodes Toronto postal codes with Apple's CoreLocation geocoder.
//
//  Replaces the notebook's OpenStreetMap + Statistics Canada lookups: Apple's geocoder
//  needs no API key and works on the device. It needs a network connection and is
//  rate-limited by Apple, which is fine for one lookup per user tap. If the full code
//  is unknown, it retries with the first three characters (the FSA area).

import CoreLocation
import Foundation
import TheftForecastInterface

/// `PostalCodeGeocoding` backed by `CLGeocoder`.
struct AppleGeocodingProvider: PostalCodeGeocoding {
    /// Looks up a postal code's centre point.
    ///
    /// - Parameter postalCode: Normalised code, `A1A 1A1` or `A1A`.
    /// - Returns: The coordinate.
    /// - Throws: `TheftForecastError.postalCodeNotFound` if neither the full code nor its area is found.
    func coordinate(forPostalCode postalCode: String) async throws -> Coordinate {
        if let point = await lookUp("\(postalCode), Toronto, ON, Canada") {
            return point
        }
        let area: String = String(postalCode.prefix(3))
        if area != postalCode, let point = await lookUp("\(area), Toronto, ON, Canada") {
            return point
        }
        throw TheftForecastError.postalCodeNotFound(postalCode)
    }

    private func lookUp(_ address: String) async -> Coordinate? {
        // A fresh geocoder per call: CLGeocoder is not Sendable and allows one request at a time.
        let geocoder: CLGeocoder = CLGeocoder()
        guard let location = try? await geocoder.geocodeAddressString(address).first?.location else {
            return nil
        }
        return Coordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
}
