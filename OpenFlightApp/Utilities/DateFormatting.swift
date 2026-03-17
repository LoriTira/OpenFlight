import Foundation

enum DateFormatting {
    /// "3:42 PM"
    static func time(_ date: Date?) -> String {
        guard let date else { return "--:--" }
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }

    /// "Mar 17"
    static func shortDate(_ date: Date?) -> String {
        guard let date else { return "---" }
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: date)
    }

    /// "Mar 17, 2026"
    static func mediumDate(_ date: Date?) -> String {
        guard let date else { return "---" }
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }

    /// "3h 42m"
    static func duration(from start: Date?, to end: Date?) -> String {
        guard let start, let end else { return "--" }
        let seconds = Int(end.timeIntervalSince(start))
        guard seconds > 0 else { return "--" }
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        if h > 0 {
            return m > 0 ? "\(h)h \(m)m" : "\(h)h"
        }
        return "\(m)m"
    }

    /// Relative time: "in 2h", "35m ago"
    static func relative(_ date: Date?) -> String {
        guard let date else { return "--" }
        let diff = date.timeIntervalSinceNow
        let absDiff = abs(diff)
        let mins = Int(absDiff / 60)
        let hours = mins / 60

        if mins < 1 { return "now" }

        let label: String
        if hours > 0 {
            let remainMins = mins % 60
            label = remainMins > 0 ? "\(hours)h \(remainMins)m" : "\(hours)h"
        } else {
            label = "\(mins)m"
        }

        return diff > 0 ? "in \(label)" : "\(label) ago"
    }
}
