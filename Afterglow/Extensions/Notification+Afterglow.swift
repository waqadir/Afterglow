import Foundation

extension Notification.Name {
    static let nightShiftStateChanged = Notification.Name("afterglow.nightShiftStateChanged")
    static let nightShiftScheduleChanged = Notification.Name("afterglow.nightShiftScheduleChanged")
    static let trueToneStateChanged = Notification.Name("afterglow.trueToneStateChanged")
    static let disableTimerStarted = Notification.Name("afterglow.disableTimerStarted")
    static let disableTimerEnded = Notification.Name("afterglow.disableTimerEnded")
    static let ruleActivated = Notification.Name("afterglow.ruleActivated")
    static let ruleDeactivated = Notification.Name("afterglow.ruleDeactivated")
}
