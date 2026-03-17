import ActivityKit
import Foundation

struct FlightAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var phase: String
        var departureTime: Date?
        var arrivalTime: Date?
        var gate: String?
        var progress: Double
        var delayMinutes: Int?

        var isDelayed: Bool { (delayMinutes ?? 0) > 0 }
    }

    var flightNumber: String
    var airlineCode: String
    var departureCode: String
    var arrivalCode: String
}
