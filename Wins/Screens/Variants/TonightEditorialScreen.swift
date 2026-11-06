import SwiftUI

// MARK: - tonight-v3 "Editorial"
//
// Tomorrow as the front page of the user's own paper. The weekday is the masthead in
// New York at display scale; the reason is the lead, set as a pull quote with a heavy
// rule; the wins are a numbered running order, each with its purpose badge and time.
//
// Motion and light (spec):
// - On hold, the running order ticks in from 01 to 03 (60 ms apart, .snappy), then the
//   masthead's date line changes to "Set · sleep well" with one `.success` haptic.
// - Reduce Motion: cross-fade only.

struct TonightEditorialScreen: View {
    var body: some View {
        VStack(spacing: 0) {
            VariantTopBar(leadingSymbol: "xmark", leadingLabel: "Close") {
                Pill(text: "Day \(TonightStory.day)", systemImage: "square.grid.3x3.fill",
                     accessibilityText: "Tomorrow is day \(TonightStory.day) of 66")
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    masthead
                        .padding(.top, Spacing.lg)

                    pullQuote
                        .padding(.top, Spacing.xl)

                    runningOrder
                        .padding(.top, Spacing.xxl)
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

    private var masthead: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(TonightStory.weekday)
                .font(.system(size: 64, weight: .regular, design: .serif))
                .tracking(-1.2)
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .accessibilityAddTraits(.isHeader)
            HStack(spacing: Spacing.sm) {
                Text(TonightStory.date)
                HStack(spacing: Spacing.xxs) {
                    Image(systemName: "alarm.fill")
                        .font(.system(size: 11, weight: .semibold))
                    Text(TonightStory.wakeText)
                }
                HStack(spacing: Spacing.xxs) {
                    Image(systemName: "sunrise.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Purpose.firstWin.tint)
                    Text(TonightStory.sunriseText)
                }
            }
            .textStyle(.meta)
            .foregroundStyle(Theme.textSecondary)
            Rectangle().fill(Theme.textPrimary).frame(height: 2).padding(.top, Spacing.sm)
        }
    }

    private var pullQuote: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            Rectangle()
                .fill(Theme.textPrimary)
                .frame(width: 3)
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(TonightStory.reason)
                    .italic()
                    .font(.system(size: 30, weight: .regular, design: .serif))
                    .tracking(-0.3)
                    .lineSpacing(4)
                    .foregroundStyle(Theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: Spacing.xs) {
                    PurposeBadge(purpose: .growth)
                    Text(TonightStory.why)
                        .textStyle(.meta)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .combine)
    }

    private var runningOrder: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Running order")
                Spacer()
                HStack(spacing: Spacing.xxs) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 11, weight: .semibold))
                    Text("Yesterday \(TonightStory.yesterday)")
                }
            }
            .textStyle(.eyebrow)
            .foregroundStyle(Theme.textSecondary)
            .padding(.bottom, Spacing.sm)

            Rectangle().fill(Theme.separator).frame(height: 0.5)

            ForEach(TonightStory.wins) { win in
                HStack(alignment: .firstTextBaseline, spacing: Spacing.md) {
                    Text(String(format: "%02d", win.id + 1))
                        .font(.system(size: 34, weight: .bold).monospacedDigit())
                        .tracking(-0.3)
                        .foregroundStyle(win.id == 0 ? Theme.textPrimary : Theme.textTertiary)
                        .frame(width: 52, alignment: .leading)
                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text(win.title)
                            .textStyle(.headline)
                            .foregroundStyle(Theme.textPrimary)
                        HStack(spacing: Spacing.xs) {
                            PurposeBadge(purpose: win.purpose, size: 18)
                            if win.id == 0 {
                                PurposeBadge(purpose: .firstWin, size: 18)
                            }
                            Text("\(win.time) · \(win.minutes) min")
                                .textStyle(.meta)
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                    Spacer(minLength: 0)
                }
                .padding(.vertical, Spacing.md)
                .accessibilityElement(children: .combine)

                Rectangle().fill(Theme.separator).frame(height: 0.5)
            }
        }
    }
}

#Preview("Dark") {
    TonightEditorialScreen().preferredColorScheme(.dark)
}

#Preview("Light") {
    TonightEditorialScreen().preferredColorScheme(.light)
}
