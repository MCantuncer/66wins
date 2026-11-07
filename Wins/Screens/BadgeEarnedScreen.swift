import SwiftUI

// MARK: - badge-earned
//
// The moment a milestone medallion is earned. The medallion is the hero, lit
// on its own small pool of light; the copy is two words and two pills.
//
// Motion and haptic (spec, not implemented in this static design):
// - The medallion rises out of its tick in the RunStrip on the night-check
//   screen (matchedGeometryEffect, .smooth(duration: 0.6, extraBounce: 0.15)).
// - It makes one slow quarter-turn on Y as it settles; the rim ticks up to the
//   earned day polish in sequence (0.4 s).
// - One .success haptic as it lands. Nothing else plays.
// - The specular highlight then follows device tilt, gently.
// - Reduce Motion: cross-fade in, static highlight, same haptic.

struct BadgeEarnedScreen: View {
    struct Sample {
        var number: Int
        var material: MedalMaterial
        var title: String
        var earnedOn: String

        static let threeWeeks = Sample(
            number: 21,
            material: .pewter,
            title: "Three weeks",
            earnedOn: "Wed 4 Nov"
        )
    }

    var sample: Sample = .threeWeeks

    private var medalSize: CGFloat { 248 }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            Spacer(minLength: Spacing.xl)

            MedallionStage(diameter: medalSize) {
                MedallionView(
                    number: sample.number,
                    material: sample.material,
                    size: medalSize,
                    litTicks: sample.number
                )
            }

            VStack(spacing: Spacing.sm) {
                Text(sample.title)
                    .textStyle(.screenTitle)
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                HStack(spacing: Spacing.xs) {
                    Pill(
                        text: "\(sample.number) of 66",
                        systemImage: "medal",
                        accessibilityText: "Day \(sample.number) of 66 milestone"
                    )
                    Pill(
                        text: sample.earnedOn,
                        systemImage: "calendar",
                        accessibilityText: "Earned \(sample.earnedOn)"
                    )
                }
            }
            .padding(.top, Spacing.xxl)

            Spacer(minLength: Spacing.xl)

            PrimaryButton(title: "Done")
        }
        .padding(.horizontal, Layout.margin)
        .padding(.bottom, Spacing.xs)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .screenBackground()
    }

    private var topBar: some View {
        HStack {
            GlassIconButton(systemImage: "xmark", accessibilityText: "Close")
            Spacer(minLength: Spacing.xs)
            GlassIconButton(systemImage: "square.and.arrow.up", accessibilityText: "Share")
        }
        .frame(minHeight: Layout.minTarget)
        .padding(.top, Spacing.xs)
    }
}

#Preview("Dark") {
    BadgeEarnedScreen()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    BadgeEarnedScreen()
        .preferredColorScheme(.light)
}
