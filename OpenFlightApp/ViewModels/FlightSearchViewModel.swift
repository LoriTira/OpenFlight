import Foundation
import SwiftData

@MainActor
final class FlightSearchViewModel: ObservableObject {
    @Published var query = ""
    @Published var results: [FlightData] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var hasSearched = false

    private let service: FlightServiceProtocol

    init(service: FlightServiceProtocol? = nil) {
        if let service {
            self.service = service
        } else if let key = AppConstants.storedAPIKey, !key.isEmpty {
            self.service = AviationStackService(apiKey: key)
        } else {
            self.service = MockFlightService()
        }
    }

    var isUsingMockData: Bool {
        service is MockFlightService
    }

    func search() async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        isLoading = true
        error = nil
        hasSearched = true

        do {
            results = try await service.searchFlight(trimmed, date: nil)
        } catch let err as FlightServiceError {
            error = err.errorDescription
            results = []
        } catch {
            self.error = error.localizedDescription
            results = []
        }

        isLoading = false
    }

    /// Save a flight result to SwiftData and mark as tracked
    func trackFlight(_ data: FlightData, context: ModelContext) {
        let flight = Flight(
            flightNumber: data.flightNumber,
            airlineCode: data.airlineCode,
            airlineName: data.airlineName,
            departureIATA: data.departure.iata,
            departureName: data.departure.name,
            departureCity: data.departure.city,
            departureTimezone: data.departure.timezone,
            departureGate: data.departure.gate,
            departureTerminal: data.departure.terminal,
            scheduledDeparture: data.scheduledDeparture,
            estimatedDeparture: data.estimatedDeparture,
            actualDeparture: data.actualDeparture,
            arrivalIATA: data.arrival.iata,
            arrivalName: data.arrival.name,
            arrivalCity: data.arrival.city,
            arrivalTimezone: data.arrival.timezone,
            arrivalGate: data.arrival.gate,
            arrivalTerminal: data.arrival.terminal,
            scheduledArrival: data.scheduledArrival,
            estimatedArrival: data.estimatedArrival,
            actualArrival: data.actualArrival,
            phase: data.phase,
            delayMinutes: data.delayMinutes,
            aircraft: data.aircraft,
            flightDate: data.flightDate,
            isTracked: true
        )
        context.insert(flight)
        try? context.save()
    }
}
