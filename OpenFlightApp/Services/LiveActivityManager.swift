import ActivityKit
import Foundation

@MainActor
final class LiveActivityManager: ObservableObject {
    static let shared = LiveActivityManager()

    @Published private(set) var activeFlightNumber: String?

    private var currentActivity: Activity<FlightAttributes>?

    private init() {}

    var isTrackingFlight: Bool { currentActivity != nil }

    /// Start a Live Activity for the given flight.
    func startTracking(_ flight: Flight) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = FlightAttributes(
            flightNumber: flight.flightNumber,
            airlineCode: flight.airlineCode,
            departureCode: flight.departureIATA,
            arrivalCode: flight.arrivalIATA
        )

        let state = FlightAttributes.ContentState(
            phase: flight.phase.label,
            departureTime: flight.bestDeparture,
            arrivalTime: flight.bestArrival,
            gate: flight.departureGate,
            progress: flight.progress,
            delayMinutes: flight.delayMinutes
        )

        let content = ActivityContent(state: state, staleDate: Date.now.addingTimeInterval(900))

        do {
            currentActivity = try Activity<FlightAttributes>.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            activeFlightNumber = flight.flightNumber
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }

    /// Update the Live Activity with fresh flight data.
    func update(_ flight: Flight) async {
        guard let activity = currentActivity else { return }

        let state = FlightAttributes.ContentState(
            phase: flight.phase.label,
            departureTime: flight.bestDeparture,
            arrivalTime: flight.bestArrival,
            gate: flight.departureGate,
            progress: flight.progress,
            delayMinutes: flight.delayMinutes
        )

        let content = ActivityContent(state: state, staleDate: Date.now.addingTimeInterval(900))
        await activity.update(content)
    }

    /// End the Live Activity.
    func stopTracking() async {
        guard let activity = currentActivity else { return }

        let finalState = activity.content.state
        let content = ActivityContent(state: finalState, staleDate: nil)

        await activity.end(content, dismissalPolicy: .default)
        currentActivity = nil
        activeFlightNumber = nil
    }
}
