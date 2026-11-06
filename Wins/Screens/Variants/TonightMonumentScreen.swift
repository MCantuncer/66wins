import SwiftUI

// MARK: - tonight-v1 "Monument"
//
// One huge object: the reason to wake up, set as a monument in New York at display scale.
// Tomorrow's first light rises behind it from the bottom edge (warm, faint), the same
// light the next milestone will be lit with. Under it, only the first win, tagged as
// "your first win", and the rest folded into one chip. One hold-to-set action.
//
// Motion and light (spec):
// - While holding, the first light brightens with the sweep (0 → 100 % over 0.6 s).
// - On success: `.success` haptic, the reason settles 8 pt up, the light dims to night.
// - Reduce Motion: no light movement, cross-fade only.

struct TonightMonumentScreen: View {
    private let first = TonightStory.wins[0]

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tomorrow's first light, rising from below.
            RadialGradient(colors: [MedalMaterial.porcelain.light.opacity(0.22), MedalMaterial.porcelain.light.opacity(0)],
                           center: .bottom, startRadius: 20, endRadius: 520)
                .ignoresSafeArea()
                .allowsHitTesting(false)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 0) {
                VariantTopBar(leadingSymbol: "xmark", leadingLabel: "Close") {
                    Pill(text: "Day \(TonightStory.day)", systemImage: "square.grid.3x3.fill",
                         accessibilityText: "Tomorrow is day \(TonightStory.day) of 66")
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text("Tomorrow, \(TonightStory.weekday)")
                        .textStyle(.eyebrow)
                        .foregroundStyle(Theme.textSecondary)

                    Text(TonightStory.reason)
                        .font(.system(size: 50, weight: .regular, design: .serif))
                        .tracking(-0.8)
                        .lineSpacing(2)
                        .foregroundStyle(Theme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .minimumScaleFactor(0.8)
                        .padding(.top, Spacing.md)
                        .accessibilityAddTraits(.isHeader)

                    HStack(spacing: Spacing.xs) {
                        PurposeBadge(purpose: .growth)
                        Text(TonightStory.why)
                            .italic()
                            .textStyle(.body)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .padding(.top, Spacing.md)

                    Spacer(minLength: Spacing.xl)

                    firstWin

                    HStack(spacing: Spacing.xs) {
                        Pill(text: TonightStory.wakeText, systemImage: "alarm", accessibilityText: "Alarm \(TonightStory.wakeText)")
                        ForEach(TonightStory.wins.dropFirst()) { win in
                            HStack(spacing: Spacing.xxs) {
                                Image(systemName: win.purpose.symbol)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(win.purpose.tint)
                                Text(win.time)
                                    .textStyle(.pill)
                                    .foregroundStyle(Theme.textPrimary)
                            }
                            .padding(.horizontal, Spacing.sm)
                            .frame(minHeight: 28)
                            .background(Theme.fill, in: Capsule())
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("\(win.title), \(win.time), \(win.purpose.label)")
                        }
                    }
                    .padding(.top, Spacing.md)

                    HoldToConfirmButton(title: "Hold to set tomorrow")
                        .padding(.top, Spacing.xl)
                        .padding(.bottom, Spacing.xs)
                }
                .padding(.horizontal, Layout.margin)
                .padding(.top, Spacing.xxl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .screenBackground()
    }

    private var firstWin: some View {
        HStack(spacing: Spacing.md) {
            BadgedIcon(systemImage: first.systemImage, purpose: .firstWin, size: 52)
            VStack(alignment: .leading, spacing: 2) {
                Text(first.title)
                    .textStyle(.focus)
                    .foregroundStyle(Theme.textPrimary)
                HStack(spacing: Spacing.xs) {
                    Text("\(first.time) · \(first.minutes) min")
                        .textStyle(.meta)
                        .foregroundStyle(Theme.textSecondary)
                    PurposeBadge(purpose: first.purpose, size: 18)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview("Dark") {
    TonightMonumentScreen().preferredColorScheme(.dark)
}

#Preview("Light") {
    TonightMonumentScreen().preferredColorScheme(.light)
}
