import SwiftUI
import SwiftData

@main
struct OpenFlightApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: Flight.self)
    }
}
