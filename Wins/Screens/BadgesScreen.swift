import SwiftUI

// MARK: - badges (Milestones)
//
// The collection. Earned medallions are struck metal with their date; locked ones
// are quiet discs with a lock and "in N days". Rescued days sit apart as small
// coins with a count pill. No data mark on this screen: the medallions are the object.

struct BadgesScreen: View {
    struct Milestone: Identifiable {
        /// The milestone day: 7, 21, 40 or 66.
        let id: Int
        let material: MedalMaterial
        /// Short date when earned, nil while locked.
        let earnedOn: String?
        /// Days remaining while locked.
        let daysToGo: Int
    }

    struct Sample {
        var today: Int
        var milestones: [Milestone]
        var rescues: Int

        /// Day 23 is Friday 6 Nov 2026. Day 7 was Wed 21 Oct, day 21 Wed 4 Nov.
        static let day23 = Sample(
            today: 23,
            milestones: [
                Milestone(id: 7, material: .porcelain, earnedOn: "21 Oct", daysToGo: 0),
                Milestone(id: 21, material: .pewter, earnedOn: "4 Nov", daysToGo: 0),
                Milestone(id: 40, material: .graphite, earnedOn: nil, daysToGo: 17),
                Milestone(id: 66, material: .platinum, earnedOn: nil, daysToGo: 43),
            ],
            rescues: 2
        )
    }

    var sample: Sample = .day23

    private var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: Spacing.md),
            GridItem(.flexible(), spacing: Spacing.md),
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            topBar

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Milestones")
                        .textStyle(.screenTitle)
                        .foregroundStyle(Theme.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                        .padding(.top, Spacing.lg)

                    LazyVGrid(columns: columns, spacing: Spacing.xl) {
                        ForEach(sample.milestones) { milestone in
                            cell(milestone)
                        }
                    }
                    .padding(.top, Spacing.xl)

                    Rectangle()
                        .fill(Theme.separator)
                        .frame(height: 0.5)
                        .padding(.top, Spacing.xl)

                    rescueRow
                        .padding(.top, Spacing.lg)
                }
                .padding(.bottom, Spacing.xl)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal, Layout.margin)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .screenBackground()
    }

    private var topBar: some View {
        HStack {
            GlassIconButton(systemImage: "chevron.left", accessibilityText: "Back")
            Spacer(minLength: Spacing.xs)
            Pill(
                text: "\(sample.today)/66",
                systemImage: "calendar",
                accessibilityText: "Day \(sample.today) of 66"
            )
        }
        .frame(minHeight: Layout.minTarget)
        .padding(.top, Spacing.xs)
    }

    private func cell(_ milestone: Milestone) -> some View {
        let isEarned = milestone.earnedOn != nil
        return VStack(spacing: Spacing.sm) {
            MedallionView(
                number: milestone.id,
                material: milestone.material,
                isEarned: isEarned,
                size: 132,
                litTicks: milestone.id
            )
            VStack(spacing: Spacing.xxs) {
                Text("Day \(milestone.id)")
                    .textStyle(.headline)
                    .foregroundStyle(isEarned ? Theme.textPrimary : Theme.textSecondary)
                caption(for: milestone)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText(for: milestone))
    }

    @ViewBuilder
    private func caption(for milestone: Milestone) -> some View {
        if let date = milestone.earnedOn {
            Text(date)
                .textStyle(.meta)
                .foregroundStyle(Theme.textSecondary)
        } else {
            HStack(spacing: Spacing.xxs) {
                Image(systemName: "lock.fill")
                    .symbolRenderingMode(.monochrome)
                    .fontWeight(.semibold)
                    .imageScale(.small)
                Text("in \(milestone.daysToGo) days")
            }
            .textStyle(.meta)
            .foregroundStyle(Theme.textSecondary)
        }
    }

    private func accessibilityText(for milestone: Milestone) -> String {
        if let date = milestone.earnedOn {
            return "Day \(milestone.id) milestone, earned \(date)"
        }
        return "Day \(milestone.id) milestone, locked, in \(milestone.daysToGo) days"
    }

    private var rescueRow: some View {
        HStack(spacing: Spacing.md) {
            MedallionView(
                number: 5,
                unit: "min",
                material: .rescue,
                size: 56,
                showsTicks: false
            )
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text("Rescued days")
                    .textStyle(.headline)
                    .foregroundStyle(Theme.textPrimary)
                Text("Saved in 5 minutes")
                    .textStyle(.meta)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer(minLength: Spacing.xs)
            Pill(text: "×\(sample.rescues)", accessibilityText: "\(sample.rescues) days rescued")
        }
    }
}

#Preview("Dark") {
    BadgesScreen()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    BadgesScreen()
        .preferredColorScheme(.light)
}
