import SwiftUI

struct FlightCard: View {
    let flight: Flight

    var body: some View {
        VStack(spacing: 12) {
            // Top row: airline + status
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(flight.flightNumber)
                        .font(.headline)
                        .fontDesign(.rounded)
                    if !flight.airlineName.isEmpty {
                        Text(flight.airlineName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                StatusBadge(phase: flight.phase, delayText: flight.delayText)
            }

            // Route
            HStack(alignment: .center, spacing: 0) {
                // Departure
                VStack(spacing: 2) {
                    Text(flight.departureIATA)
                        .font(.title3)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                    Text(DateFormatting.time(flight.bestDeparture))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Middle arrow + duration
                VStack(spacing: 2) {
                    Image(systemName: "airplane")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(DateFormatting.duration(from: flight.bestDeparture, to: flight.bestArrival))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                // Arrival
                VStack(spacing: 2) {
                    Text(flight.arrivalIATA)
                        .font(.title3)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                    Text(DateFormatting.time(flight.bestArrival))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }

            // Progress bar (only for active flights)
            if flight.phase.isActive {
                ProgressView(value: flight.progress)
                    .tint(.accentColor)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    VStack(spacing: 12) {
        FlightCard(flight: .preview)
        FlightCard(flight: .previewScheduled)
        FlightCard(flight: .previewLanded)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
