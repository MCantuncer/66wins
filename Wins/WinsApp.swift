import SwiftUI

@main
struct WinsApp: App {
    var body: some Scene {
        WindowGroup {
            DesignCatalog.rootView()
                .preferredColorScheme(DesignCatalog.colorScheme)
        }
    }
}
