//  ChartColors.swift
//
//  The colours every map and chart in the app share, so one risk level always looks the same.
//
//  Risk is an ordered scale, so it uses one hue stepped light (low) to dark (very high)
//  rather than traffic-light colours; the ramp was checked for colour-blind separation and
//  contrast on both light and dark backgrounds. Every use is paired with an icon or label.
//  Patrol shifts are categories, so they take the first three slots of a fixed categorical
//  palette, with darker-background steps chosen for dark mode.

import SwiftUI
import TheftForecastInterface

extension RiskLevel {
    /// The risk level's step on the risk colour ramp.
    var tint: Color {
        switch self {
        case .low: return Color(hex: 0xF0A07A)
        case .moderate: return Color(hex: 0xE2703F)
        case .high: return Color(hex: 0xC24A22)
        case .veryHigh: return Color(hex: 0x932F12)
        }
    }

    /// SF Symbol shown next to the risk level.
    var symbol: String {
        switch self {
        case .low: return "checkmark.shield"
        case .moderate: return "shield"
        case .high: return "exclamationmark.shield"
        case .veryHigh: return "exclamationmark.triangle.fill"
        }
    }
}

/// Colours for the patrol shifts, in shift order.
enum ShiftColors {
    /// Returns one colour per shift for the current appearance.
    ///
    /// - Parameter scheme: Light or dark mode.
    /// - Returns: Night, day and evening colours.
    static func colors(for scheme: ColorScheme) -> [Color] {
        scheme == .dark
            ? [Color(hex: 0x3987E5), Color(hex: 0xD95926), Color(hex: 0x199E70)]
            : [Color(hex: 0x2A78D6), Color(hex: 0xEB6834), Color(hex: 0x1BAF7A)]
    }
}

extension Color {
    /// Creates an opaque colour from a `0xRRGGBB` value.
    ///
    /// - Parameter hex: The colour, for example `0x2A78D6`.
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
