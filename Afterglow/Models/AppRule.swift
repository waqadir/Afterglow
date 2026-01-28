import Foundation

/// Represents a rule to disable Night Shift for a specific application.
struct AppRule: Codable, Identifiable, Hashable {
    var id: String { bundleIdentifier }

    let bundleIdentifier: String
    let appName: String
    var isEnabled: Bool
    var mode: DisableMode

    /// How the app rule triggers Night Shift disabling.
    enum DisableMode: String, Codable {
        /// Disable only when the app is the frontmost (active) application.
        case whenFrontmost
        /// Disable whenever the app is running, regardless of focus.
        case whenRunning
    }

    init(
        bundleIdentifier: String,
        appName: String,
        isEnabled: Bool = true,
        mode: DisableMode = .whenFrontmost
    ) {
        self.bundleIdentifier = bundleIdentifier
        self.appName = appName
        self.isEnabled = isEnabled
        self.mode = mode
    }
}
