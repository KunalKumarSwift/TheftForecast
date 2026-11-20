//  TheftForecastError.swift
//
//  Every failure the forecasting feature reports to callers.
//
//  Providers map framework errors (CoreLocation, Core ML, decoding) into these cases
//  so the UI can show a clear message without knowing which framework failed.

import Foundation

/// Errors from looking up a neighbourhood or running the forecast.
public enum TheftForecastError: Error, Sendable, Equatable, LocalizedError {
    /// The postal code could not be located.
    case postalCodeNotFound(String)
    /// The postal code was found but lies outside Toronto's neighbourhoods.
    case outsideToronto(String)
    /// The text matches several neighbourhoods; the associated value lists some of them.
    case ambiguousName(String, matches: [String])
    /// The text matches no postal code or neighbourhood.
    case noMatch(String)
    /// The bundled model or data could not be loaded.
    case resourcesUnavailable(String)

    public var errorDescription: String? {
        switch self {
        case .postalCodeNotFound(let code):
            return "Could not find postal code \(code). Try a neighbourhood name, e.g. Yorkdale."
        case .outsideToronto(let code):
            return "\(code) is not inside a Toronto neighbourhood."
        case .ambiguousName(let text, let matches):
            return "'\(text)' matches several neighbourhoods: \(matches.joined(separator: ", "))"
        case .noMatch(let text):
            return "Could not match '\(text)' to a postal code or neighbourhood."
        case .resourcesUnavailable(let detail):
            return "The forecast model could not be loaded: \(detail)"
        }
    }
}
