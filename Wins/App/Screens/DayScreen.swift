import SwiftUI
import SwiftData

// MARK: - The day: your reason, the dial with the now hand, one next block in focus

struct DayScreen: View {
    @Environment(\.modelContext) private var context
    @Bindable var plan: Plan
    let profile: Profile
    let now: Date
    var onPill: () -> Void = {}
    var onSettings: () -> Void = {}

    @State private var editing: Block?
    @State private var wins = 0

    private var hourNow: Double { DayKey.hour(now) }

    var body: some View {
        VStack(spacing: 0) {
            DayTopBar(leadingSymbol: "gearshape", leadingLabel: "Settings", leadingAction: onSettings,
                      day: profile.dayNumber(plan.dayKey), onPill: onPill)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ReasonEyebrow(text: "Why you're up").padding(.top, Spacing.md)
                    Text(plan.reason)
                        .textStyle(hourNow < plan.wake + 2 ? .reason : .reasonCompact)
                        .foregroundStyle(Theme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, Spacing.xs)

                    DayDial(wins: plan.wins, size: 200, lineWidth: 12, states: plan.dialStates,
                            nowHour: hourNow, wake: plan.wake, sleep: plan.sleep) {
                        VStack(spacing: Spacing.xxs) {
                            if let next = plan.nextBlock {
                                Text(countdown(to: next)).textStyle(.eyebrow).foregroundStyle(Theme.textSecondary)
                                Text(DayKey.timeText(next.start)).textStyle(.numeral).foregroundStyle(Theme.textPrimary)
                            } else {
                                Text("\(plan.wonCount)/\(plan.blocks.count)").textStyle(.numeral).foregroundStyle(Theme.textPrimary)
                            }
                        }
                        .accessibilityElement(children: .combine)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, Spacing.lg)

                    if let next = plan.nextBlock {
                        focus(next).padding(.top, Spacing.lg)
                    }

                    // The rest of the day, quiet.
                    VStack(spacing: 0) {
                        ForEach(plan.sortedBlocks.filter { $0 !== plan.nextBlock }, id: \.persistentModelID) { b in
                            Button { editing = b } label: { BlockRow(block: b, dimmed: b.status == .planned) }
                                .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, Spacing.lg)
                }
                .padding(.horizontal, Layout.margin)
                .padding(.bottom, Spacing.lg)
            }
            .scrollIndicators(.hidden)

            if let next = plan.nextBlock {
                VStack(spacing: Spacing.xs) {
                    PrimaryButton(title: "Done", systemImage: "checkmark") { mark(next, .won) }
                    HStack(spacing: Spacing.lg) {
                        Button("5-minute version") { next.title = next.topic.tinyVersion; mark(next, .won) }
                        Button("Skip") { mark(next, .skipped) }
                    }
                    .textStyle(.meta)
                    .foregroundStyle(Theme.textSecondary)
                }
                .padding(.horizontal, Layout.margin)
                .padding(.top, Spacing.sm)
                .padding(.bottom, Spacing.xs)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .screenBackground()
        .sheet(item: $editing) { BlockEditor(block: $0) }
        .sensoryFeedback(.success, trigger: wins)
    }

    private func focus(_ b: Block) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Button { editing = b } label: {
                HStack(spacing: Spacing.md) {
                    BadgedIcon(systemImage: b.topic.symbol, purpose: b.topic.purpose, size: 44)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(b.title).textStyle(.headline).foregroundStyle(Theme.textPrimary)
                        Text("\(DayKey.timeText(b.start)) · \(Int((b.duration * 60).rounded())) min")
                            .textStyle(.caption).foregroundStyle(Theme.textSecondary)
                    }
                    Spacer()
                }
            }
            .buttonStyle(.plain)

            ForEach(Array(b.steps.enumerated()), id: \.offset) { i, s in
                Button { b.toggleStep(i) } label: {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: b.isStepDone(i) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(b.isStepDone(i) ? Theme.accent : Theme.textTertiary)
                        Text(s).textStyle(.body).foregroundStyle(Theme.textPrimary)
                            .strikethrough(b.isStepDone(i))
                        Spacer()
                    }
                    .frame(minHeight: 36)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .sensoryFeedback(.selection, trigger: b.isStepDone(i))
            }
        }
        .padding(Spacing.md)
        .background(Theme.surfaceRaised, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func countdown(to b: Block) -> String {
        let minutes = Int(((b.start - hourNow) * 60).rounded())
        if minutes > 60 { return "in \(minutes / 60) h \(minutes % 60) min" }
        if minutes > 0 { return "in \(minutes) min" }
        return "now"
    }

    private func mark(_ b: Block, _ s: BlockStatus) {
        b.status = s
        if s == .won { wins += 1 }
        try? context.save()
    }
}
