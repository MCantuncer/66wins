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
        // Chosen direction: "Instrument".
        Entry(id: "evening-plan", title: "Tonight") { AnyView(TonightInstrumentScreen()) },
        Entry(id: "tomorrow-set", title: "Tomorrow is set") { AnyView(TomorrowSetInstrumentScreen()) },
        Entry(id: "morning-open", title: "Morning") { AnyView(MorningOpenInstrumentScreen()) },
        Entry(id: "night-check", title: "Night check") { AnyView(NightCheckInstrumentScreen()) },
        Entry(id: "missed-day", title: "Missed day") { AnyView(MissedDayInstrumentScreen()) },
        Entry(id: "badge-earned", title: "Badge earned") { AnyView(BadgeEarnedInstrumentScreen()) },
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
