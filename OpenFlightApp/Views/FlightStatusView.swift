import SwiftUI

struct FlightStatusView: View {
    var status: FlightStatus

    var body: some View {
        VStack(spacing: 8) {
            Text(status.description)
                .font(.title)
                .bold()
            Text(status.details)
                .font(.subheadline)
        }
        .padding()
    }
}

#Preview {
    FlightStatusView(status: .placeholder)
}
