import SwiftUI

struct ContentView: View {
    @State private var flightNumber: String = ""
    @State private var status: FlightStatus?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Enter flight #", text: $flightNumber)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                Button("Track Flight") {
                    Task {
                        status = await FlightAPI.shared.fetchStatus(for: flightNumber)
                    }
                }
                if let status = status {
                    FlightStatusView(status: status)
                }
                Spacer()
            }
            .navigationTitle("OpenFlight")
        }
    }
}

#Preview {
    ContentView()
}
