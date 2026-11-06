import SwiftUI

// MARK: - tonight-v2 "Instrument"
//
// Tomorrow as a 24-hour dial, like a watch complication. The waking day (6:30 to 22:30)
// is a lit arc; each win is a thick segment at its real time and length, carrying its
// purpose glyph on the bezel. Centre: the wake time and sunrise. Below, the reason in
// serif, then precise rows: purpose badge, win, time, length.
//
// Motion and light (spec):
// - A hand sweeps from now (21:30) to the wake time when the screen opens (.smooth 0.7 s).
// - Dragging a segment snaps to 15 min with `.selection`; overlaps give `.warning`.
// - Hold to set: segments lock one by one (40 ms apart), then one `.success`.
// - Reduce Motion: no sweep; segments appear in place.

struct TonightInstrumentScreen: View {
    private let dial: CGFloat = 248

    var body: some View {
        VStack(spacing: 0) {
            VariantTopBar(leadingSymbol: "xmark", leadingLabel: "Close") {
                Pill(text: "\(TonightStory.day)/66", systemImage: "square.grid.3x3.fill",
                     accessibilityText: "Tomorrow is day \(TonightStory.day) of 66")
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    dialView
                        .frame(width: dial + 48, height: dial + 48)
                        .frame(maxWidth: .infinity)
                        .padding(.top, Spacing.sm)

                    HStack(spacing: Spacing.xs) {
                        PurposeBadge(purpose: .growth)
                        Text("Reason to wake up")
                            .textStyle(.eyebrow)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .padding(.top, Spacing.xl)

                    Text(TonightStory.reason)
                        .textStyle(.reasonCompact)
                        .foregroundStyle(Theme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, Spacing.xs)

                    VStack(spacing: 0) {
                        ForEach(TonightStory.wins) { win in
                            row(win, isFirst: win.id == 0)
                            if win.id != TonightStory.wins.count - 1 {
                                Rectangle().fill(Theme.separator).frame(height: 0.5).padding(.leading, 52)
                            }
                        }
                    }
                    .padding(.top, Spacing.lg)
                }
                .padding(.horizontal, Layout.margin)
                .padding(.bottom, Spacing.lg)
            }
            .scrollIndicators(.hidden)

            HoldToConfirmButton(title: "Hold to set tomorrow")
                .padding(.horizontal, Layout.margin)
                .padding(.top, Spacing.sm)
                .padding(.bottom, Spacing.xs)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .screenBackground()
    }

    // MARK: Dial

    private func fraction(_ hour: Double) -> CGFloat { CGFloat(hour / 24.0) }

    private var dialView: some View {
        let radius = dial / 2
        return ZStack {
            // Night track (full circle) and the waking day arc.
            Circle()
                .stroke(Theme.markTrack, lineWidth: 14)
                .frame(width: dial, height: dial)
            Circle()
                .trim(from: fraction(TonightStory.wake), to: fraction(TonightStory.sleep))
                .stroke(Theme.markMuted, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: dial, height: dial)

            // Wins as solid segments at their real time and length.
            ForEach(TonightStory.wins) { win in
                Circle()
                    .trim(from: fraction(win.start), to: fraction(win.start + win.duration))
                    .stroke(Theme.textPrimary,
                            style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: dial, height: dial)
            }

            // Purpose glyphs on the bezel, outside each segment.
            ForEach(TonightStory.wins) { win in
                PurposeBadge(purpose: win.purpose)
                    .offset(point(hour: win.start + win.duration / 2, radius: radius + 22))
            }

            // Hour marks 0, 6, 12, 18.
            ForEach([0, 6, 12, 18], id: \.self) { hour in
                Text(String(format: "%02d", hour))
                    .textStyle(.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .offset(point(hour: Double(hour), radius: radius - 26))
            }

            // Centre: wake time, sunrise.
            VStack(spacing: Spacing.xxs) {
                HStack(spacing: Spacing.xxs) {
                    Image(systemName: "alarm.fill")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Wake")
                        .textStyle(.eyebrow)
                }
                .foregroundStyle(Theme.textSecondary)
                Text(TonightStory.wakeText)
                    .font(.system(size: 56, weight: .bold).monospacedDigit())
                    .tracking(-0.6)
                    .foregroundStyle(Theme.textPrimary)
                HStack(spacing: Spacing.xxs) {
                    Image(systemName: "sunrise.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Purpose.firstWin.tint)
                    Text("Sunrise \(TonightStory.sunriseText)")
                        .textStyle(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .accessibilityElement(children: .combine)
        }
    }

    private func point(hour: Double, radius: CGFloat) -> CGSize {
        let angle = hour / 24.0 * 2.0 * Double.pi
        return CGSize(width: radius * CGFloat(sin(angle)), height: -radius * CGFloat(cos(angle)))
    }

    // MARK: Rows

    private func row(_ win: TonightWin, isFirst: Bool) -> some View {
        HStack(spacing: Spacing.md) {
            BadgedIcon(systemImage: win.systemImage, purpose: win.purpose, size: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(win.title)
                    .textStyle(.headline)
                    .foregroundStyle(Theme.textPrimary)
                if isFirst {
                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: Purpose.firstWin.symbol)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Purpose.firstWin.tint)
                        Text(Purpose.firstWin.label)
                            .textStyle(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }
            Spacer(minLength: Spacing.xs)
            VStack(alignment: .trailing, spacing: 2) {
                Text(win.time)
                    .textStyle(.meta)
                    .foregroundStyle(Theme.textPrimary)
                Text("\(win.minutes) min")
                    .textStyle(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .frame(minHeight: 60)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Dark") {
    TonightInstrumentScreen().preferredColorScheme(.dark)
}

#Preview("Light") {
    TonightInstrumentScreen().preferredColorScheme(.light)
}
