import SwiftUI
import UIKit

// MARK: - Shared story for the round 5 variants
//
// Minimal, but alive: every element carries the user's own story.
// Calendar: day 1 was Thu 15 Oct 2026, today (day 23) is Fri 6 Nov,
// tomorrow (day 24) is Sat 7 Nov, day 40 falls on Mon 23 Nov.

/// One milestone as a moment with its own identity.
struct MilestoneMoment: Identifiable {
    /// The milestone day: 7, 21, 40, 66.
    let id: Int
    let name: String
    /// What the milestone stands for, one line in the user's voice.
    let meaning: String
    let material: MedalMaterial
    /// Earned date, nil while ahead.
    let earnedOn: String?
    /// Date it will be reached if the run continues.
    let dueOn: String
    /// The user's own numbers inside this milestone (earned only).
    let wins: Int
    let rescued: Int
    /// What this milestone rewards, shown as a mini badge.
    let rewards: Purpose

    var isEarned: Bool { earnedOn != nil }
}

enum MilestoneStory {
    static let today = 23
    static let started = "15 Oct"
    static let totalWins = 58
    static let totalRescued = 2

    static let moments: [MilestoneMoment] = [
        MilestoneMoment(id: 7, name: "First week", meaning: "The habit found its shape.",
                        material: .porcelain, earnedOn: "21 Oct", dueOn: "21 Oct", wins: 16, rescued: 0, rewards: .showingUp),
        MilestoneMoment(id: 21, name: "Three weeks", meaning: "It runs without asking.",
                        material: .pewter, earnedOn: "4 Nov", dueOn: "4 Nov", wins: 54, rescued: 2, rewards: .consistency),
        MilestoneMoment(id: 40, name: "Forty days", meaning: "Past the point of quitting.",
                        material: .graphite, earnedOn: nil, dueOn: "23 Nov", wins: 0, rescued: 0, rewards: .resilience),
        MilestoneMoment(id: 66, name: "The run", meaning: "It is who you are now.",
                        material: .platinum, earnedOn: nil, dueOn: "19 Dec", wins: 0, rescued: 0, rewards: .identity),
    ]

    /// The most recent earned milestone (the hero).
    static var latest: MilestoneMoment { moments[1] }
    /// The next milestone ahead.
    static var next: MilestoneMoment { moments[2] }

    static var daysToNext: Int { next.id - today }
    /// Progress from the last milestone (21) to the next (40).
    static var progressToNext: Double {
        Double(today - latest.id) / Double(next.id - latest.id)
    }
}

// MARK: - Light per milestone
//
// The light progresses over the 66 days like a morning: first light (amber) at 7,
// early sun (gold) at 21, daylight (cool white) at 40, full light (platinum white) at 66.
// Used only as a faint glow behind an earned medal, never on controls or text.

extension MedalMaterial {
    var light: Color {
        switch self {
        case .porcelain: return Color(uiColor: UIColor(hex: 0xE9B98C))
        case .pewter, .rescue: return Color(uiColor: UIColor(hex: 0xEBD3A0))
        case .graphite: return Color(uiColor: UIColor(hex: 0xC9D8EA))
        case .platinum: return Color(uiColor: UIColor(hex: 0xF4F7FB))
        }
    }
}

// MARK: - Tonight's story

struct TonightWin: Identifiable {
    let id: Int
    let systemImage: String
    let title: String
    let time: String
    /// Start in hours (e.g. 12.5) and duration in hours, for dials and shapes.
    let start: Double
    let duration: Double
    let purpose: Purpose
    var minutes: Int { Int((duration * 60).rounded()) }
}

enum TonightStory {
    static let weekday = "Saturday"
    static let date = "7 November"
    static let day = 24
    static let reason = "Finish the first chapter before anyone else is awake."
    /// Why the reason matters, written by the user on day 1.
    static let why = "The book you promised yourself on day 1."
    static let wake = 6.5
    static let wakeText = "6:30"
    static let sleep = 22.5
    static let sunriseText = "7:14"
    static let yesterday = "2 of 3"

    static let wins: [TonightWin] = [
        TonightWin(id: 0, systemImage: "pencil", title: "Write 500 words", time: "7:00", start: 7, duration: 0.75, purpose: .growth),
        TonightWin(id: 1, systemImage: "figure.run", title: "Run 5k by the river", time: "12:30", start: 12.5, duration: 0.75, purpose: .health),
        TonightWin(id: 2, systemImage: "phone", title: "Call Mum", time: "19:00", start: 19, duration: 0.5, purpose: .family),
    ]
}

// MARK: - Small shared pieces

/// A thin progress line: track plus filled part. Used for "toward the next milestone".
struct ProgressLine: View {
    let value: Double
    var height: CGFloat = 4
    var fill: Color = Theme.textPrimary

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(Theme.markTrack)
                Capsule()
                    .fill(fill)
                    .frame(width: max(height, proxy.size.width * CGFloat(min(max(value, 0), 1))))
            }
        }
        .frame(height: height)
        .accessibilityHidden(true)
    }
}

/// Faint light pool behind an earned medal, in the milestone's own light.
struct MilestoneGlow: View {
    let material: MedalMaterial
    let diameter: CGFloat
    var strength: Double = 0.22

    var body: some View {
        Circle()
            .fill(RadialGradient(colors: [material.light.opacity(strength), material.light.opacity(0)],
                                 center: .center,
                                 startRadius: diameter * 0.2,
                                 endRadius: diameter * 0.9))
            .frame(width: diameter * 1.8, height: diameter * 1.8)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

/// A label/value readout for instrument layouts.
struct Readout: View {
    let label: String
    let value: String
    var systemImage: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            HStack(spacing: Spacing.xxs) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .symbolRenderingMode(.monochrome)
                        .fontWeight(.semibold)
                        .imageScale(.small)
                }
                Text(label)
            }
            .textStyle(.eyebrow)
            .foregroundStyle(Theme.textSecondary)
            Text(value)
                .textStyle(.numeral)
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

/// Close or back plus an optional trailing control, aligned to the margin.
struct VariantTopBar<Trailing: View>: View {
    let leadingSymbol: String
    let leadingLabel: String
    let trailing: Trailing

    init(leadingSymbol: String, leadingLabel: String, @ViewBuilder trailing: () -> Trailing) {
        self.leadingSymbol = leadingSymbol
        self.leadingLabel = leadingLabel
        self.trailing = trailing()
    }

    var body: some View {
        HStack {
            GlassIconButton(systemImage: leadingSymbol, accessibilityText: leadingLabel)
            Spacer(minLength: Spacing.xs)
            trailing
        }
        .frame(minHeight: Layout.minTarget)
        .padding(.horizontal, Layout.margin)
        .padding(.top, Spacing.xs)
    }
}

// MARK: - Purpose badges
//
// Every element carries a mini badge that says WHY it is there.
// One size (20 pt disc, 10 pt glyph), one rendering mode (monochrome),
// tinted from this small semantic palette. Muted tints, never the action green.

enum Purpose {
    // Why a win exists
    case health, work, family, growth
    // Why a system element exists
    case firstWin, rescue
    // What a milestone rewards
    case showingUp, consistency, resilience, identity

    var symbol: String {
        switch self {
        case .health: return "heart.fill"
        case .work: return "briefcase.fill"
        case .family: return "person.2.fill"
        case .growth: return "leaf.fill"
        case .firstWin: return "sunrise.fill"
        case .rescue: return "lifepreserver.fill"
        case .showingUp: return "checkmark.seal.fill"
        case .consistency: return "repeat"
        case .resilience: return "shield.fill"
        case .identity: return "infinity"
        }
    }

    var label: String {
        switch self {
        case .health: return "Health"
        case .work: return "Work"
        case .family: return "Family"
        case .growth: return "Growth"
        case .firstWin: return "Your first win"
        case .rescue: return "Rescue"
        case .showingUp: return "Rewards showing up"
        case .consistency: return "Rewards consistency"
        case .resilience: return "Rewards resilience"
        case .identity: return "Rewards identity"
        }
    }

    var tint: Color {
        switch self {
        case .health: return Color(light: UIColor(hex: 0xB0443C), dark: UIColor(hex: 0xEF8A80))
        case .work: return Color(light: UIColor(hex: 0x2F66A8), dark: UIColor(hex: 0x82B4F0))
        case .family: return Color(light: UIColor(hex: 0x8C5E0E), dark: UIColor(hex: 0xEBC07A))
        case .growth: return Color(light: UIColor(hex: 0x5E46A8), dark: UIColor(hex: 0xB9A2F2))
        case .firstWin: return Color(light: UIColor(hex: 0x9A5A1E), dark: UIColor(hex: 0xF0B57E))
        case .rescue: return Color(light: UIColor(hex: 0x1E7470), dark: UIColor(hex: 0x6FD0C8))
        case .showingUp, .consistency, .resilience, .identity:
            return Theme.textSecondary
        }
    }
}

/// The one mini badge: 20 pt tinted disc with a 10 pt monochrome glyph.
struct PurposeBadge: View {
    let purpose: Purpose
    var size: CGFloat = 20

    var body: some View {
        Image(systemName: purpose.symbol)
            .font(.system(size: size * 0.5, weight: .bold))
            .symbolRenderingMode(.monochrome)
            .foregroundStyle(purpose.tint)
            .frame(width: size, height: size)
            .background(purpose.tint.opacity(0.16), in: Circle())
            .accessibilityLabel(purpose.label)
    }
}

/// A row icon with its purpose badge pinned to the bottom trailing corner.
struct BadgedIcon: View {
    let systemImage: String
    let purpose: Purpose
    var size: CGFloat = 40

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: size * 0.42, weight: .medium))
            .symbolRenderingMode(.monochrome)
            .foregroundStyle(Theme.textPrimary)
            .frame(width: size, height: size)
            .background(Theme.surfaceRaised, in: RoundedRectangle(cornerRadius: size * 0.3, style: .continuous))
            .overlay(alignment: .bottomTrailing) {
                PurposeBadge(purpose: purpose, size: 18)
                    .background(Theme.background, in: Circle().inset(by: -2))
                    .offset(x: 6, y: 6)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(purpose.label)
    }
}
