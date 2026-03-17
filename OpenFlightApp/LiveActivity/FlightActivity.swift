import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Live Activity Widget

struct FlightLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FlightAttributes.self) { context in
            // Lock Screen banner
            lockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.attributes.departureCode)
                            .font(.headline)
                            .fontDesign(.rounded)
                        if let time = context.state.departureTime {
                            Text(time, style: .time)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(context.attributes.arrivalCode)
                            .font(.headline)
                            .fontDesign(.rounded)
                        if let time = context.state.arrivalTime {
                            Text(time, style: .time)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 4) {
                        Text(context.attributes.flightNumber)
                            .font(.caption)
                            .fontWeight(.semibold)
                        ProgressView(value: context.state.progress)
                            .tint(context.state.isDelayed ? .orange : .accentColor)
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text(context.state.phase)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        if let gate = context.state.gate {
                            Text("Gate \(gate)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

            } compactLeading: {
                HStack(spacing: 4) {
                    Image(systemName: "airplane")
                        .font(.caption2)
                    Text(context.attributes.flightNumber)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                }

            } compactTrailing: {
                Text("\(context.attributes.departureCode)→\(context.attributes.arrivalCode)")
                    .font(.caption2)
                    .fontDesign(.rounded)

            } minimal: {
                Image(systemName: "airplane")
                    .font(.caption)
            }
        }
    }

    // MARK: - Lock Screen View

    @ViewBuilder
    private func lockScreenView(context: ActivityViewContext<FlightAttributes>) -> some View {
        VStack(spacing: 12) {
            // Top: flight number and status
            HStack {
                Text(context.attributes.flightNumber)
                    .font(.headline)
                    .fontDesign(.rounded)
                Spacer()
                Text(context.state.phase)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        context.state.isDelayed
                            ? Color.orange.opacity(0.2)
                            : Color.accentColor.opacity(0.2)
                    )
                    .clipShape(Capsule())
            }

            // Route with progress
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(context.attributes.departureCode)
                        .font(.title3)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                    if let time = context.state.departureTime {
                        Text(time, style: .time)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                VStack(spacing: 4) {
                    Image(systemName: "airplane")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ProgressView(value: context.state.progress)
                        .frame(width: 80)
                        .tint(context.state.isDelayed ? .orange : .accentColor)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(context.attributes.arrivalCode)
                        .font(.title3)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                    if let time = context.state.arrivalTime {
                        Text(time, style: .time)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Bottom: gate info
            if let gate = context.state.gate {
                HStack {
                    Spacer()
                    Label("Gate \(gate)", systemImage: "door.left.hand.open")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }
}
