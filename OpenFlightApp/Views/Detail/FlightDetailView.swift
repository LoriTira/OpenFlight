import SwiftUI

struct FlightDetailView: View {
    @Bindable var flight: Flight
    @Environment(\.modelContext) private var modelContext
    @StateObject private var liveActivityManager = LiveActivityManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                progressSection
                departureCard
                arrivalCard
                infoSection
                actionsSection
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(flight.flightNumber)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(role: flight.isTracked ? .destructive : nil) {
                        flight.isTracked.toggle()
                        try? modelContext.save()
                    } label: {
                        Label(
                            flight.isTracked ? "Stop Tracking" : "Track Flight",
                            systemImage: flight.isTracked ? "bell.slash" : "bell.badge"
                        )
                    }

                    if flight.phase.isActive {
                        Button {
                            toggleLiveActivity()
                        } label: {
                            Label(
                                liveActivityManager.activeFlightNumber == flight.flightNumber
                                    ? "Remove from Lock Screen"
                                    : "Show on Lock Screen",
                                systemImage: "lock.display"
                            )
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(flight.flightNumber)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                    if !flight.airlineName.isEmpty {
                        Text(flight.airlineName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                StatusBadge(phase: flight.phase, delayText: flight.delayText)
            }

            HStack {
                Text(DateFormatting.mediumDate(flight.flightDate))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                if let aircraft = flight.aircraft {
                    Label(aircraft, systemImage: "airplane.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Progress

    private var progressSection: some View {
        VStack(spacing: 8) {
            FlightProgressBar(
                departureCode: flight.departureIATA,
                arrivalCode: flight.arrivalIATA,
                progress: flight.progress,
                phase: flight.phase
            )

            // Time summaries below progress
            HStack {
                VStack(alignment: .leading) {
                    Text(DateFormatting.time(flight.bestDeparture))
                        .font(.headline)
                        .fontDesign(.rounded)
                    Text(flight.departureCity.isEmpty ? flight.departureIATA : flight.departureCity)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack {
                    Text(DateFormatting.duration(from: flight.bestDeparture, to: flight.bestArrival))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(DateFormatting.time(flight.bestArrival))
                        .font(.headline)
                        .fontDesign(.rounded)
                    Text(flight.arrivalCity.isEmpty ? flight.arrivalIATA : flight.arrivalCity)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Airport Cards

    private var departureCard: some View {
        AirportTimeCard(
            title: "Departure",
            airportCode: flight.departureIATA,
            airportName: flight.departureName,
            city: flight.departureCity,
            scheduled: flight.scheduledDeparture,
            estimated: flight.estimatedDeparture,
            actual: flight.actualDeparture,
            gate: flight.departureGate,
            terminal: flight.departureTerminal
        )
    }

    private var arrivalCard: some View {
        AirportTimeCard(
            title: "Arrival",
            airportCode: flight.arrivalIATA,
            airportName: flight.arrivalName,
            city: flight.arrivalCity,
            scheduled: flight.scheduledArrival,
            estimated: flight.estimatedArrival,
            actual: flight.actualArrival,
            gate: flight.arrivalGate,
            terminal: flight.arrivalTerminal
        )
    }

    // MARK: - Info Section

    @ViewBuilder
    private var infoSection: some View {
        if flight.delayMinutes != nil || flight.aircraft != nil {
            VStack(alignment: .leading, spacing: 12) {
                Text("FLIGHT INFO")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                if let delay = flight.delayMinutes, delay > 0 {
                    HStack {
                        Image(systemName: "clock.badge.exclamationmark")
                            .foregroundStyle(.orange)
                        Text("Delayed by \(delay) minutes")
                            .font(.subheadline)
                    }
                }

                if let aircraft = flight.aircraft {
                    HStack {
                        Image(systemName: "airplane")
                            .foregroundStyle(.secondary)
                        Text(aircraft)
                            .font(.subheadline)
                    }
                }

                HStack {
                    Image(systemName: "arrow.clockwise")
                        .foregroundStyle(.secondary)
                    Text("Updated \(DateFormatting.relative(flight.lastUpdated))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Actions

    private var actionsSection: some View {
        VStack(spacing: 12) {
            if flight.phase.isActive {
                Button {
                    toggleLiveActivity()
                } label: {
                    Label(
                        liveActivityManager.activeFlightNumber == flight.flightNumber
                            ? "Remove from Lock Screen"
                            : "Show on Lock Screen",
                        systemImage: "lock.display"
                    )
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private func toggleLiveActivity() {
        if liveActivityManager.activeFlightNumber == flight.flightNumber {
            Task { await liveActivityManager.stopTracking() }
        } else {
            liveActivityManager.startTracking(flight)
        }
    }
}

#Preview {
    NavigationStack {
        FlightDetailView(flight: .preview)
    }
    .modelContainer(for: Flight.self, inMemory: true)
}
