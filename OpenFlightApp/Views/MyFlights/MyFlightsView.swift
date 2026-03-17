import SwiftUI
import SwiftData

struct MyFlightsView: View {
    @Query(
        filter: #Predicate<Flight> { $0.isTracked },
        sort: [SortDescriptor(\Flight.scheduledDeparture, order: .reverse)]
    )
    private var trackedFlights: [Flight]

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            Group {
                if trackedFlights.isEmpty {
                    emptyState
                } else {
                    flightList
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("My Flights")
        }
    }

    // MARK: - Flight List

    private var flightList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // Active flights first
                let active = trackedFlights.filter { $0.phase.isActive }
                let upcoming = trackedFlights.filter { $0.phase == .scheduled || $0.phase == .boarding }
                let past = trackedFlights.filter { $0.phase.isTerminal }

                if !active.isEmpty {
                    sectionHeader("Active")
                    ForEach(active) { flight in
                        flightLink(flight)
                    }
                }

                if !upcoming.isEmpty {
                    sectionHeader("Upcoming")
                    ForEach(upcoming) { flight in
                        flightLink(flight)
                    }
                }

                if !past.isEmpty {
                    sectionHeader("Past")
                    ForEach(past) { flight in
                        flightLink(flight)
                    }
                }
            }
            .padding()
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
    }

    private func flightLink(_ flight: Flight) -> some View {
        NavigationLink {
            FlightDetailView(flight: flight)
        } label: {
            FlightCard(flight: flight)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                flight.isTracked = false
                try? modelContext.save()
            } label: {
                Label("Stop Tracking", systemImage: "bell.slash")
            }

            Button(role: .destructive) {
                modelContext.delete(flight)
                try? modelContext.save()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "airplane.circle")
                .font(.system(size: 56))
                .foregroundStyle(.tertiary)

            Text("No Tracked Flights")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Search for a flight and tap \"Track\" to add it here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("With Flights") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Flight.self, configurations: config)
    let context = container.mainContext

    let f1 = Flight.preview
    f1.isTracked = true
    context.insert(f1)

    let f2 = Flight.previewScheduled
    f2.isTracked = true
    context.insert(f2)

    let f3 = Flight.previewLanded
    f3.isTracked = true
    context.insert(f3)

    return MyFlightsView()
        .modelContainer(container)
}

#Preview("Empty") {
    MyFlightsView()
        .modelContainer(for: Flight.self, inMemory: true)
}
