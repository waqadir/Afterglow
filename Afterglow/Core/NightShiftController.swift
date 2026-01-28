import Foundation

/// Controls Night Shift via the private CoreBrightness framework.
/// All interaction with CBBlueLightClient is isolated here for testability.
final class NightShiftController {
    private let client = CBBlueLightClient()

    /// Callback fired when Night Shift state changes externally (e.g., schedule trigger, Control Center).
    var onStateChanged: (() -> Void)?

    var isEnabled: Bool {
        var status = StatusData()
        client.getBlueLightStatus(&status)
        return status.enabled.boolValue
    }

    var strength: Float {
        var strength: Float = 0
        client.getStrength(&strength)
        return strength
    }

    var currentSchedule: NightShiftSchedule {
        var status = StatusData()
        client.getBlueLightStatus(&status)

        switch status.mode {
        case 0:
            return .off
        case 1:
            return .sunsetToSunrise
        case 2:
            let start = ScheduleTime(hour: Int(status.schedule.fromTime.hour),
                                     minute: Int(status.schedule.fromTime.minute))
            let end = ScheduleTime(hour: Int(status.schedule.toTime.hour),
                                   minute: Int(status.schedule.toTime.minute))
            return .custom(start: start, end: end)
        default:
            return .off
        }
    }

    init() {
        setupStatusNotification()
    }

    func setEnabled(_ enabled: Bool) {
        client.setEnabled(enabled)
    }

    func setStrength(_ strength: Float) {
        let clamped = min(max(strength, 0.0), 1.0)
        client.setStrength(clamped, commit: true)
    }

    func setSchedule(_ schedule: NightShiftSchedule) {
        switch schedule {
        case .off:
            client.setMode(0)
        case .sunsetToSunrise:
            client.setMode(1)
        case .custom(let start, let end):
            client.setMode(2)
            var scheduleData = ScheduleData()
            scheduleData.fromTime.hour = Int32(start.hour)
            scheduleData.fromTime.minute = Int32(start.minute)
            scheduleData.toTime.hour = Int32(end.hour)
            scheduleData.toTime.minute = Int32(end.minute)
            client.setSchedule(&scheduleData)
        }
    }

    static func isSupported() -> Bool {
        CBBlueLightClient.supportsBlueLightReduction()
    }

    // MARK: - Private

    private func setupStatusNotification() {
        client.setStatusNotificationBlock { [weak self] in
            self?.onStateChanged?()
        }
    }
}
