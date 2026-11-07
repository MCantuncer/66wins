import SwiftUI
import SwiftData

// MARK: - Night check: what you won today. If nothing, a 5-minute rescue (no shame).

struct CheckScreen: View {
    @Environment(\.modelContext) private var context
    @Bindable var plan: Plan
    let profile: Profile
    var onClosed: (Int) -> Void = { _ in }
    var onPill: () -> Void = {}

    @State private var rescuing = false
    @State private var rescueEnd: Date?

    var body: some View {
        if plan.wonCount == 0 && !plan.rescued {
            rescue
        } else {
            check
        }
    }

    // MARK: check

    private var check: some View {
        VStack(spacing: 0) {
            DayTopBar(leadingSymbol: "moon.fill", leadingLabel: "Night check",
                      day: profile.dayNumber(plan.dayKey), onPill: onPill)
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    DayDial(wins: plan.wins, states: plan.dialStates, wake: plan.wake, sleep: plan.sleep) {
                        VStack(spacing: Spacing.xxs) {
                            Text("\(plan.wonCount)/\(plan.blocks.count)").textStyle(.numeralHero).foregroundStyle(Theme.textPrimary)
                            Text(plan.rescued ? "rescued" : "won today").textStyle(.caption).foregroundStyle(Theme.textSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    VStack(spacing: 0) {
                        ForEach(plan.sortedBlocks, id: \.persistentModelID) { b in
                            Button {
                                b.status = (b.status == .won) ? .skipped : .won
                            } label: {
                                HStack {
                                    BlockRow(block: b)
                                    Image(systemName: b.status == .won ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 22))
                                        .foregroundStyle(b.status == .won ? Theme.accent : Theme.textTertiary)
                                }
                            }
                            .buttonStyle(.plain)
                            .sensoryFeedback(.selection, trigger: b.status == .won)
                        }
                    }
                    .padding(.top, Spacing.lg)

                    HStack(alignment: .top, spacing: Spacing.md) {
                        Readout(label: "Day", value: "\(profile.dayNumber(plan.dayKey))", systemImage: "square.grid.3x3.fill")
                        Readout(label: "To go", value: "\(max(66 - profile.dayNumber(plan.dayKey), 0)) d", systemImage: "hourglass")
                    }
                    .padding(.top, Spacing.xl)
                }
                .padding(.horizontal, Layout.margin)
                .padding(.bottom, Spacing.lg)
            }
            .scrollIndicators(.hidden)

            PrimaryButton(title: "Close the day", systemImage: "arrow.right") { close() }
                .padding(.horizontal, Layout.margin)
                .padding(.top, Spacing.sm)
                .padding(.bottom, Spacing.xs)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .screenBackground()
    }

    // MARK: rescue

    private var tiny: Block? { plan.sortedBlocks.first }

    private var rescue: some View {
        VStack(spacing: 0) {
            DayTopBar(leadingSymbol: "lifepreserver.fill", leadingLabel: "Rescue",
                      day: profile.dayNumber(plan.dayKey), onPill: onPill)
            Spacer(minLength: Spacing.md)
            TimelineView(.periodic(from: .now, by: 1)) { ctx in
                let left = max(0, Int((rescueEnd ?? ctx.date.addingTimeInterval(300)).timeIntervalSince(ctx.date)))
                VStack(spacing: Spacing.xs) {
                    Text(String(format: "%d:%02d", left / 60, left % 60))
                        .font(.system(size: 72, weight: .bold).monospacedDigit())
                        .foregroundStyle(Theme.textPrimary)
                    Text("saves day \(profile.dayNumber(plan.dayKey))")
                        .textStyle(.meta).foregroundStyle(Theme.textSecondary)
                }
                .onChange(of: left == 0) { _, done in if done && rescuing { finishRescue() } }
            }
            VStack(spacing: Spacing.xs) {
                HStack(spacing: Spacing.xs) {
                    PurposeBadge(purpose: .rescue)
                    Text("Rescue win").textStyle(.eyebrow).foregroundStyle(Theme.textSecondary)
                }
                Text(tiny?.topic.tinyVersion ?? "Five minutes of anything you planned")
                    .textStyle(.reasonCompact)
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                Text("A missed day doesn't undo a habit. Five minutes keeps the chain.")
                    .textStyle(.caption).foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, Layout.margin)
            .padding(.top, Spacing.xl)
            Spacer(minLength: Spacing.md)

            VStack(spacing: Spacing.sm) {
                if rescuing {
                    PrimaryButton(title: "Done", systemImage: "checkmark") { finishRescue() }
                } else {
                    PrimaryButton(title: "Start 5 minutes", systemImage: "timer") {
                        rescuing = true
                        rescueEnd = .now.addingTimeInterval(300)
                    }
                }
                Button("I won something else") { plan.rescued = false; markAnyWon() }
                    .textStyle(.meta).foregroundStyle(Theme.textSecondary)
                Button("Close the day as it is") { close() }
                    .textStyle(.caption).foregroundStyle(Theme.textTertiary)
            }
            .padding(.horizontal, Layout.margin)
            .padding(.bottom, Spacing.xs)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .screenBackground()
    }

    private func finishRescue() {
        rescuing = false
        plan.rescued = true
        close()
    }

    /// Shows the check list so the user can tick what they did win.
    private func markAnyWon() {
        if let first = plan.sortedBlocks.first { first.status = .won }
    }

    private func close() {
        for b in plan.blocks where b.status == .planned { b.status = .skipped }
        plan.checkedIn = true
        try? context.save()
        onClosed(profile.dayNumber(plan.dayKey))
    }
}
