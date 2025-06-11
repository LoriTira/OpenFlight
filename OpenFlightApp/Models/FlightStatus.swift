import Foundation

struct FlightStatus: Codable {
    var description: String
    var details: String

    static let placeholder = FlightStatus(description: "On Time", details: "Departing Soon")
}
