import SwiftUI
import SwiftData

struct FlightSearchView: View {
    @StateObject private var viewModel = FlightSearchViewModel()
    @Environment(\.modelContext) private var modelContext
    @State private var selectedFlight: FlightData?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    searchBar
                    content
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Search")
            .sheet(item: $selectedFlight) { data in
                SearchResultDetailSheet(data: data) {
                    viewModel.trackFlight(data, context: modelContext)
                }
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Flight number (e.g. UA2402)", text: $viewModel.query)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .onSubmit { Task { await viewModel.search() } }

                if !viewModel.query.isEmpty {
                    Button { viewModel.query = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(12)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Button {
                Task { await viewModel.search() }
            } label: {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
            }
            .disabled(viewModel.query.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isLoading)
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            loadingView
        } else if let error = viewModel.error {
            errorView(error)
        } else if viewModel.results.isEmpty && viewModel.hasSearched {
            emptyView
        } else if !viewModel.results.isEmpty {
            resultsList
        } else {
            placeholderView
        }
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .controlSize(.large)
            Text("Searching flights...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Try Again") { Task { await viewModel.search() } }
                .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "airplane.circle")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No flights found")
                .font(.headline)
            Text("Check the flight number and try again.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    private var placeholderView: some View {
        VStack(spacing: 16) {
            Image(systemName: "airplane.circle")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text("Enter a flight number to get started")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if viewModel.isUsingMockData {
                Text("Set your API key in Settings to search real flights.")
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    private var resultsList: some View {
        VStack(spacing: 12) {
            ForEach(Array(viewModel.results.enumerated()), id: \.offset) { _, data in
                Button { selectedFlight = data } label: {
                    SearchResultRow(data: data)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Search Result Row

private struct SearchResultRow: View {
    let data: FlightData

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(data.flightNumber)
                        .font(.headline)
                        .fontDesign(.rounded)
                    if !data.airlineName.isEmpty {
                        Text("- \(data.airlineName)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                HStack(spacing: 4) {
                    Text(data.departure.iata)
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(data.arrival.iata)
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .fontDesign(.rounded)

                Text(DateFormatting.mediumDate(data.flightDate))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            StatusBadge(
                phase: data.phase,
                delayText: data.delayMinutes.flatMap { $0 > 0 ? "\($0)m late" : nil }
            )
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Detail Sheet

private struct SearchResultDetailSheet: View {
    let data: FlightData
    let onTrack: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text(data.flightNumber)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                        if !data.airlineName.isEmpty {
                            Text(data.airlineName)
                                .foregroundStyle(.secondary)
                        }
                        StatusBadge(
                            phase: data.phase,
                            delayText: data.delayMinutes.flatMap { $0 > 0 ? "\($0)m late" : nil }
                        )
                    }
                    .padding(.top)

                    // Route
                    FlightProgressBar(
                        departureCode: data.departure.iata,
                        arrivalCode: data.arrival.iata,
                        progress: data.phase.isActive ? 0.5 : (data.phase.isTerminal ? 1.0 : 0.0),
                        phase: data.phase
                    )
                    .padding(.horizontal)

                    // Airport cards
                    AirportTimeCard(
                        title: "Departure",
                        airportCode: data.departure.iata,
                        airportName: data.departure.name,
                        city: data.departure.city,
                        scheduled: data.scheduledDeparture,
                        estimated: data.estimatedDeparture,
                        actual: data.actualDeparture,
                        gate: data.departure.gate,
                        terminal: data.departure.terminal
                    )

                    AirportTimeCard(
                        title: "Arrival",
                        airportCode: data.arrival.iata,
                        airportName: data.arrival.name,
                        city: data.arrival.city,
                        scheduled: data.scheduledArrival,
                        estimated: data.estimatedArrival,
                        actual: data.actualArrival,
                        gate: data.arrival.gate,
                        terminal: data.arrival.terminal
                    )

                    if let aircraft = data.aircraft {
                        HStack {
                            Image(systemName: "airplane.circle")
                                .foregroundStyle(.secondary)
                            Text(aircraft)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Track button
                    Button {
                        onTrack()
                        dismiss()
                    } label: {
                        Label("Track This Flight", systemImage: "bell.badge")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Identifiable conformance for FlightData

extension FlightData: Identifiable, Equatable {
    var id: String { "\(flightNumber)_\(Flight.dateString(from: flightDate))" }

    static func == (lhs: FlightData, rhs: FlightData) -> Bool {
        lhs.id == rhs.id
    }
}

#Preview {
    FlightSearchView()
        .modelContainer(for: Flight.self, inMemory: true)
}
