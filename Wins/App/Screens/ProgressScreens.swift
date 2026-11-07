import SwiftUI
import SwiftData

// MARK: - Records for the 66-day grid from real plans

enum GridData {
    static func records(plans: [Plan], profile: Profile, through key: String) -> [DayRecord] {
        let byKey = Dictionary(plans.map { ($0.dayKey, $0) }, uniquingKeysWith: { a, _ in a })
        let last = max(1, min(profile.dayNumber(key), 66))
        return (0..<last).map { i in
            let k = DayKey.add(i, to: profile.startKey)
            if let p = byKey[k] {
                return DayRecord(arcs: [], rescued: p.rescued && p.wonCount == 0, level: p.level)
            }
            return DayRecord(arcs: [], rescued: false, level: 0)
        }
    }

    static let milestones = MilestoneStory.moments
}

// MARK: - The 66 days (opened from the day pill)

struct ProgressSheet: View {
    @Environment(\.dismiss) private var dismiss
    let records: [DayRecord]

    var body: some View {
        let day = records.count
        let next = GridData.milestones.first { $0.id > day }
        VStack(spacing: Spacing.md) {
            HStack {
                GlassIconButton(systemImage: "xmark", accessibilityText: "Close") { dismiss() }
                Spacer()
            }
            HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                Text("\(day)").textStyle(.numeralHero).foregroundStyle(Theme.textPrimary)
                Text("of 66 days").textStyle(.headline).foregroundStyle(Theme.textSecondary)
            }
            DayGrid(records: records)
            DayGridLegend()
            if let next {
                HStack(spacing: Spacing.xs) {
                    PurposeBadge(purpose: next.rewards, size: 18)
                    Text("\(next.id - day) days to \(next.name)").textStyle(.meta).foregroundStyle(Theme.textSecondary)
                }
            }
            Spacer()
        }
        .padding(.horizontal, Layout.margin)
        .padding(.top, Spacing.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .screenBackground()
    }
}

// MARK: - Milestone earned (after the night check on day 7, 21, 40 and 66)

struct MilestoneSheet: View {
    @Environment(\.dismiss) private var dismiss
    let moment: MilestoneMoment
    let records: [DayRecord]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                        Text("\(moment.id)").textStyle(.numeralHero).foregroundStyle(Theme.textPrimary)
                        Text("of 66 days").textStyle(.headline).foregroundStyle(Theme.textSecondary)
                    }
                    .padding(.top, Spacing.xl)
                    DayGrid(records: records).padding(.top, Spacing.md)
                    DayGridLegend().padding(.top, Spacing.sm)

                    HStack(spacing: Spacing.xs) {
                        PurposeBadge(purpose: moment.rewards)
                        Text(moment.rewards.label).textStyle(.eyebrow).foregroundStyle(Theme.textSecondary)
                    }
                    .padding(.top, Spacing.xl)
                    Text(moment.name).textStyle(.screenTitle).foregroundStyle(Theme.textPrimary).padding(.top, Spacing.xs)
                    Text(moment.meaning).textStyle(.reasonCompact).foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center).padding(.top, Spacing.xxs)
                }
                .padding(.horizontal, Layout.margin)
            }
            GlassWideButton(title: "Keep going", systemImage: "arrow.right") { dismiss() }
                .padding(.horizontal, Layout.margin)
                .padding(.bottom, Spacing.xs)
        }
        .screenBackground()
        .sensoryFeedback(.success, trigger: true)
    }
}

// MARK: - Settings: your rhythm and reason, sign out

struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Bindable var profile: Profile
    @State private var confirmReset = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HourRow(systemImage: "alarm.fill", label: "Wake up", hour: $profile.wake)
                    HourRow(systemImage: "bed.double.fill", label: "Bedtime", hour: $profile.sleep)
                    HourRow(systemImage: "briefcase.fill", label: "Work starts", hour: $profile.workStart)
                    HourRow(systemImage: "briefcase", label: "Work ends", hour: $profile.workEnd)
                    Toggle("Most energy in the morning", isOn: $profile.isMorningPerson)
                } header: { Text("Your rhythm") } footer: {
                    Text("New blocks start from these times. Peak work goes early in your day; the wind-down sits before bed.")
                }
                Section("Your reason") {
                    TextField("Why tomorrow matters", text: $profile.reason, axis: .vertical)
                }
                Section {
                    LabeledContent("Signed in with", value: profile.provider.capitalized)
                    Button("Sign out and start over", role: .destructive) { confirmReset = true }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
            .confirmationDialog("This deletes your plans on this phone.", isPresented: $confirmReset, titleVisibility: .visible) {
                Button("Sign out and delete", role: .destructive) {
                    try? context.delete(model: Block.self)
                    try? context.delete(model: Plan.self)
                    try? context.delete(model: Profile.self)
                    try? context.save()
                    dismiss()
                }
            }
        }
    }
}
