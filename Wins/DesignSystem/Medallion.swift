import SwiftUI

// MARK: - Milestone medallions
//
// The one dimensional object in the app. Struck metal discs, neutral only,
// so the accent stays reserved for actions. Earned at days 7, 21, 40, 66,
// plus a small milled "5" coin for each rescued day.
// The rim carries 66 engraved ticks; ticks up to the earned day are polished.

enum MedalMaterial {
    case porcelain   // day 7
    case pewter      // day 21
    case graphite    // day 40
    case platinum    // day 66
    case rescue      // 5-minute rescue coin

    /// Conic rim gradient, light catching the bevel.
    var rim: [Color] {
        switch self {
        case .porcelain:
            return [hex(0xF7F5F1), hex(0xC9C4BC), hex(0xEFEDE9), hex(0xB5B0A8), hex(0xF5F3EF), hex(0xCBC6BE), hex(0xF7F5F1)]
        case .pewter, .rescue:
            return [hex(0xE6E8EB), hex(0x8E939A), hex(0xD4D7DB), hex(0x767B82), hex(0xE9EBEE), hex(0x9499A0), hex(0xE6E8EB)]
        case .graphite:
            return [hex(0x74767B), hex(0x232427), hex(0x5E6065), hex(0x18191B), hex(0x7A7C80), hex(0x222326), hex(0x74767B)]
        case .platinum:
            return [hex(0xFFFFFF), hex(0xB8BCC4), hex(0xF4F5F7), hex(0xA3A8B0), hex(0xFFFFFF), hex(0xC0C4CB), hex(0xFFFFFF)]
        }
    }

    /// Radial face gradient, from highlight to shadow.
    var face: [Color] {
        switch self {
        case .porcelain: return [hex(0xFDFCFA), hex(0xE7E3DD), hex(0xCFCAC2)]
        case .pewter, .rescue: return [hex(0xF0F1F3), hex(0xC4C8CD), hex(0x9DA2A9)]
        case .graphite: return [hex(0x55575C), hex(0x2D2E31), hex(0x18191B)]
        case .platinum: return [hex(0xFFFFFF), hex(0xE3E5E9), hex(0xC4C8CF)]
        }
    }

    /// Engraved numeral color. Chosen for at least 4.5:1 against the face midtone.
    var ink: Color {
        switch self {
        case .porcelain: return hex(0x6B655C)
        case .pewter, .rescue: return hex(0x3F444B)
        case .graphite: return hex(0xD9DADD)
        case .platinum: return hex(0x4A4F57)
        }
    }

    /// Engraving highlight (1 pt offset), gives the struck look.
    var engravingHighlight: Color {
        switch self {
        case .graphite: return Color.black.opacity(0.6)
        default: return Color.white.opacity(0.75)
        }
    }

    var tickOn: Color {
        switch self {
        case .graphite: return Color.white.opacity(0.85)
        default: return Color.white.opacity(0.95)
        }
    }

    var tickOff: Color {
        switch self {
        case .graphite: return Color.black.opacity(0.45)
        default: return Color.black.opacity(0.16)
        }
    }

    private func hex(_ value: UInt32) -> Color {
        Color(uiColor: UIColor(hex: value))
    }
}

struct MedallionView: View {
    let number: Int
    var unit: String? = "days"
    var material: MedalMaterial = .pewter
    var isEarned: Bool = true
    var size: CGFloat = 132
    /// How many of the 66 rim ticks are polished (usually equals `number`).
    var litTicks: Int = 0
    /// Show the 66-tick rim engraving. Off for very small coins.
    var showsTicks: Bool = true

    var body: some View {
        Group {
            if isEarned {
                earned
            } else {
                locked
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isEarned ? "Day \(number) milestone, earned" : "Day \(number) milestone, locked")
    }

    // MARK: Earned

    private var earned: some View {
        ZStack {
            Circle()
                .fill(AngularGradient(colors: material.rim, center: .center, angle: .degrees(200)))

            Circle()
                .fill(RadialGradient(colors: material.face,
                                     center: UnitPoint(x: 0.34, y: 0.28),
                                     startRadius: 0,
                                     endRadius: size * 0.62))
                .overlay {
                    Circle().strokeBorder(Color.black.opacity(0.18), lineWidth: 1)
                }
                .padding(size * 0.075)

            if showsTicks {
                tickRing
            }

            // Soft specular sweep across the face.
            Circle()
                .fill(LinearGradient(colors: [Color.white.opacity(0.35), Color.white.opacity(0)],
                                     startPoint: .topLeading,
                                     endPoint: .center))
                .padding(size * 0.075)
                .blendMode(.softLight)

            VStack(spacing: size * 0.02) {
                Text("\(number)")
                    .font(.system(size: size * 0.34, weight: .heavy).width(.expanded).monospacedDigit())
                    .tracking(-size * 0.008)
                    .foregroundStyle(material.ink)
                    .shadow(color: material.engravingHighlight, radius: 0, x: 0, y: 1)
                if let unit {
                    Text(unit)
                        .font(.system(size: max(9, size * 0.075), weight: .semibold).width(.expanded))
                        .foregroundStyle(material.ink.opacity(0.8))
                        .shadow(color: material.engravingHighlight, radius: 0, x: 0, y: 1)
                }
            }
        }
        .compositingGroup()
        .shadow(color: Color.black.opacity(0.35), radius: size * 0.08, x: 0, y: size * 0.06)
    }

    private var tickRing: some View {
        let tickLength = size * 0.045
        let radius = size * 0.445
        return ZStack {
            ForEach(0..<66, id: \.self) { index in
                Capsule()
                    .fill(index < litTicks ? material.tickOn : material.tickOff)
                    .frame(width: size > 150 ? 1.6 : 1.1, height: tickLength)
                    .offset(y: -radius + tickLength / 2)
                    .rotationEffect(.degrees(Double(index) / 66.0 * 360.0))
            }
        }
        .frame(width: size, height: size)
    }

    // MARK: Locked

    private var locked: some View {
        ZStack {
            Circle()
                .fill(Theme.fill)
            Circle()
                .strokeBorder(Theme.separator, lineWidth: 1)
            Text("\(number)")
                .font(.system(size: size * 0.34, weight: .heavy).width(.expanded).monospacedDigit())
                .foregroundStyle(Theme.textTertiary)
        }
    }
}

#Preview("Medallions") {
    VStack(spacing: Spacing.xl) {
        HStack(spacing: Spacing.lg) {
            MedallionView(number: 7, material: .porcelain, litTicks: 7)
            MedallionView(number: 21, material: .pewter, litTicks: 21)
        }
        HStack(spacing: Spacing.lg) {
            MedallionView(number: 40, material: .graphite, isEarned: false)
            MedallionView(number: 66, material: .platinum, isEarned: false)
        }
        MedallionView(number: 5, unit: "min", material: .rescue, size: 64, showsTicks: false)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .screenBackground()
    .preferredColorScheme(.dark)
}
