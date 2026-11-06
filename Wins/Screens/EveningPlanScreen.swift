import SwiftUI

/// evening-plan: tonight, the user sets tomorrow.
/// The reason to wake up is the hero (New York). Tomorrow is drawn once as a day shape,
/// then named in plain rows. One primary action: hold to set tomorrow.
struct EveningPlanScreen: View {
    var dateLine: String = "Saturday, 7 November"
    var reason: String = SampleDay.reason
    var wins: [PlannedWin] = SampleDay.wins
    var segments: [DaySegment] = SampleDay.segments
    var wakeTime: String = "6:30"
    var day: Int = 24

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ScreenHeader(eyebrow: dateLine, title: "Tomorrow")

                HStack(spacing: Spacing.xs) {
                    Pill(text: wakeTime, systemImage: "alarm", accessibilityText: "Alarm at \(wakeTime)")
                    Pill(text: "\(day)/66", systemImage: "square.grid.3x3.fill", accessibilityText: "Day \(day) of 66")
                }
                .padding(.top, Spacing.sm)

                SectionHeader("Reason to wake up")
                    .padding(.top, Spacing.xxl)

                Text(reason)
                    .textStyle(.reason)
                    .foregroundStyle(Theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, Spacing.xs)

                DayShapeView(segments: segments)
                    .padding(.top, Spacing.xxl)

                WinList(wins: wins)
                    .padding(.top, Spacing.lg)
            }
            .padding(.horizontal, Layout.margin)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.xl)
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .top, spacing: 0) {
            HStack {
                GlassIconButton(systemImage: "xmark", accessibilityText: "Close")
                Spacer()
            }
            .padding(.horizontal, Layout.margin)
            .padding(.top, Spacing.xs)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            HoldToConfirmButton(title: "Hold to set tomorrow")
                .padding(.horizontal, Layout.margin)
                .padding(.top, Spacing.sm)
                .padding(.bottom, Spacing.xs)
        }
        .screenBackground()
    }
}

#Preview("Dark") {
    EveningPlanScreen()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    EveningPlanScreen()
        .preferredColorScheme(.light)
}
