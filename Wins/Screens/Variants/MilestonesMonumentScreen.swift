import SwiftUI

// MARK: - milestones-v1 "Monument"
//
// One huge object: the latest earned medal, lit by its own light (pewter = early-sun gold).
// It is a page in a paged showcase (dots show 7 · 21 · 40 · 66); swiping moves the light.
// Under it: its name, what it stands for, and the user's own numbers inside it.
// At the bottom, the next milestone is within reach: progress, days to go, what it rewards.
//
// Motion and light (spec):
// - The specular highlight follows device tilt (max 6°); rim ticks catch it in sequence.
// - Earned medals glow faintly: the light pool breathes 0.18 → 0.24 over 4 s, once per visit.
// - Paging: matchedGeometry on the medal, .smooth(0.5); the light cross-fades to the next
//   milestone's colour. `.selection` haptic per page. Reduce Motion: cross-fade, static light.

struct MilestonesMonumentScreen: View {
    private let moment = MilestoneStory.latest
    private let next = MilestoneStory.next
    private let medalSize: CGFloat = 270

    var body: some View {
        VStack(spacing: 0) {
            VariantTopBar(leadingSymbol: "chevron.left", leadingLabel: "Back") {
                Pill(text: "\(MilestoneStory.today)/66", systemImage: "square.grid.3x3.fill",
                     accessibilityText: "Day \(MilestoneStory.today) of 66")
            }

            pageDots
                .padding(.top, Spacing.md)

            // The glow sits in a background so its 1.8x pool never widens the layout.
            MedallionView(number: moment.id, material: moment.material, size: medalSize, litTicks: moment.id)
                .background {
                    MilestoneGlow(material: moment.material, diameter: medalSize, strength: 0.24)
                }
                .frame(maxWidth: .infinity)
                .frame(height: medalSize + Spacing.xl)
            .padding(.top, Spacing.lg)

            VStack(spacing: Spacing.xs) {
                HStack(spacing: Spacing.xs) {
                    PurposeBadge(purpose: moment.rewards)
                    Text(moment.name)
                        .textStyle(.screenTitle)
                        .foregroundStyle(Theme.textPrimary)
                }
                .accessibilityElement(children: .combine)
                Text(moment.meaning)
                    .italic()
                    .textStyle(.reasonCompact)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, Spacing.md)

            HStack(spacing: Spacing.xs) {
                Pill(text: "\(moment.wins)", systemImage: "checkmark.circle.fill", accessibilityText: "\(moment.wins) wins")
                Pill(text: "\(moment.rescued)", systemImage: "lifepreserver.fill", accessibilityText: "\(moment.rescued) rescued days")
                Pill(text: "since \(MilestoneStory.started)", systemImage: "flag.fill", accessibilityText: "Run started \(MilestoneStory.started)")
            }
            .padding(.top, Spacing.lg)

            Spacer(minLength: Spacing.lg)

            nextCard
                .padding(.horizontal, Layout.margin)
                .padding(.bottom, Spacing.xs)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .screenBackground()
    }

    private var pageDots: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(MilestoneStory.moments) { item in
                Capsule()
                    .fill(item.id == moment.id ? Theme.textPrimary : (item.isEarned ? Theme.textSecondary : Theme.markMuted))
                    .frame(width: item.id == moment.id ? 20 : 6, height: 6)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Milestone 2 of 4")
    }

    private var nextCard: some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                Circle().fill(Theme.fill)
                Circle().strokeBorder(Theme.separator, lineWidth: 1)
                Text("\(next.id)")
                    .font(.system(size: 20, weight: .bold).monospacedDigit())
                    .foregroundStyle(Theme.textSecondary)
            }
            .frame(width: 56, height: 56)
            .overlay(alignment: .bottomTrailing) {
                PurposeBadge(purpose: next.rewards)
                    .background(Theme.surface, in: Circle().inset(by: -2))
                    .offset(x: 4, y: 4)
            }

            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack(alignment: .firstTextBaseline) {
                    Text(next.name)
                        .textStyle(.headline)
                        .foregroundStyle(Theme.textPrimary)
                    Spacer(minLength: Spacing.xs)
                    Text("\(MilestoneStory.daysToNext) days")
                        .textStyle(.meta)
                        .foregroundStyle(Theme.textSecondary)
                }
                ProgressLine(value: MilestoneStory.progressToNext)
                Text(next.meaning)
                    .textStyle(.meta)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(Spacing.md)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

#Preview("Dark") {
    MilestonesMonumentScreen().preferredColorScheme(.dark)
}

#Preview("Light") {
    MilestonesMonumentScreen().preferredColorScheme(.light)
}
