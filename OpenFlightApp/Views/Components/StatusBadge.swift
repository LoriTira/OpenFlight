import SwiftUI

struct StatusBadge: View {
    let phase: FlightPhase
    let delayText: String?

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: phase.icon)
                .font(.caption2)
            Text(delayText ?? phase.label)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(backgroundColor.opacity(0.15))
        .foregroundStyle(backgroundColor)
        .clipShape(Capsule())
    }

    private var backgroundColor: Color {
        switch phase {
        case .scheduled: return .blue
        case .boarding: return .orange
        case .departed, .enRoute: return .green
        case .landed, .arrived: return .secondary
        case .cancelled: return .red
        case .diverted: return .purple
        case .unknown: return .gray
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        StatusBadge(phase: .enRoute, delayText: nil)
        StatusBadge(phase: .enRoute, delayText: "12m late")
        StatusBadge(phase: .cancelled, delayText: nil)
        StatusBadge(phase: .scheduled, delayText: nil)
        StatusBadge(phase: .landed, delayText: nil)
    }
}
