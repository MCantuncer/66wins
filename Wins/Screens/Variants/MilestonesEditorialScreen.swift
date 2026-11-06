import SwiftUI

// MARK: - milestones-v3 "Editorial"
//
// A magazine spread about the user's run. The latest milestone's number is set at
// dramatic scale and bleeds off the leading edge; its medal overlaps the numeral like a
// photograph on a page. A serif headline and one personal standfirst tell the story.
// Below, a contents list: every milestone with its mini "rewards" badge, date or countdown.
//
// Motion and light (spec):
// - The giant numeral parallaxes 8 pt against the medal on scroll; the medal's highlight
//   follows tilt and glows faintly in its own light (early-sun gold for 21).
// - Reduce Motion: no parallax, static highlight.

struct MilestonesEditorialScreen: View {
    private let moment = MilestoneStory.latest

    var body: some View {
        VStack(spacing: 0) {
            VariantTopBar(leadingSymbol: "chevron.left", leadingLabel: "Back") {
                Pill(text: "Issue \(MilestoneStory.today)", systemImage: "square.grid.3x3.fill",
                     accessibilityText: "Day \(MilestoneStory.today) of 66")
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    hero

                    HStack(spacing: Spacing.xs) {
                        PurposeBadge(purpose: moment.rewards)
                        Text(moment.rewards.label)
                            .textStyle(.eyebrow)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .padding(.top, Spacing.md)

                    Text("\(moment.name).")
                        .font(.system(size: 44, weight: .regular, design: .serif))
                        .tracking(-0.6)
                        .foregroundStyle(Theme.textPrimary)
                        .padding(.top, Spacing.xs)
                        .accessibilityAddTraits(.isHeader)

                    Text("Twenty-one days kept since \(MilestoneStory.started). \(moment.wins) wins, \(moment.rescued) of them saved with five minutes.")
                        .textStyle(.body)
                        .foregroundStyle(Theme.textSecondary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, Spacing.sm)

                    contents
                        .padding(.top, Spacing.xxl)
                }
                .padding(.horizontal, Layout.margin)
                .padding(.bottom, Spacing.xl)
            }
            .scrollIndicators(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .screenBackground()
    }

    // The giant numeral with the medal laid over it.
    private var hero: some View {
        ZStack(alignment: .bottomTrailing) {
            Text("\(moment.id)")
                .font(.system(size: 220, weight: .heavy).monospacedDigit())
                .tracking(-8)
                .foregroundStyle(Theme.textPrimary.opacity(0.08))
                .lineLimit(1)
                .fixedSize()
                .offset(x: -14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityHidden(true)

            ZStack {
                MilestoneGlow(material: moment.material, diameter: 170, strength: 0.28)
                MedallionView(number: moment.id, material: moment.material, size: 170, litTicks: moment.id)
            }
            .frame(width: 170, height: 170)
            .offset(y: 20)
        }
        .frame(height: 240)
        .padding(.top, Spacing.md)
    }

    private var contents: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("The run")
                .textStyle(.eyebrow)
                .foregroundStyle(Theme.textSecondary)
                .padding(.bottom, Spacing.sm)
            Rectangle().fill(Theme.textPrimary).frame(height: 1)
            ForEach(MilestoneStory.moments) { item in
                contentsLine(item)
                Rectangle().fill(Theme.separator).frame(height: 0.5)
            }
        }
    }

    private func contentsLine(_ item: MilestoneMoment) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: Spacing.md) {
            Text(String(format: "%02d", item.id))
                .font(.system(size: 28, weight: .bold).monospacedDigit())
                .tracking(-0.3)
                .foregroundStyle(item.isEarned ? Theme.textPrimary : Theme.textTertiary)
                .frame(width: 48, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.system(size: 20, weight: .regular, design: .serif))
                    .foregroundStyle(item.isEarned ? Theme.textPrimary : Theme.textSecondary)
                Text(item.meaning)
                    .textStyle(.meta)
                    .foregroundStyle(Theme.textSecondary)
            }

            Spacer(minLength: Spacing.xs)

            VStack(alignment: .trailing, spacing: Spacing.xxs) {
                PurposeBadge(purpose: item.rewards)
                Text(item.isEarned ? (item.earnedOn ?? "") : "in \(item.id - MilestoneStory.today) days")
                    .textStyle(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(.vertical, Spacing.md)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Dark") {
    MilestonesEditorialScreen().preferredColorScheme(.dark)
}

#Preview("Light") {
    MilestonesEditorialScreen().preferredColorScheme(.light)
}
