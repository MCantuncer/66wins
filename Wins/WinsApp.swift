import SwiftUI
import SwiftData

@main
struct WinsApp: App {
    /// Design renders launch with `-screen <id>`; `-catalog` opens the design list.
    private var showsCatalog: Bool {
        DesignCatalog.requestedID != nil || ProcessInfo.processInfo.arguments.contains("-catalog")
    }

    var body: some Scene {
        WindowGroup {
            if showsCatalog {
                DesignCatalog.rootView()
                    .preferredColorScheme(DesignCatalog.colorScheme)
            } else {
                RootView()
                    .preferredColorScheme(.dark)
            }
        }
        .modelContainer(for: [Profile.self, Plan.self, Block.self])
    }
}
