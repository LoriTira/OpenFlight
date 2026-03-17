import Foundation

// MARK: - Flight Service Protocol

protocol FlightServiceProtocol {
    func searchFlight(_ flightNumber: String, date: Date?) async throws -> [FlightData]
}

// MARK: - Intermediate DTO (decoupled from SwiftData)

struct FlightData {
    var flightNumber: String
    var airlineCode: String
    var airlineName: String
    var departure: AirportInfo
    var arrival: AirportInfo
    var scheduledDeparture: Date?
    var estimatedDeparture: Date?
    var actualDeparture: Date?
    var scheduledArrival: Date?
    var estimatedArrival: Date?
    var actualArrival: Date?
    var phase: FlightPhase
    var delayMinutes: Int?
    var aircraft: String?
    var flightDate: Date
}

// MARK: - Service Errors

enum FlightServiceError: LocalizedError {
    case invalidFlightNumber
    case networkError(Error)
    case apiError(String)
    case rateLimited
    case noResults
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidFlightNumber:
            return "Please enter a valid flight number (e.g. UA2402)."
        case .networkError(let err):
            return "Network error: \(err.localizedDescription)"
        case .apiError(let msg):
            return "API error: \(msg)"
        case .rateLimited:
            return "API rate limit reached. Try again later."
        case .noResults:
            return "No flights found. Check the flight number and date."
        case .decodingError:
            return "Failed to parse flight data."
        }
    }
}

// MARK: - AviationStack Service

/// Free flight data via AviationStack (https://aviationstack.com).
/// Sign up for a free API key (100 requests/month on free tier).
final class AviationStackService: FlightServiceProtocol {
    private let apiKey: String
    private let baseURL = "https://api.aviationstack.com/v1"
    private let session: URLSession

    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    func searchFlight(_ flightNumber: String, date: Date?) async throws -> [FlightData] {
        let cleaned = flightNumber.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard cleaned.count >= 3, cleaned.first?.isLetter == true else {
            throw FlightServiceError.invalidFlightNumber
        }

        var components = URLComponents(string: "\(baseURL)/flights")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "access_key", value: apiKey),
            URLQueryItem(name: "flight_iata", value: cleaned),
        ]
        if let date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            queryItems.append(URLQueryItem(name: "flight_date", value: formatter.string(from: date)))
        }
        components.queryItems = queryItems

        let request = URLRequest(url: components.url!)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw FlightServiceError.networkError(error)
        }

        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 200: break
            case 429: throw FlightServiceError.rateLimited
            default:
                throw FlightServiceError.apiError("HTTP \(httpResponse.statusCode)")
            }
        }

        let decoded: AviationStackResponse
        do {
            let decoder = JSONDecoder()
            decoded = try decoder.decode(AviationStackResponse.self, from: data)
        } catch {
            throw FlightServiceError.decodingError
        }

        if let error = decoded.error {
            throw FlightServiceError.apiError(error.message)
        }

        guard let results = decoded.data, !results.isEmpty else {
            throw FlightServiceError.noResults
        }

        return results.map { $0.toFlightData() }
    }
}

// MARK: - AviationStack Response Models

private struct AviationStackResponse: Decodable {
    let data: [ASFlight]?
    let error: ASError?
}

private struct ASError: Decodable {
    let message: String
}

private struct ASFlight: Decodable {
    let flight_date: String?
    let flight_status: String?
    let departure: ASAirport?
    let arrival: ASAirport?
    let airline: ASAirline?
    let flight: ASFlightInfo?
    let aircraft: ASAircraft?

    func toFlightData() -> FlightData {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let isoBasic = ISO8601DateFormatter()
        isoBasic.formatOptions = [.withInternetDateTime]

        func parseDate(_ str: String?) -> Date? {
            guard let str else { return nil }
            return isoFormatter.date(from: str) ?? isoBasic.date(from: str)
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let flightDate = dateFormatter.date(from: flight_date ?? "") ?? Date.now

        let phase: FlightPhase = {
            switch flight_status?.lowercased() {
            case "scheduled": return .scheduled
            case "active": return .enRoute
            case "landed": return .landed
            case "cancelled": return .cancelled
            case "incident": return .diverted
            case "diverted": return .diverted
            default: return .unknown
            }
        }()

        let depDelay = departure?.delay
        let arrDelay = arrival?.delay
        let delay = arrDelay ?? depDelay

        return FlightData(
            flightNumber: flight?.iata?.uppercased() ?? "???",
            airlineCode: airline?.iata?.uppercased() ?? "",
            airlineName: airline?.name ?? "",
            departure: AirportInfo(
                iata: departure?.iata?.uppercased() ?? "???",
                name: departure?.airport ?? "",
                city: departure?.timezone?.components(separatedBy: "/").last?.replacingOccurrences(of: "_", with: " ") ?? "",
                timezone: departure?.timezone,
                gate: departure?.gate,
                terminal: departure?.terminal
            ),
            arrival: AirportInfo(
                iata: arrival?.iata?.uppercased() ?? "???",
                name: arrival?.airport ?? "",
                city: arrival?.timezone?.components(separatedBy: "/").last?.replacingOccurrences(of: "_", with: " ") ?? "",
                timezone: arrival?.timezone,
                gate: arrival?.gate,
                terminal: arrival?.terminal
            ),
            scheduledDeparture: parseDate(departure?.scheduled),
            estimatedDeparture: parseDate(departure?.estimated),
            actualDeparture: parseDate(departure?.actual),
            scheduledArrival: parseDate(arrival?.scheduled),
            estimatedArrival: parseDate(arrival?.estimated),
            actualArrival: parseDate(arrival?.actual),
            phase: phase,
            delayMinutes: delay,
            aircraft: aircraft?.registration,
            flightDate: flightDate
        )
    }
}

private struct ASAirport: Decodable {
    let airport: String?
    let timezone: String?
    let iata: String?
    let gate: String?
    let terminal: String?
    let delay: Int?
    let scheduled: String?
    let estimated: String?
    let actual: String?
}

private struct ASAirline: Decodable {
    let name: String?
    let iata: String?
}

private struct ASFlightInfo: Decodable {
    let iata: String?
}

private struct ASAircraft: Decodable {
    let registration: String?
}

// MARK: - Mock Service (for previews and testing)

final class MockFlightService: FlightServiceProtocol {
    var mockResults: [FlightData] = []
    var shouldFail = false

    func searchFlight(_ flightNumber: String, date: Date?) async throws -> [FlightData] {
        try await Task.sleep(for: .milliseconds(300))

        if shouldFail {
            throw FlightServiceError.networkError(URLError(.notConnectedToInternet))
        }

        let cleaned = flightNumber.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard cleaned.count >= 3 else {
            throw FlightServiceError.invalidFlightNumber
        }

        if !mockResults.isEmpty {
            return mockResults
        }

        // Generate realistic mock data
        return [FlightData(
            flightNumber: cleaned,
            airlineCode: String(cleaned.prefix(2)),
            airlineName: "Mock Airlines",
            departure: AirportInfo(iata: "SFO", name: "San Francisco International", city: "San Francisco", gate: "B42", terminal: "3"),
            arrival: AirportInfo(iata: "JFK", name: "John F. Kennedy International", city: "New York", gate: "T4", terminal: "4"),
            scheduledDeparture: Date.now.addingTimeInterval(-3600),
            estimatedDeparture: Date.now.addingTimeInterval(-3500),
            actualDeparture: Date.now.addingTimeInterval(-3500),
            scheduledArrival: Date.now.addingTimeInterval(14400),
            estimatedArrival: Date.now.addingTimeInterval(14700),
            actualArrival: nil,
            phase: .enRoute,
            delayMinutes: 5,
            aircraft: "Boeing 737-900",
            flightDate: date ?? .now
        )]
    }
}
