import SwiftUI

// MARK: - milestones-v2 "Instrument"
//
// The 66-day run as a watch face. 66 ticks around a dial; saved days are lit and the
// saved arc carries the one accent gradient (it means "won"). Each milestone sits on
// the bezel at its day, as a small medal in its own metal, with a mini badge for what
// it rewards. Centre: today's count and the distance to the next milestone.
// Below: precise readouts of the user's own run, then each milestone as a line.
//
// Motion and light (spec):
// - On open the saved arc sweeps from day 1 to today (.smooth 0.8 s); today's tick pulses
//   once. Earned bezel medals catch light with device tilt. `.selection` haptic when a
//   bezel medal is focused. Reduce Motion: arc appears complete, no pulse.

struct MilestonesInstrumentScreen: View {
    private let dial: CGFloat = 300
    private let today = MilestoneStory.today

    var body: some View {
        VStack(spacing: 0) {
            VariantTopBar(leadingSymbol: "chevron.left", leadingLabel: "Back") {
                GlassIconButton(systemImage: "square.and.arrow.up", accessibilityText: "Share")
            }

            ScrollView {
                VStack(spacing: 0) {
                    dialView
                        .frame(width: dial + 40, height: dial + 40)
                        .padding(.top, Spacing.md)

                    readouts
                        .padding(.top, Spacing.xl)

                    VStack(spacing: 0) {
                        ForEach(MilestoneStory.moments) { item in
                            milestoneLine(item)
                            if item.id != 66 {
                                Rectangle().fill(Theme.separator).frame(height: 0.5).padding(.leading, 56)
                            }
                        }
                    }
                    .padding(.top, Spacing.xl)
                }
                .padding(.horizontal, Layout.margin)
                .padding(.bottom, Spacing.xl)
            }
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .screenBackground()
    }

    // MARK: Dial

    private var dialView: some View {
        let radius = dial / 2
        return ZStack {
            // Saved arc, the one accent gradient.
            Circle()
                .trim(from: 0, to: CGFloat(today) / 66.0)
                .stroke(
                    AngularGradient(colors: [Theme.accent.opacity(0.25), Theme.accent],
                                    center: .center,
                                    startAngle: .degrees(0),
                                    endAngle: .degrees(360.0 * Double(today) / 66.0)),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: dial - 36, height: dial - 36)

            // 66 day ticks.
            ForEach(1...66, id: \.self) { day in
                Capsule()
                    .fill(day <= today ? Theme.textPrimary : Theme.markMuted)
                    .frame(width: day == today ? 2.5 : 1.5, height: day == today ? 18 : 10)
                    .offset(y: -radius + (day == today ? 9 : 5))
                    .rotationEffect(.degrees(Double(day - 1) / 66.0 * 360.0))
            }

            // Milestones on the bezel.
            ForEach(MilestoneStory.moments) { item in
                bezelMedal(item)
                    .offset(x: offset(for: item.id, radius: radius + 6).width,
                            y: offset(for: item.id, radius: radius + 6).height)
            }

            // Centre readout.
            VStack(spacing: Spacing.xxs) {
                Text("\(today)")
                    .textStyle(.numeralHero)
                    .foregroundStyle(Theme.textPrimary)
                Text("of 66 days")
                    .textStyle(.meta)
                    .foregroundStyle(Theme.textSecondary)
                HStack(spacing: Spacing.xxs) {
                    PurposeBadge(purpose: MilestoneStory.next.rewards, size: 18)
                    Text("\(MilestoneStory.daysToNext) to \(MilestoneStory.next.name)")
                        .textStyle(.pill)
                        .foregroundStyle(Theme.textPrimary)
                }
                .padding(.top, Spacing.xs)
            }
            .accessibilityElement(children: .combine)
        }
    }

    private func offset(for day: Int, radius: CGFloat) -> CGSize {
        let angle = Double(day - 1) / 66.0 * 2.0 * Double.pi
        return CGSize(width: radius * CGFloat(sin(angle)), height: -radius * CGFloat(cos(angle)))
    }

    @ViewBuilder
    private func bezelMedal(_ item: MilestoneMoment) -> some View {
        if item.isEarned {
            ZStack {
                MilestoneGlow(material: item.material, diameter: 40, strength: 0.35)
                MedallionView(number: item.id, unit: nil, material: item.material, size: 40, showsTicks: false)
            }
            .frame(width: 40, height: 40)
        } else {
            ZStack {
                Circle().fill(Theme.background)
                Circle().strokeBorder(Theme.textTertiary, lineWidth: 1)
                Text("\(item.id)")
                    .font(.system(size: 13, weight: .bold).monospacedDigit())
                    .foregroundStyle(Theme.textSecondary)
            }
            .frame(width: 34, height: 34)
            .accessibilityLabel("Day \(item.id), \(item.name), ahead")
        }
    }

    // MARK: Readouts

    private var readouts: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            Readout(label: "Wins", value: "\(MilestoneStory.totalWins)", systemImage: "checkmark.circle.fill")
            Readout(label: "Rescued", value: "\(MilestoneStory.totalRescued)", systemImage: "lifepreserver.fill")
            Readout(label: "Since", value: MilestoneStory.started, systemImage: "flag.fill")
        }
    }

    // MARK: Milestone lines

    private func milestoneLine(_ item: MilestoneMoment) -> some View {
        HStack(spacing: Spacing.md) {
            ZStack(alignment: .bottomTrailing) {
                if item.isEarned {
                    MedallionView(number: item.id, unit: nil, material: item.material, size: 40, showsTicks: false)
                } else {
                    ZStack {
                        Circle().fill(Theme.fill)
                        Text("\(item.id)")
                            .font(.system(size: 13, weight: .bold).monospacedDigit())
                            .foregroundStyle(Theme.textTertiary)
                    }
                    .frame(width: 40, height: 40)
                }
                PurposeBadge(purpose: item.rewards, size: 18)
                    .background(Theme.background, in: Circle().inset(by: -2))
                    .offset(x: 5, y: 5)
            }
            .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .textStyle(.headline)
                    .foregroundStyle(item.isEarned ? Theme.textPrimary : Theme.textSecondary)
                Text(item.meaning)
                    .textStyle(.meta)
                    .foregroundStyle(Theme.textSecondary)
            }

            Spacer(minLength: Spacing.xs)

            VStack(alignment: .trailing, spacing: 2) {
                if item.isEarned {
                    Text(item.earnedOn ?? "")
                        .textStyle(.meta)
                        .foregroundStyle(Theme.textPrimary)
                    Text("\(item.wins) wins")
                        .textStyle(.caption)
                        .foregroundStyle(Theme.textSecondary)
                } else {
                    Text("in \(item.id - today) d")
                        .textStyle(.meta)
                        .foregroundStyle(Theme.textPrimary)
                    Text(item.dueOn)
                        .textStyle(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .frame(minHeight: 64)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Dark") {
    MilestonesInstrumentScreen().preferredColorScheme(.dark)
}

#Preview("Light") {
    MilestonesInstrumentScreen().preferredColorScheme(.light)
}
