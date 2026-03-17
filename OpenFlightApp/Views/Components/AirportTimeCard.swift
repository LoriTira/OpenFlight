import SwiftUI

struct AirportTimeCard: View {
    let title: String // "Departure" or "Arrival"
    let airportCode: String
    let airportName: String
    let city: String
    let scheduled: Date?
    let estimated: Date?
    let actual: Date?
    let gate: String?
    let terminal: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Text(title.uppercased())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            // Airport
            HStack(alignment: .firstTextBaseline) {
                Text(airportCode)
                    .font(.title)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                VStack(alignment: .leading, spacing: 2) {
                    Text(airportName)
                        .font(.subheadline)
                        .lineLimit(1)
                    if !city.isEmpty {
                        Text(city)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Divider()

            // Times
            VStack(alignment: .leading, spacing: 8) {
                timeRow(label: "Scheduled", time: scheduled)

                if let estimated, estimated != scheduled {
                    timeRow(label: "Estimated", time: estimated, highlight: true)
                }

                if let actual {
                    timeRow(label: "Actual", time: actual, highlight: true)
                }
            }

            // Gate & Terminal
            if gate != nil || terminal != nil {
                Divider()
                HStack(spacing: 16) {
                    if let terminal {
                        infoChip(label: "Terminal", value: terminal)
                    }
                    if let gate {
                        infoChip(label: "Gate", value: gate)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private func timeRow(label: String, time: Date?, highlight: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(DateFormatting.time(time))
                .font(.subheadline)
                .fontWeight(highlight ? .semibold : .regular)
                .fontDesign(.rounded)
                .foregroundStyle(highlight ? .primary : .secondary)
        }
    }

    @ViewBuilder
    private func infoChip(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(label.uppercased())
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
        }
    }
}

#Preview {
    AirportTimeCard(
        title: "Departure",
        airportCode: "SFO",
        airportName: "San Francisco International",
        city: "San Francisco",
        scheduled: Date.now.addingTimeInterval(-3600),
        estimated: Date.now.addingTimeInterval(-3500),
        actual: Date.now.addingTimeInterval(-3480),
        gate: "B42",
        terminal: "3"
    )
    .padding()
}
