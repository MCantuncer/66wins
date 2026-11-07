import SwiftUI

/// missed-day: nothing won yet tonight. A five-minute version of a planned win
/// still saves the day. No guilt: today's tick on the run strip is open, not broken.
struct MissedDayScreen: View {
    var dateLine: String = "Friday, 6 November"
    var rescueTitle: String = "Write 100 words"
    var rescueSymbol: String = "pencil"
    var sourceTitle: String = "Write 500 words"
    var day: Int = 23

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScreenHeader(eyebrow: dateLine, title: "Still time")
                .padding(.top, Spacing.md)

            Text("5:00")
                .textStyle(.numeralHero)
                .foregroundStyle(Theme.textPrimary)
                .padding(.top, Spacing.xxl)
                .accessibilityLabel("Five minutes")

            Text("Five minutes saves the day.")
                .textStyle(.body)
                .foregroundStyle(Theme.textSecondary)
                .padding(.top, Spacing.xxs)

            HStack(spacing: Spacing.md) {
                IconTile(systemImage: rescueSymbol)
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(rescueTitle)
                        .textStyle(.focus)
                        .foregroundStyle(Theme.textPrimary)
                    Text("From \(sourceTitle)")
                        .textStyle(.meta)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .padding(.top, Spacing.xl)
            .accessibilityElement(children: .combine)

            Spacer(minLength: Spacing.xl)

            RunStrip(saved: day - 1, today: day, todaySaved: false)
                .padding(.bottom, Spacing.lg)
        }
        .padding(.horizontal, Layout.margin)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .safeAreaInset(edge: .top, spacing: 0) {
            HStack {
                GlassIconButton(systemImage: "xmark", accessibilityText: "Close")
                Spacer()
            }
            .padding(.horizontal, Layout.margin)
            .padding(.top, Spacing.xs)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: Spacing.xxs) {
                PrimaryButton(title: "Start 5 minutes", systemImage: "timer")
                Button {
                } label: {
                    Text("I won something else")
                        .textStyle(.button)
                        .foregroundStyle(Theme.textSecondary)
                        .frame(maxWidth: .infinity, minHeight: Layout.minTarget)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Layout.margin)
            .padding(.bottom, Spacing.xxs)
        }
        .screenBackground()
    }
}

#Preview("Dark") {
    MissedDayScreen()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    MissedDayScreen()
        .preferredColorScheme(.light)
}
