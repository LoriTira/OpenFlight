import Foundation

final class FlightAPI {
    static let shared = FlightAPI()

    func fetchStatus(for flight: String) async -> FlightStatus {
        // In a real app, perform network call to a flight tracking API
        // Placeholder implementation
        await Task.sleep(500_000_000) // simulate delay
        return .placeholder
    }
}
