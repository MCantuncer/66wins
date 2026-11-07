import SwiftUI
import SwiftData

// MARK: - Root: decides which screen the moment calls for
//
// No tabs and no menus to learn. The app opens on the one thing that matters now:
// planning, the set plan, the day itself, or the night check.

struct RootView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var phase
    @Query private var profiles: [Profile]
    @Query(sort: \Plan.dayKey) private var plans: [Plan]

    @State private var now = Date.now
    @State private var showProgress = false
    @State private var showSettings = false
    @State private var milestone: MilestoneMoment?

    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        Group {
            if let profile = profiles.first, profile.onboarded {
                home(profile)
                    .sheet(isPresented: $showProgress) {
                        ProgressSheet(records: GridData.records(plans: plans, profile: profile, through: DayKey.today(now)))
                    }
                    .sheet(isPresented: $showSettings) { SettingsSheet(profile: profile) }
                    .sheet(item: $milestone) { m in
                        MilestoneSheet(moment: m, records: GridData.records(
                            plans: plans, profile: profile, through: DayKey.add(m.id - 1, to: profile.startKey)))
                    }
            } else {
                OnboardingFlow(profile: profiles.first)
            }
        }
        .onReceive(timer) { now = $0 }
        .onChange(of: phase) { _, p in if p == .active { now = .now } }
    }

    private enum Route { case plan(Plan), set(Plan), day(Plan), check(Plan), needsDraft(String) }

    @ViewBuilder
    private func home(_ profile: Profile) -> some View {
        switch route(profile) {
        case .needsDraft(let key):
            Theme.background.ignoresSafeArea()
                .onAppear { draft(for: key, profile: profile) }
        case .plan(let p):
            PlanScreen(plan: p, profile: profile, onPill: { showProgress = true }, onSettings: { showSettings = true })
        case .set(let p):
            SetScreen(plan: p, profile: profile, onEdit: { p.isSet = false }, onPill: { showProgress = true })
        case .day(let p):
            DayScreen(plan: p, profile: profile, now: now, onPill: { showProgress = true }, onSettings: { showSettings = true })
        case .check(let p):
            CheckScreen(plan: p, profile: profile, onClosed: { day in
                if p.wonCount > 0 || p.rescued, let m = MilestoneStory.moments.first(where: { $0.id == day }) {
                    milestone = m
                }
            }, onPill: { showProgress = true })
        }
    }

    private func route(_ profile: Profile) -> Route {
        let today = DayKey.today(now)
        let tomorrow = DayKey.add(1, to: today)
        let yesterday = DayKey.add(-1, to: today)
        let h = DayKey.hour(now)
        let byKey = Dictionary(plans.map { ($0.dayKey, $0) }, uniquingKeysWith: { a, _ in a })

        // A day that was set but never closed: close it until noon the next day.
        if h < 12, let y = byKey[yesterday], y.isSet, !y.checkedIn { return .check(y) }

        if let t = byKey[today], t.isSet, !t.checkedIn {
            if t.isResolved || h >= t.sleep - 1.5 { return .check(t) }
            return .day(t)
        }
        if let tm = byKey[tomorrow], tm.isSet { return .set(tm) }

        // Nothing set: plan today in the morning (if today is still open), otherwise tomorrow.
        let todayOpen = byKey[today].map { !$0.checkedIn } ?? true
        let target = (h < 11 && todayOpen) ? today : tomorrow
        if let p = byKey[target] { return .plan(p) }
        return .needsDraft(target)
    }

    /// Returns the plan for a day, creating a draft from the topics and rhythm if needed.
    private func draft(for key: String, profile: Profile) {
        guard !plans.contains(where: { $0.dayKey == key }) else { return }
        let last = plans.last { $0.dayKey < key }
        let plan = Plan(dayKey: key,
                        reason: last?.reason.isEmpty == false ? last!.reason : profile.reason,
                        wake: profile.wake, sleep: profile.sleep)
        context.insert(plan)
        for t in profile.topics {
            // Reuse yesterday's block for the same topic (same time, same steps), else the science default.
            if let prev = last?.blocks.first(where: { $0.topic == t }) {
                let b = Block(topic: t, title: prev.title, start: prev.start, duration: prev.duration, steps: prev.steps)
                b.plan = plan
                context.insert(b)
            } else {
                let slot = t.defaultSlot(profile)
                let b = Block(topic: t, title: t.defaultTitle(), start: slot.start, duration: slot.duration, steps: t.defaultSteps)
                b.plan = plan
                context.insert(b)
            }
        }
        if profile.startKey.isEmpty { profile.startKey = key }
        try? context.save()
    }
}

