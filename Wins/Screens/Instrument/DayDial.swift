import SwiftUI

// MARK: - Instrument: the day as a 24-hour dial
//
// Shared by the Instrument screens. The waking day is a muted arc; each win is a
// thick segment at its real time and length, with its purpose badge on the bezel.
// Won segments use the accent, open ones the primary ink, and dimmed ones the muted mark.

enum DialSegmentState { case planned, won, open, dimmed }

struct DayDial<Center: View>: View {

    let wins: [TonightWin]
    var size: CGFloat = 248
    var lineWidth: CGFloat = 14
    /// State per win id. Missing ids are `.planned`.
    var states: [Int: DialSegmentState] = [:]
    /// Optional "now" hand, in hours.
    var nowHour: Double? = nil
    var showsBadges: Bool = true
    let center: Center

    init(wins: [TonightWin],
         size: CGFloat = 248,
         lineWidth: CGFloat = 14,
         states: [Int: DialSegmentState] = [:],
         nowHour: Double? = nil,
         showsBadges: Bool = true,
         @ViewBuilder center: () -> Center) {
        self.wins = wins
        self.size = size
        self.lineWidth = lineWidth
        self.states = states
        self.nowHour = nowHour
        self.showsBadges = showsBadges
        self.center = center()
    }

    var body: some View {
        let radius = size / 2
        ZStack {
            Circle()
                .stroke(Theme.markTrack, lineWidth: lineWidth)
                .frame(width: size, height: size)
            Circle()
                .trim(from: fraction(TonightStory.wake), to: fraction(TonightStory.sleep))
                .stroke(Theme.markMuted, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: size, height: size)

            ForEach(wins) { win in
                Circle()
                    .trim(from: fraction(win.start), to: fraction(win.start + win.duration))
                    .stroke(color(for: states[win.id] ?? .planned),
                            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: size, height: size)
            }

            if showsBadges {
                ForEach(wins) { win in
                    PurposeBadge(purpose: win.purpose)
                        .opacity((states[win.id] ?? .planned) == .dimmed ? 0.45 : 1)
                        .offset(point(hour: win.start + win.duration / 2, radius: radius + 22))
                }
            }

            ForEach([0, 6, 12, 18], id: \.self) { hour in
                Text(String(format: "%02d", hour))
                    .textStyle(.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .offset(point(hour: Double(hour), radius: radius - 26))
            }

            if let nowHour {
                Capsule()
                    .fill(Theme.accent)
                    .frame(width: 3, height: lineWidth + 12)
                    .offset(y: -radius)
                    .rotationEffect(.degrees(nowHour / 24.0 * 360.0))
                    .accessibilityHidden(true)
            }

            center
        }
        .frame(width: size + 48, height: size + 48)
    }

    private func fraction(_ hour: Double) -> CGFloat { CGFloat(hour / 24.0) }

    private func color(for state: DialSegmentState) -> Color {
        switch state {
        case .planned, .open: return Theme.textPrimary
        case .won: return Theme.accent
        case .dimmed: return Theme.markMuted
        }
    }

    private func point(hour: Double, radius: CGFloat) -> CGSize {
        let angle = hour / 24.0 * 2.0 * Double.pi
        return CGSize(width: radius * CGFloat(sin(angle)), height: -radius * CGFloat(cos(angle)))
    }
}

/// Small eyebrow line with a purpose badge, used above the reason.
struct ReasonEyebrow: View {
    var text: String = "Reason to wake up"
    var purpose: Purpose = .growth

    var body: some View {
        HStack(spacing: Spacing.xs) {
            PurposeBadge(purpose: purpose)
            Text(text)
                .textStyle(.eyebrow)
                .foregroundStyle(Theme.textSecondary)
        }
    }
}
