import SwiftUI
import SwiftData

// MARK: - Tonight: plan the next day on the dial, then hold to set

struct PlanScreen: View {
    @Environment(\.modelContext) private var context
    @Bindable var plan: Plan
    let profile: Profile
    var onPill: () -> Void = {}
    var onSettings: () -> Void = {}

    @State private var editing: Block?
    @State private var dump = ""

    var body: some View {
        VStack(spacing: 0) {
            DayTopBar(leadingSymbol: "gearshape", leadingLabel: "Settings", leadingAction: onSettings,
                      day: profile.dayNumber(plan.dayKey), onPill: onPill)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text(DayKey.key(.now) == plan.dayKey ? "Today" : DayKey.weekday(plan.dayKey))
                        .textStyle(.eyebrow)
                        .foregroundStyle(Theme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, Spacing.xs)

                    DayDial(wins: plan.wins, size: 236, wake: plan.wake, sleep: plan.sleep) {
                        VStack(spacing: Spacing.xxs) {
                            HStack(spacing: Spacing.xxs) {
                                Image(systemName: "alarm.fill").font(.system(size: 13, weight: .semibold))
                                Text("Wake").textStyle(.eyebrow)
                            }
                            .foregroundStyle(Theme.textSecondary)
                            DatePicker("Wake", selection: Binding(
                                get: { DayKey.hourDate(plan.wake) },
                                set: { plan.wake = DayKey.hour($0) }),
                                displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                    }
                    .frame(maxWidth: .infinity)

                    ReasonEyebrow()
                        .padding(.top, Spacing.lg)
                    TextField("Why tomorrow matters", text: $plan.reason, axis: .vertical)
                        .textStyle(.reasonCompact)
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(1...3)
                        .padding(.top, Spacing.xs)

                    VStack(spacing: 0) {
                        ForEach(Array(plan.sortedBlocks.enumerated()), id: \.element.persistentModelID) { i, b in
                            Button { editing = b } label: { BlockRow(block: b, isFirst: i == 0) }
                                .buttonStyle(.plain)
                            Rectangle().fill(Theme.separator).frame(height: 0.5).padding(.leading, 52)
                        }
                    }
                    .padding(.top, Spacing.lg)

                    // Dump first, sort later: anything typed here becomes a step of the work block.
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "tray.and.arrow.down.fill")
                            .foregroundStyle(Theme.textSecondary)
                        TextField("Empty your head: one task per line", text: $dump)
                            .textStyle(.body)
                            .onSubmit(addDump)
                    }
                    .padding(Spacing.md)
                    .background(Theme.surfaceRaised, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.top, Spacing.md)

                    addMenu
                        .padding(.top, Spacing.md)
                }
                .padding(.horizontal, Layout.margin)
                .padding(.bottom, Spacing.lg)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)

            HoldToConfirmButton(title: "Hold to set \(DayKey.key(.now) == plan.dayKey ? "today" : "tomorrow")") {
                plan.isSet = true
                try? context.save()
                Reminders.reschedule(plan: plan, profile: profile)
            }
            .disabled(plan.blocks.isEmpty)
            .padding(.horizontal, Layout.margin)
            .padding(.top, Spacing.sm)
            .padding(.bottom, Spacing.xs)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .screenBackground()
        .sheet(item: $editing) { BlockEditor(block: $0) }
    }

    private var addMenu: some View {
        Menu {
            ForEach(Topic.allCases) { t in
                Button { add(t) } label: { Label(t.name, systemImage: t.symbol) }
            }
        } label: {
            Label("Add a block", systemImage: "plus")
                .textStyle(.meta)
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private func add(_ t: Topic) {
        let slot = t.defaultSlot(profile)
        let b = Block(topic: t, title: t.defaultTitle(), start: slot.start, duration: slot.duration, steps: t.defaultSteps)
        b.plan = plan
        context.insert(b)
        editing = b
    }

    private func addDump() {
        let lines = dump.split(whereSeparator: \.isNewline).map(String.init)
        let work = plan.blocks.first { $0.topic == .work } ?? {
            let slot = Topic.work.defaultSlot(profile)
            let b = Block(topic: .work, title: Topic.work.defaultTitle(), start: slot.start, duration: slot.duration)
            b.plan = plan
            context.insert(b)
            return b
        }()
        lines.forEach { work.addStep($0) }
        dump = ""
    }
}

// MARK: - Tomorrow is set

struct SetScreen: View {
    let plan: Plan
    let profile: Profile
    var onEdit: () -> Void = {}
    var onPill: () -> Void = {}
    @State private var saidGoodNight = false

    var body: some View {
        VStack(spacing: 0) {
            DayTopBar(leadingSymbol: "pencil", leadingLabel: "Edit", leadingAction: onEdit,
                      day: profile.dayNumber(plan.dayKey), onPill: onPill)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    DayDial(wins: plan.wins, wake: plan.wake, sleep: plan.sleep) {
                        VStack(spacing: Spacing.xxs) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(Theme.accent)
                            Text("Set").textStyle(.numeralHero).foregroundStyle(Theme.textPrimary)
                            Text("\(DayKey.weekday(plan.dayKey)) is ready")
                                .textStyle(.caption).foregroundStyle(Theme.textSecondary)
                        }
                        .accessibilityElement(children: .combine)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, Spacing.sm)

                    ReasonEyebrow().padding(.top, Spacing.xl)
                    Text(plan.reason)
                        .textStyle(.reasonCompact)
                        .foregroundStyle(Theme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, Spacing.xs)

                    HStack(alignment: .top, spacing: Spacing.md) {
                        Readout(label: "Alarm", value: DayKey.timeText(plan.wake), systemImage: "alarm.fill")
                        Readout(label: "First win", value: plan.sortedBlocks.first.map { DayKey.timeText($0.start) } ?? "–",
                                systemImage: Purpose.firstWin.symbol)
                        Readout(label: "Blocks", value: "\(plan.blocks.count)", systemImage: "checkmark.circle.fill")
                    }
                    .padding(.top, Spacing.xl)
                }
                .padding(.horizontal, Layout.margin)
                .padding(.bottom, Spacing.lg)
            }
            .scrollIndicators(.hidden)

            if saidGoodNight {
                Text("Sleep well. Your reason will be waiting at \(DayKey.timeText(plan.wake)).")
                    .textStyle(.meta)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Layout.margin)
                    .padding(.bottom, Spacing.md)
            } else {
                GlassWideButton(title: "Good night", systemImage: "moon.fill") { saidGoodNight = true }
                    .padding(.horizontal, Layout.margin)
                    .padding(.top, Spacing.sm)
                    .padding(.bottom, Spacing.xs)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .screenBackground()
    }
}
