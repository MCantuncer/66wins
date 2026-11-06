import SwiftUI
import UIKit

// MARK: - 66wins color system
//
// Dark is the primary look. Every token resolves at runtime from the trait
// collection, so light mode and Increased Contrast come for free.
// Rule: one accent (`Theme.accent`), used only for the single primary action
// and for "won" state. Everything else is neutral. Medal metals live in
// `MedalMaterial` and are physical colors, not theme colors.

extension UIColor {
    /// 0xRRGGBB hex helper.
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255
        let g = CGFloat((hex >> 8) & 0xFF) / 255
        let b = CGFloat(hex & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}

extension Color {
    /// Dynamic color with light and dark values, plus optional Increased Contrast values.
    init(light: UIColor, dark: UIColor, lightHighContrast: UIColor? = nil, darkHighContrast: UIColor? = nil) {
        self.init(uiColor: UIColor { traits in
            let isDark = traits.userInterfaceStyle == .dark
            let isHigh = traits.accessibilityContrast == .high
            if isDark {
                if isHigh, let darkHighContrast { return darkHighContrast }
                return dark
            } else {
                if isHigh, let lightHighContrast { return lightHighContrast }
                return light
            }
        })
    }
}

enum Theme {
    // MARK: Surfaces (layered, dark-first)

    /// Screen background. Near-black in dark, warm paper in light.
    static let background = Color(light: UIColor(hex: 0xF5F3EE), dark: UIColor(hex: 0x050506))
    /// First raised layer: rows, tiles.
    static let surface = Color(light: UIColor(hex: 0xFFFFFF), dark: UIColor(hex: 0x111113))
    /// Second raised layer: icon tiles, pressed rows.
    static let surfaceRaised = Color(light: UIColor(hex: 0xECE9E3), dark: UIColor(hex: 0x1C1C1F))
    /// Pill and chip fill.
    static let fill = Color(
        light: UIColor(white: 0, alpha: 0.06),
        dark: UIColor(white: 1, alpha: 0.10),
        lightHighContrast: UIColor(white: 0, alpha: 0.12),
        darkHighContrast: UIColor(white: 1, alpha: 0.18)
    )
    /// Hairline separators.
    static let separator = Color(
        light: UIColor(white: 0, alpha: 0.12),
        dark: UIColor(white: 1, alpha: 0.12),
        lightHighContrast: UIColor(white: 0, alpha: 0.30),
        darkHighContrast: UIColor(white: 1, alpha: 0.30)
    )

    // MARK: Text

    /// Primary text: 18:1 on background in dark, 17:1 in light.
    static let textPrimary = Color(light: UIColor(hex: 0x111113), dark: UIColor(hex: 0xF5F5F7))
    /// Secondary text: about 7.6:1 dark, 6.1:1 light. Safe for body sizes.
    static let textSecondary = Color(
        light: UIColor(hex: 0x5E5E66),
        dark: UIColor(hex: 0xA1A1A8),
        lightHighContrast: UIColor(hex: 0x3A3A40),
        darkHighContrast: UIColor(hex: 0xC8C8CE)
    )
    /// Tertiary: locked, future, disabled. Not for text under 17 pt.
    static let textTertiary = Color(
        light: UIColor(hex: 0x9A9AA2),
        dark: UIColor(hex: 0x5C5C64),
        lightHighContrast: UIColor(hex: 0x6E6E76),
        darkHighContrast: UIColor(hex: 0x8A8A92)
    )

    // MARK: The one accent

    /// "Won" green. Used for the primary action tint and won checkmarks only.
    static let accent = Color(
        light: UIColor(hex: 0x13744C),
        dark: UIColor(hex: 0x2FA36F),
        lightHighContrast: UIColor(hex: 0x0B5A39),
        darkHighContrast: UIColor(hex: 0x4CC38A)
    )
    /// Solid fill behind white text (white on this is at least 5:1 in both modes).
    static let accentFill = Color(light: UIColor(hex: 0x13744C), dark: UIColor(hex: 0x187A51))
    /// Text and icons on the accent.
    static let onAccent = Color.white

    // MARK: Data marks (day shape, 66-day run)

    static let markFilled = textPrimary
    static let markMuted = Color(light: UIColor(white: 0, alpha: 0.22), dark: UIColor(white: 1, alpha: 0.24))
    static let markTrack = Color(light: UIColor(white: 0, alpha: 0.10), dark: UIColor(white: 1, alpha: 0.10))
}

// MARK: - Screen background

extension View {
    /// Full-bleed themed background. Use on every screen's root.
    func screenBackground() -> some View {
        background {
            Theme.background.ignoresSafeArea()
        }
    }
}
