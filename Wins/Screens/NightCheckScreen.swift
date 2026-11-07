import SwiftUI

/// night-check: mark what got won. Any single win saves the day.
/// Shown here in the "day saved" state: 2 of 3 won. The run strip is the one data mark.
struct NightCheckScreen: View {
    var dateLine: String = "Friday, 6 November"
    var wins: [PlannedWin] = SampleDay.wins
    var checks: [Int: WinCheck] = [0: .won, 1: .won, 2: .open]
    var day: Int = 23

    private var wonCount: Int {
        checks.values.filter { $0 == .won }.count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ScreenHeader(eyebrow: dateLine, title: "Day saved")

                Pill(text: "\(wonCount) of \(wins.count)",
                     systemImage: "checkmark.circle.fill",
                     style: .solid,
                     accessibilityText: "\(wonCount) of \(wins.count) wins")
                    .padding(.top, Spacing.sm)

                RunStrip(saved: day, today: day, todaySaved: true)
                    .padding(.top, Spacing.xxl)

                WinList(wins: wins, checks: checks, showsChecks: true)
                    .padding(.top, Spacing.xxl)
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
            PrimaryButton(title: "Set tomorrow", systemImage: "arrow.right")
                .padding(.horizontal, Layout.margin)
                .padding(.top, Spacing.sm)
                .padding(.bottom, Spacing.xs)
        }
        .screenBackground()
    }
}

#Preview("Dark") {
    NightCheckScreen()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    NightCheckScreen()
        .preferredColorScheme(.light)
}
