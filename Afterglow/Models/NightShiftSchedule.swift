import Foundation

/// Represents the Night Shift schedule configuration.
enum NightShiftSchedule: Equatable {
    /// No schedule — Night Shift is manually controlled.
    case off
    /// Automatically activate from sunset to sunrise based on location.
    case sunsetToSunrise
    /// Activate on a custom schedule with specific start and end times.
    case custom(start: ScheduleTime, end: ScheduleTime)

    var displayName: String {
        switch self {
        case .off:
            return "Off"
        case .sunsetToSunrise:
            return "Sunset to Sunrise"
        case .custom(let start, let end):
            return "\(start.formatted) to \(end.formatted)"
        }
    }

    var isScheduled: Bool {
        self != .off
    }
}

/// A simple hour:minute time value used for schedule configuration.
struct ScheduleTime: Equatable, Codable {
    let hour: Int
    let minute: Int

    var formatted: String {
        let h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)
        let period = hour >= 12 ? "PM" : "AM"
        return String(format: "%d:%02d %@", h, minute, period)
    }

    var date: Date {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }

    init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }

    init(from date: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        self.hour = components.hour ?? 0
        self.minute = components.minute ?? 0
    }
}
