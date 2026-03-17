import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            MyFlightsView()
                .tabItem {
                    Label("My Flights", systemImage: "airplane")
                }

            FlightSearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: Flight.self, inMemory: true)
}
