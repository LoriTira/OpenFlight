import Foundation
import SwiftData

// MARK: - Flight Status

enum FlightPhase: String, Codable, CaseIterable {
    case scheduled
    case boarding
    case departed
    case enRoute = "en_route"
    case landed
    case arrived
    case cancelled
    case diverted
    case unknown

    var label: String {
        switch self {
        case .scheduled: return "Scheduled"
        case .boarding: return "Boarding"
        case .departed: return "Departed"
        case .enRoute: return "En Route"
        case .landed: return "Landed"
        case .arrived: return "Arrived"
        case .cancelled: return "Cancelled"
        case .diverted: return "Diverted"
        case .unknown: return "Unknown"
        }
    }

    var icon: String {
        switch self {
        case .scheduled: return "clock"
        case .boarding: return "door.left.hand.open"
        case .departed: return "airplane.departure"
        case .enRoute: return "airplane"
        case .landed: return "airplane.arrival"
        case .arrived: return "checkmark.circle.fill"
        case .cancelled: return "xmark.circle.fill"
        case .diverted: return "arrow.triangle.branch"
        case .unknown: return "questionmark.circle"
        }
    }

    var isActive: Bool {
        switch self {
        case .boarding, .departed, .enRoute: return true
        default: return false
        }
    }

    var isTerminal: Bool {
        switch self {
        case .landed, .arrived, .cancelled: return true
        default: return false
        }
    }
}

// MARK: - Airport Info

struct AirportInfo: Codable, Equatable {
    var iata: String
    var name: String
    var city: String
    var timezone: String?
    var gate: String?
    var terminal: String?

    var displayCode: String { iata.uppercased() }
}

// MARK: - Flight Model (SwiftData)

@Model
final class Flight {
    @Attribute(.unique) var id: String // flightNumber + date
    var flightNumber: String
    var airlineCode: String
    var airlineName: String

    // Departure
    var departureIATA: String
    var departureName: String
    var departureCity: String
    var departureTimezone: String?
    var departureGate: String?
    var departureTerminal: String?
    var scheduledDeparture: Date?
    var estimatedDeparture: Date?
    var actualDeparture: Date?

    // Arrival
    var arrivalIATA: String
    var arrivalName: String
    var arrivalCity: String
    var arrivalTimezone: String?
    var arrivalGate: String?
    var arrivalTerminal: String?
    var scheduledArrival: Date?
    var estimatedArrival: Date?
    var actualArrival: Date?

    // Status
    var phaseRaw: String
    var delayMinutes: Int?
    var aircraft: String?

    // Tracking
    var isTracked: Bool
    var lastUpdated: Date
    var flightDate: Date

    var phase: FlightPhase {
        get { FlightPhase(rawValue: phaseRaw) ?? .unknown }
        set { phaseRaw = newValue.rawValue }
    }

    var departure: AirportInfo {
        AirportInfo(
            iata: departureIATA,
            name: departureName,
            city: departureCity,
            timezone: departureTimezone,
            gate: departureGate,
            terminal: departureTerminal
        )
    }

    var arrival: AirportInfo {
        AirportInfo(
            iata: arrivalIATA,
            name: arrivalName,
            city: arrivalCity,
            timezone: arrivalTimezone,
            gate: arrivalGate,
            terminal: arrivalTerminal
        )
    }

    /// Estimated or scheduled departure time (best available)
    var bestDeparture: Date? {
        actualDeparture ?? estimatedDeparture ?? scheduledDeparture
    }

    /// Estimated or scheduled arrival time (best available)
    var bestArrival: Date? {
        actualArrival ?? estimatedArrival ?? scheduledArrival
    }

    /// Flight progress from 0.0 to 1.0
    var progress: Double {
        guard phase.isActive || phase == .landed || phase == .arrived else {
            return phase.isTerminal ? 1.0 : 0.0
        }
        guard let dep = bestDeparture, let arr = bestArrival else { return 0.0 }
        let total = arr.timeIntervalSince(dep)
        guard total > 0 else { return 0.0 }
        let elapsed = Date.now.timeIntervalSince(dep)
        return min(max(elapsed / total, 0.0), 1.0)
    }

    /// Whether the flight is delayed
    var isDelayed: Bool {
        (delayMinutes ?? 0) > 0
    }

    /// Formatted delay string
    var delayText: String? {
        guard let mins = delayMinutes, mins > 0 else { return nil }
        if mins >= 60 {
            let h = mins / 60
            let m = mins % 60
            return m > 0 ? "\(h)h \(m)m late" : "\(h)h late"
        }
        return "\(mins)m late"
    }

    init(
        flightNumber: String,
        airlineCode: String = "",
        airlineName: String = "",
        departureIATA: String,
        departureName: String = "",
        departureCity: String = "",
        departureTimezone: String? = nil,
        departureGate: String? = nil,
        departureTerminal: String? = nil,
        scheduledDeparture: Date? = nil,
        estimatedDeparture: Date? = nil,
        actualDeparture: Date? = nil,
        arrivalIATA: String,
        arrivalName: String = "",
        arrivalCity: String = "",
        arrivalTimezone: String? = nil,
        arrivalGate: String? = nil,
        arrivalTerminal: String? = nil,
        scheduledArrival: Date? = nil,
        estimatedArrival: Date? = nil,
        actualArrival: Date? = nil,
        phase: FlightPhase = .scheduled,
        delayMinutes: Int? = nil,
        aircraft: String? = nil,
        flightDate: Date = .now,
        isTracked: Bool = false
    ) {
        let dateStr = Self.dateString(from: flightDate)
        self.id = "\(flightNumber.uppercased())_\(dateStr)"
        self.flightNumber = flightNumber.uppercased()
        self.airlineCode = airlineCode.uppercased()
        self.airlineName = airlineName
        self.departureIATA = departureIATA.uppercased()
        self.departureName = departureName
        self.departureCity = departureCity
        self.departureTimezone = departureTimezone
        self.departureGate = departureGate
        self.departureTerminal = departureTerminal
        self.scheduledDeparture = scheduledDeparture
        self.estimatedDeparture = estimatedDeparture
        self.actualDeparture = actualDeparture
        self.arrivalIATA = arrivalIATA.uppercased()
        self.arrivalName = arrivalName
        self.arrivalCity = arrivalCity
        self.arrivalTimezone = arrivalTimezone
        self.arrivalGate = arrivalGate
        self.arrivalTerminal = arrivalTerminal
        self.scheduledArrival = scheduledArrival
        self.estimatedArrival = estimatedArrival
        self.actualArrival = actualArrival
        self.phaseRaw = phase.rawValue
        self.delayMinutes = delayMinutes
        self.aircraft = aircraft
        self.flightDate = flightDate
        self.isTracked = isTracked
        self.lastUpdated = .now
    }

    static func dateString(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}

// MARK: - Preview Helpers

extension Flight {
    static var preview: Flight {
        Flight(
            flightNumber: "UA2402",
            airlineCode: "UA",
            airlineName: "United Airlines",
            departureIATA: "SFO",
            departureName: "San Francisco International",
            departureCity: "San Francisco",
            departureGate: "B42",
            departureTerminal: "3",
            scheduledDeparture: Date.now.addingTimeInterval(-3600),
            estimatedDeparture: Date.now.addingTimeInterval(-3500),
            actualDeparture: Date.now.addingTimeInterval(-3500),
            arrivalIATA: "JFK",
            arrivalName: "John F. Kennedy International",
            arrivalCity: "New York",
            arrivalGate: "T4",
            arrivalTerminal: "4",
            scheduledArrival: Date.now.addingTimeInterval(14400),
            estimatedArrival: Date.now.addingTimeInterval(14500),
            phase: .enRoute,
            delayMinutes: 12,
            aircraft: "Boeing 737-900"
        )
    }

    static var previewScheduled: Flight {
        Flight(
            flightNumber: "DL1837",
            airlineCode: "DL",
            airlineName: "Delta Air Lines",
            departureIATA: "LAX",
            departureName: "Los Angeles International",
            departureCity: "Los Angeles",
            departureGate: "A12",
            departureTerminal: "2",
            scheduledDeparture: Date.now.addingTimeInterval(7200),
            arrivalIATA: "ORD",
            arrivalName: "O'Hare International",
            arrivalCity: "Chicago",
            scheduledArrival: Date.now.addingTimeInterval(21600),
            phase: .scheduled,
            aircraft: "Airbus A321"
        )
    }

    static var previewLanded: Flight {
        Flight(
            flightNumber: "AA100",
            airlineCode: "AA",
            airlineName: "American Airlines",
            departureIATA: "JFK",
            departureName: "John F. Kennedy International",
            departureCity: "New York",
            departureTerminal: "8",
            scheduledDeparture: Date.now.addingTimeInterval(-28800),
            actualDeparture: Date.now.addingTimeInterval(-28800),
            arrivalIATA: "LHR",
            arrivalName: "London Heathrow",
            arrivalCity: "London",
            arrivalTerminal: "5",
            scheduledArrival: Date.now.addingTimeInterval(-3600),
            actualArrival: Date.now.addingTimeInterval(-3200),
            phase: .landed,
            aircraft: "Boeing 777-300ER"
        )
    }
}
