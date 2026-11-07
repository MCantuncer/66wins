import SwiftUI

/// Design-review harness. Launch with `-screen <id>` (and optionally `-light`)
/// to show one design screen full-screen, so scripts/render.sh can screenshot it.
/// Without arguments it shows a list of every screen.
enum DesignCatalog {
    struct Entry: Identifiable {
        let id: String
        let title: String
        let view: () -> AnyView
    }

    /// Register every design screen here.
    static let entries: [Entry] = [
        // The real app on seeded data (MVP).
        Entry(id: "app-welcome", title: "App: Welcome") { AnyView(DemoHost(.welcome)) },
        Entry(id: "app-rhythm", title: "App: Your rhythm") { AnyView(DemoHost(.rhythm)) },
        Entry(id: "app-reason", title: "App: Your reason") { AnyView(DemoHost(.reason)) },
        Entry(id: "app-topics", title: "App: Topics") { AnyView(DemoHost(.topics)) },
        Entry(id: "app-plan", title: "App: Tonight") { AnyView(DemoHost(.plan)) },
        Entry(id: "app-set", title: "App: Tomorrow is set") { AnyView(DemoHost(.set)) },
        Entry(id: "app-day", title: "App: The day") { AnyView(DemoHost(.day)) },
        Entry(id: "app-day-deck", title: "App: The day (deck)") { AnyView(DemoHost(.day, focus: .deck)) },
        Entry(id: "app-day-ring", title: "App: The day (ring)") { AnyView(DemoHost(.day, focus: .ring)) },
        Entry(id: "app-day-rail", title: "App: The day (rail)") { AnyView(DemoHost(.day, focus: .rail)) },
        Entry(id: "app-check", title: "App: Night check") { AnyView(DemoHost(.check)) },
        Entry(id: "app-rescue", title: "App: Rescue") { AnyView(DemoHost(.rescue)) },
        Entry(id: "app-progress", title: "App: 66 days") { AnyView(DemoHost(.progress)) },
        // Chosen direction: "Instrument".
        Entry(id: "welcome", title: "Welcome") { AnyView(WelcomeInstrumentScreen()) },
        Entry(id: "evening-plan", title: "Tonight") { AnyView(TonightInstrumentScreen()) },
        Entry(id: "tomorrow-set", title: "Tomorrow is set") { AnyView(TomorrowSetInstrumentScreen()) },
        Entry(id: "morning-open", title: "Morning") { AnyView(MorningOpenInstrumentScreen()) },
        Entry(id: "night-check", title: "Night check") { AnyView(NightCheckInstrumentScreen()) },
        Entry(id: "missed-day", title: "Missed day") { AnyView(MissedDayInstrumentScreen()) },
        Entry(id: "badge-earned", title: "Badge earned") { AnyView(BadgeEarnedInstrumentScreen()) },
        Entry(id: "progress-habits", title: "Progress: habit rows") { AnyView(BadgeEarnedInstrumentScreen(progress: .habits)) },
        Entry(id: "progress-thennow", title: "Progress: then vs now") { AnyView(BadgeEarnedInstrumentScreen(progress: .thenNow)) },
        Entry(id: "badges", title: "Milestones") { AnyView(MilestonesInstrumentScreen()) },
    ]

    static var requestedID: String? {
        let args = ProcessInfo.processInfo.arguments
        guard let i = args.firstIndex(of: "-screen"), i + 1 < args.count else { return nil }
        return args[i + 1]
    }

    static var colorScheme: ColorScheme {
        ProcessInfo.processInfo.arguments.contains("-light") ? .light : .dark
    }

    @ViewBuilder
    static func rootView() -> some View {
        if let id = requestedID, let entry = entries.first(where: { $0.id == id }) {
            entry.view()
        } else {
            NavigationStack {
                List(entries) { entry in
                    NavigationLink(entry.title) { entry.view() }
                }
                .navigationTitle("66wins designs")
            }
        }
    }
}
