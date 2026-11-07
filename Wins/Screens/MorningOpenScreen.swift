import SwiftUI

// MARK: - morning-open (07:00)
//
// What opening the app after the alarm shows. Zero decisions:
// the reason to wake up is the hero (New York), tomorrow's shape shows where
// the first win sits in the day, then only that first win and one action.
// Data mark: DayShapeView (the only one on this screen).

struct MorningOpenScreen: View {
    struct Sample {
        var weekday: String
        var day: Int
        var reason: String
        var firstWin: String
        var firstWinSymbol: String
        var firstWinTime: String
        var firstWinMinutes: Int
        var segments: [DaySegment]

        static let saturday = Sample(
            weekday: "Saturday",
            day: 24,
            // Same day the user planned last night (SampleDay), so the flow reads as one story.
            reason: SampleDay.reason,
            firstWin: "Write 500 words",
            firstWinSymbol: "pencil",
            firstWinTime: "7:00",
            firstWinMinutes: 45,
            segments: [
                DaySegment(id: 0, start: 7, duration: 0.75, state: .focus),
                DaySegment(id: 1, start: 12.5, duration: 0.75, state: .muted),
                DaySegment(id: 2, start: 19, duration: 0.5, state: .muted),
            ]
        )
    }

    var sample: Sample = .saturday

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            topBar

            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(sample.weekday)
                    .textStyle(.eyebrow)
                    .foregroundStyle(Theme.textSecondary)
                Text(sample.reason)
                    .textStyle(.reason)
                    .foregroundStyle(Theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
            }
            .padding(.top, Spacing.xxl)

            DayShapeView(segments: sample.segments)
                .padding(.top, Spacing.xxl)

            Spacer(minLength: Spacing.xl)

            focalTask

            PrimaryButton(title: "Start", systemImage: "play.fill")
                .padding(.top, Spacing.lg)
        }
        .padding(.horizontal, Layout.margin)
        .padding(.bottom, Spacing.xs)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .screenBackground()
    }

    private var topBar: some View {
        HStack {
            Pill(
                text: "\(sample.day)/66",
                systemImage: "square.grid.3x3.fill",
                accessibilityText: "Day \(sample.day) of 66"
            )
            Spacer(minLength: Spacing.xs)
            GlassIconButton(systemImage: "ellipsis", accessibilityText: "More")
        }
        .frame(minHeight: Layout.minTarget)
        .padding(.top, Spacing.xs)
    }

    private var focalTask: some View {
        HStack(spacing: Spacing.md) {
            IconTile(systemImage: sample.firstWinSymbol, size: 56)
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(sample.firstWin)
                    .textStyle(.focus)
                    .foregroundStyle(Theme.textPrimary)
                HStack(spacing: Spacing.sm) {
                    metaItem(systemImage: "clock", text: sample.firstWinTime)
                    metaItem(systemImage: "timer", text: "\(sample.firstWinMinutes) min")
                }
            }
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("First win: \(sample.firstWin), \(sample.firstWinTime), \(sample.firstWinMinutes) minutes")
    }

    private func metaItem(systemImage: String, text: String) -> some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: systemImage)
                .symbolRenderingMode(.monochrome)
                .fontWeight(.semibold)
                .imageScale(.small)
            Text(text)
        }
        .textStyle(.meta)
        .foregroundStyle(Theme.textSecondary)
    }
}

#Preview("Dark") {
    MorningOpenScreen()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    MorningOpenScreen()
        .preferredColorScheme(.light)
}
