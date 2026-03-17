import SwiftUI

struct FlightProgressBar: View {
    let departureCode: String
    let arrivalCode: String
    let progress: Double
    let phase: FlightPhase

    var body: some View {
        VStack(spacing: 6) {
            // Airport codes
            HStack {
                Text(departureCode)
                    .font(.title2)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                Spacer()
                Text(arrivalCode)
                    .font(.title2)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
            }

            // Progress bar with airplane
            ZStack(alignment: .leading) {
                // Track
                Capsule()
                    .fill(Color(.systemGray5))
                    .frame(height: 4)

                // Filled portion
                GeometryReader { geo in
                    Capsule()
                        .fill(trackColor)
                        .frame(width: max(0, geo.size.width * progress), height: 4)
                }
                .frame(height: 4)

                // Airplane icon
                GeometryReader { geo in
                    let xPos = geo.size.width * progress
                    Image(systemName: "airplane")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(airplaneColor)
                        .offset(x: min(max(xPos - 8, 0), geo.size.width - 16))
                        .offset(y: -12)
                }
                .frame(height: 4)
            }
            .padding(.vertical, 8)

            // Dots for departure and arrival
            HStack {
                Circle()
                    .fill(progress > 0 ? trackColor : Color(.systemGray4))
                    .frame(width: 8, height: 8)
                Spacer()
                Circle()
                    .fill(progress >= 1.0 ? trackColor : Color(.systemGray4))
                    .frame(width: 8, height: 8)
            }
            .padding(.horizontal, -2)
        }
    }

    private var trackColor: Color {
        switch phase {
        case .cancelled: return .red
        case .diverted: return .purple
        default: return .accentColor
        }
    }

    private var airplaneColor: Color {
        phase == .cancelled ? .red : .accentColor
    }
}

#Preview {
    VStack(spacing: 40) {
        FlightProgressBar(departureCode: "SFO", arrivalCode: "JFK", progress: 0.0, phase: .scheduled)
        FlightProgressBar(departureCode: "SFO", arrivalCode: "JFK", progress: 0.4, phase: .enRoute)
        FlightProgressBar(departureCode: "SFO", arrivalCode: "JFK", progress: 1.0, phase: .landed)
        FlightProgressBar(departureCode: "SFO", arrivalCode: "JFK", progress: 0.3, phase: .cancelled)
    }
    .padding()
}
