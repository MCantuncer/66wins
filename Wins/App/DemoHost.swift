import SwiftUI
import SwiftData

// MARK: - Seeded app states for design renders (`-screen app-day` etc.)
//
// Each state runs the real RootView on an in-memory store with a fixed clock.

struct DemoHost: View {
    enum Mode: String { case welcome, rhythm, reason, topics, plan, set, day, check, rescue, progress }

    let state: Mode
    var focusStyle: FocusStyle = .ring
    private let container: ModelContainer
    private let now: Date

    init(_ state: Mode, focus: FocusStyle = .ring) {
        self.state = state
        self.focusStyle = focus
        container = try! ModelContainer(for: Profile.self, Plan.self, Block.self,
                                        configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let today = DayKey.today()
        let hour: Double
        switch state {
        case .plan, .set, .check, .rescue, .progress: hour = 21.5
        case .day: hour = 9.5
        default: hour = 9
        }
        now = DayKey.moment(today, hour: hour) ?? .now
        Self.seed(state, into: container.mainContext, today: today)
    }

    var body: some View {
        Group {
            switch state {
            case .rhythm: RhythmStep(profile: profile) {}
            case .reason: ReasonStep(profile: profile) {}
            case .topics: TopicsStep(profile: profile) {}
            default: RootView(fixedNow: now, openProgress: state == .progress)
            }
        }
        .modelContainer(container)
        .environment(\.focusStyle, focusStyle)
    }

    private var profile: Profile {
        (try? container.mainContext.fetch(FetchDescriptor<Profile>()).first) ?? Profile()
    }

    private static func seed(_ state: Mode, into ctx: ModelContext, today: String) {
        guard state != .welcome else { return }
        let p = Profile()
        p.provider = "apple"
        p.userID = "demo"
        p.name = "Can"
        p.wake = 6.5
        p.sleep = 22.5
        p.reason = state == .reason ? "" : "Finish the first chapter before anyone else is awake."
        p.topicKeys = Topic.allCases.map(\.rawValue)
        p.onboarded = ![.rhythm, .reason, .topics].contains(state)
        p.startKey = DayKey.add(-20, to: today)
        ctx.insert(p)
        guard p.onboarded else { return }

        // 20 past days with real-life gaps; day 9 and 16 were rescued.
        for i in 0..<20 {
            let key = DayKey.add(i, to: p.startKey)
            let plan = makePlan(key, p, ctx)
            plan.isSet = true
            plan.checkedIn = true
            let day = i + 1
            for (j, b) in plan.sortedBlocks.enumerated() {
                let won = (day == 9 || day == 16) ? false : (j == 0 || (j == 1 && day % 4 != 3) || (j == 2 && day % 3 != 0) || (j == 3 && day % 5 != 2))
                b.status = won ? .won : .skipped
            }
            plan.rescued = day == 9 || day == 16
        }

        switch state {
        case .set:
            let t = makePlan(today, p, ctx); t.isSet = true; t.checkedIn = true
            for b in t.blocks { b.status = .won }
            let tm = makePlan(DayKey.add(1, to: today), p, ctx); tm.isSet = true
        case .day:
            let t = makePlan(today, p, ctx); t.isSet = true
            t.sortedBlocks.first?.status = .won
            t.sortedBlocks.dropFirst().first?.status = .won
        case .check:
            let t = makePlan(today, p, ctx); t.isSet = true
            t.sortedBlocks.first?.status = .won
            t.sortedBlocks.dropFirst().first?.status = .won
        case .rescue:
            let t = makePlan(today, p, ctx); t.isSet = true
        case .plan, .progress:
            let t = makePlan(today, p, ctx); t.isSet = true; t.checkedIn = true
            for b in t.blocks { b.status = .won }
        default: break
        }
        try? ctx.save()
    }

    @discardableResult
    private static func makePlan(_ key: String, _ p: Profile, _ ctx: ModelContext) -> Plan {
        let plan = Plan(dayKey: key, reason: p.reason, wake: p.wake, sleep: p.sleep)
        ctx.insert(plan)
        let steps: [Topic: [String]] = [.wake: ["Water", "Make the bed", "Shower"],
                                        .work: ["Outline chapter 2", "Reply to Deniz", "Send the invoice"],
                                        .gym: ["Squats 5×5", "Bench 5×5"],
                                        .bedtime: ["Screens off"]]
        let titles: [Topic: String] = [.wake: "Wake routine", .work: "Deep work", .gym: "Gym: legs and push", .bedtime: "Wind down"]
        for t in Topic.allCases {
            let slot = t.defaultSlot(p)
            let b = Block(topic: t, title: titles[t] ?? t.name, start: slot.start, duration: slot.duration, steps: steps[t] ?? [])
            b.plan = plan
            ctx.insert(b)
        }
        return plan
    }
}

// MARK: - The three step-card variants, full size, one above the other

struct FocusCompare: View {
    private let block: Block = {
        let b = Block(topic: .work, title: "Deep work", start: 9, duration: 2,
                      steps: ["Outline chapter 2", "Reply to Deniz", "Send the invoice"])
        b.stepsDone = [true, false, false]
        return b
    }()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                ForEach([(FocusStyle.deck, "A · Deck"), (.ring, "B · Ring"), (.rail, "C · Rail")], id: \.1) { style, label in
                    Text(label).textStyle(.eyebrow).foregroundStyle(Theme.textSecondary)
                    FocusCard(block: block, hourNow: 9.5)
                        .environment(\.focusStyle, style)
                }
            }
            .padding(.horizontal, Layout.margin)
            .padding(.top, Spacing.md)
        }
        .screenBackground()
    }
}
