import ActivityKit
import WidgetKit
import SwiftUI

struct FlightAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var status: FlightStatus
    }

    var flightNumber: String
}

struct FlightLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FlightAttributes.self) { context in
            VStack {
                Text("Flight \(context.attributes.flightNumber)")
                Text(context.state.status.description)
            }
            .padding()
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.state.status.description)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.status.details)
                }
            } compactLeading: {
                Text(context.attributes.flightNumber)
            } compactTrailing: {
                Text("\(context.state.status.description.prefix(1))")
            } minimal: {
                Text("\(context.state.status.description.prefix(1))")
            }
        }
    }
}
