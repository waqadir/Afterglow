import Foundation

/// Manages a temporary disable period for Night Shift.
final class DisableTimer: ObservableObject, Identifiable {
    let id = UUID()
    let duration: Duration
    let startDate: Date
    let endDate: Date

    @Published var isActive: Bool = false

    private var timer: Timer?

    enum Duration: Equatable {
        case hour
        case custom(minutes: Int)

        var timeInterval: TimeInterval {
            switch self {
            case .hour:
                return 3600
            case .custom(let minutes):
                return TimeInterval(minutes * 60)
            }
        }

        var displayString: String {
            switch self {
            case .hour:
                return "1 hour"
            case .custom(let minutes):
                if minutes >= 60 {
                    let hours = minutes / 60
                    let remaining = minutes % 60
                    if remaining == 0 {
                        return "\(hours) hour\(hours == 1 ? "" : "s")"
                    }
                    return "\(hours)h \(remaining)m"
                }
                return "\(minutes) minute\(minutes == 1 ? "" : "s")"
            }
        }
    }

    var remainingTime: TimeInterval {
        max(0, endDate.timeIntervalSinceNow)
    }

    var remainingTimeFormatted: String {
        let remaining = Int(remainingTime)
        let hours = remaining / 3600
        let minutes = (remaining % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m remaining"
        }
        return "\(minutes)m remaining"
    }

    init(duration: Duration) {
        self.duration = duration
        self.startDate = Date()
        self.endDate = Date().addingTimeInterval(duration.timeInterval)
    }

    func start(onExpire: @escaping () -> Void) {
        isActive = true

        // Use appropriate timer tolerance to save energy
        let tolerance: TimeInterval
        switch duration.timeInterval {
        case let t where t > 1800: tolerance = 60
        case let t where t > 300: tolerance = 10
        default: tolerance = 1
        }

        timer = Timer.scheduledTimer(withTimeInterval: duration.timeInterval, repeats: false) { [weak self] _ in
            self?.isActive = false
            onExpire()
        }
        timer?.tolerance = tolerance
    }

    func cancel() {
        timer?.invalidate()
        timer = nil
        isActive = false
    }
}
