import SwiftUI
import Combine

/// Central observable state for the Afterglow app.
/// Coordinates between the Night Shift controller, rule manager,
/// and UI layer via Combine publishers.
final class AppState: ObservableObject {
    // MARK: - Night Shift State
    @Published var isNightShiftEnabled: Bool = false
    @Published var colorTemperature: Float = 0.5 // 0.0 (warm) to 1.0 (cool)
    @Published var schedule: NightShiftSchedule = .off
    @Published var isNightShiftSupported: Bool = true

    // MARK: - True Tone State
    @Published var isTrueToneEnabled: Bool = false
    @Published var isTrueToneSupported: Bool = false
    @Published var isTrueToneAvailable: Bool = false

    // MARK: - Disable Timer
    @Published var activeDisableTimer: DisableTimer?

    // MARK: - Rule State
    @Published var currentApp: RunningApp?
    @Published var currentDomain: String?
    @Published var currentSubdomain: String?
    @Published var isDisabledForCurrentApp: Bool = false
    @Published var isDisabledForCurrentDomain: Bool = false

    // MARK: - Controllers
    let nightShift: NightShiftController
    let trueTone: TrueToneController
    let rules: RuleManager
    let shortcuts: ShortcutManager

    private var cancellables = Set<AnyCancellable>()

    init(
        nightShift: NightShiftController = NightShiftController(),
        trueTone: TrueToneController = TrueToneController(),
        rules: RuleManager = RuleManager(),
        shortcuts: ShortcutManager = ShortcutManager()
    ) {
        self.nightShift = nightShift
        self.trueTone = trueTone
        self.rules = rules
        self.shortcuts = shortcuts

        setupBindings()
        refreshState()
    }

    // MARK: - Actions

    func toggleNightShift() {
        let newState = !isNightShiftEnabled
        nightShift.setEnabled(newState)
        isNightShiftEnabled = newState
    }

    func toggleTrueTone() {
        let newState = !isTrueToneEnabled
        trueTone.setEnabled(newState)
        isTrueToneEnabled = newState
    }

    func setColorTemperature(_ value: Float) {
        let clamped = min(max(value, 0.0), 1.0)
        nightShift.setStrength(clamped)
        colorTemperature = clamped
    }

    func disableForOneHour() {
        nightShift.setEnabled(false)
        let timer = DisableTimer(duration: .hour)
        activeDisableTimer = timer
        timer.start { [weak self] in
            self?.disableTimerExpired()
        }
    }

    func disableForCustomTime(minutes: Int) {
        nightShift.setEnabled(false)
        let timer = DisableTimer(duration: .custom(minutes: minutes))
        activeDisableTimer = timer
        timer.start { [weak self] in
            self?.disableTimerExpired()
        }
    }

    func cancelDisableTimer() {
        activeDisableTimer?.cancel()
        activeDisableTimer = nil
        refreshState()
    }

    func refreshState() {
        isNightShiftEnabled = nightShift.isEnabled
        colorTemperature = nightShift.strength
        schedule = nightShift.currentSchedule

        isTrueToneSupported = trueTone.isSupported
        isTrueToneAvailable = trueTone.isAvailable
        isTrueToneEnabled = trueTone.isEnabled
    }

    // MARK: - Private

    private func setupBindings() {
        nightShift.onStateChanged = { [weak self] in
            DispatchQueue.main.async {
                self?.refreshState()
            }
        }

        // Observe frontmost app changes to update rule state
        NSWorkspace.shared.notificationCenter
            .publisher(for: NSWorkspace.didActivateApplicationNotification)
            .compactMap { $0.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] app in
                self?.handleAppActivated(app)
            }
            .store(in: &cancellables)
    }

    private func handleAppActivated(_ app: NSRunningApplication) {
        currentApp = RunningApp(from: app)

        if let bundleID = app.bundleIdentifier {
            let wasDisabled = isDisabledForCurrentApp
            isDisabledForCurrentApp = rules.isAppDisabled(bundleIdentifier: bundleID)

            if isDisabledForCurrentApp && !wasDisabled {
                nightShift.setEnabled(false)
            } else if !isDisabledForCurrentApp && wasDisabled {
                refreshState()
            }
        }
    }

    private func disableTimerExpired() {
        DispatchQueue.main.async { [weak self] in
            self?.activeDisableTimer = nil
            self?.refreshState()
        }
    }
}

/// Lightweight representation of a running application for display purposes.
struct RunningApp: Identifiable {
    let id: String // bundle identifier
    let name: String
    let icon: NSImage?

    init?(from app: NSRunningApplication) {
        guard let bundleID = app.bundleIdentifier else { return nil }
        self.id = bundleID
        self.name = app.localizedName ?? bundleID
        self.icon = app.icon
    }
}
